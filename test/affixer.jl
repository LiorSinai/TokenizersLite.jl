using Test
using TokenizersLite
using TokenizersLite: decode

prefixes, suffixes = TokenizersLite.get_default_affixes()
vocab = Set([
    "age",
    "bake",
    "big",
    "box",
    "bubble",
    "cap",
    "candy",
    "cell",
    "lucky",
    "possible",
    "pup",
    "stop",
    ])
affixer = AffixTokenizer(prefixes, suffixes, vocab)

@testset "prefixes" begin
    word = "image"
    tokens = affixer(word)
    expected_tokens = ["im-", "age"]
    @test tokens == expected_tokens

    word = "impossible"
    tokens = affixer(word)
    expected_tokens = ["im-", "possible"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word

    word = "united"
    tokens = affixer(word)
    expected_tokens = ["united"]
    @test tokens == expected_tokens

    word = "unlucky"
    tokens = affixer(word)
    expected_tokens = ["un-", "lucky"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word
end

@testset "suffixes" begin
    word = "cells"
    tokens = affixer(word)
    expected_tokens = ["cell", "-s"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word

    word = "bigger"
    tokens = affixer(word)
    expected_tokens = ["big", "-er"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word

    word = "puppies"
    tokens = affixer(word)
    expected_tokens = ["pup", "-ies"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word

    word = "candies"
    tokens = affixer(word)
    expected_tokens = ["candy", "-es"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word

    word = "baked"
    tokens = affixer(word)
    expected_tokens = ["bake", "-ed"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word

    word = "bakes"
    tokens = affixer(word)
    expected_tokens = ["bake", "-s"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word

    word = "bubbling"
    tokens = affixer(word)
    expected_tokens = ["bubble", "-ing"]
    @test tokens == expected_tokens
    decoded = decode(affixer, tokens)
    @test decoded == word
end

@testset "prefix + suffix" begin
    word = "unboxed"
    tokens = affixer(word)
    expected_tokens = ["un-", "box", "-ed"]
    @test_broken tokens == expected_tokens
end
