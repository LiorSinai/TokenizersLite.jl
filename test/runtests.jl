using Test
using TokenizersLite

@testset "sentence splitting" verbose=true begin
    include("split_sentences.jl")
end

@testset "byte pair encoding" verbose=true begin
    include("byte_pair_encoding.jl")
end
;