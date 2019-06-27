# BitConverter.jl

Converts base data types to an array of bytes, and an array of bytes to base
data types.
So far Integer only are implemented.

## Functions

```@docs
bytes(x::Integer; len::Integer, little_endian::Bool)
big(x::Vector{UInt8})
Int(x::Vector{UInt8}; little_endian::Bool)
```

## Examples

```julia
julia> bytes(big(2)^32)
5-element Array{UInt8,1}:
 0x01
 0x00
 0x00
 0x00
 0x00
```

```julia
julia> x = rand(UInt8, 8)
8-element Array{UInt8,1}:
 0xd3
 0x82
 0x42
 0xa7
 0xd8
 0x2b
 0xd0
 0xc5

julia> big(x)
15240817377628901573

julia> Int(rand(UInt8, 2))
48868

julia> Int(rand(UInt8, 8))
-3411029373876830527
```

## Buy me a cup of coffee

[Donate Bitcoin](bitcoin:1786ytdyKz1TJgpVM34DKDB85eEQkvwgjo)

## Index

```@index
```
