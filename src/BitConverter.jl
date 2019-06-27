module BitConverter

export bytes, big, Int

"""
    bytes(x::Integer; len::Integer, little_endian::Bool)
    -> Vector{len, UInt8}

Convert an Integer `x` to a Vector{UInt8}
"""
function bytes(x::Integer; len::Integer=0, little_endian::Bool=false)
    result = reinterpret(UInt8, [hton(x)])
    i = findfirst(x -> x != 0x00, result)
    if len != 0
        i = length(result) - len + 1
    end
    result = result[i:end]
    if little_endian
        reverse!(result)
    end
    return result
end

function bytes(x::BigInt)
    n_bytes_with_zeros = x.size * sizeof(Sys.WORD_SIZE)
    uint8_ptr = convert(Ptr{UInt8}, x.d)
    n_bytes_without_zeros = 1

    if ENDIAN_BOM == 0x04030201
        # the minimum should be 1, else the result array will be of
        # length 0
        for i in n_bytes_with_zeros:-1:1
            if unsafe_load(uint8_ptr, i) != 0x00
                n_bytes_without_zeros = i
                break
            end
        end

        result = Array{UInt8}(undef, n_bytes_without_zeros)

        for i in 1:n_bytes_without_zeros
            @inbounds result[n_bytes_without_zeros + 1 - i] = unsafe_load(uint8_ptr, i)
        end
    else
        for i in 1:n_bytes_with_zeros
            if unsafe_load(uint8_ptr, i) != 0x00
                n_bytes_without_zeros = i
                break
            end
        end

        result = Array{UInt8}(undef, n_bytes_without_zeros)

        for i in 1:n_bytes_without_zeros
            @inbounds result[i] = unsafe_load(uint8_ptr, i)
        end
    end
    return result
end

"""
    Int(x::Vector{UInt8}; little_endian::Bool)
    -> Integer

Convert a Vector{UInt8} to an Integer
"""
function Core.Int(x::Vector{UInt8}; little_endian::Bool=false)
    if length(x) > 8
        big(x)
    else
        missing_zeros = div(Sys.WORD_SIZE, 8) -  length(x)
        if missing_zeros > 0
            if little_endian
                for i in 1:missing_zeros
                    push!(x,0x00)
                end
            else
                for i in 1:missing_zeros
                    pushfirst!(x,0x00)
                end
            end
        end
        if ENDIAN_BOM == 0x04030201 && little_endian
        elseif ENDIAN_BOM == 0x04030201 || little_endian
            reverse!(x)
        end
        return reinterpret(Int, x)[1]
    end
end

"""
    Base.big(x::Vector{UInt8}) -> BigInt

Convert a Vector{UInt8} to a BigInt
"""
function Base.big(x::Vector{UInt8})
    hex = bytes2hex(x)
    return parse(BigInt, hex, base=16)
end

end # module
