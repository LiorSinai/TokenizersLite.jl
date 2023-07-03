using Test
using TokenizersLite
using TokenizersLite: encode_corpus, WordEncoding, count_tokens, count_all_pairs!, score_pairs, update!
using TokenizersLite: decode
using DataStructures: DefaultDict

@testset "count pairs" verbose=true begin
    @testset "1 of each" begin
        vocab = DefaultDict{Union{String, Tuple{String, String}}, Int, Int}(
            0, 
            Dict{Union{String, Tuple{String, String}}, Int}(
              "⋅a" => 2,
              "##b" => 3
            )
        )
        corpus = Dict(
            "abb"  => WordEncoding(1, ["⋅a", "##b", "##b"]),
            "ab" => WordEncoding(1, ["⋅a", "##b"]),
        )
        count_all_pairs!(corpus, vocab)
        expected_vocab = Dict(
            "⋅a" => 2,
            "##b" => 3,
            ("##b", "##b") => 1,
            ("⋅a", "##b") => 2
        )
        @test expected_vocab == vocab
    end

    @testset "different counts" begin
        vocab = DefaultDict{Union{String, Tuple{String, String}}, Int, Int}(
            0, 
            Dict{Union{String, Tuple{String, String}}, Int}(
              "⋅a" => 4,
              "##b" => 5
            )
        )
        corpus = Dict(
            "abb"  => WordEncoding(1, ["⋅a", "##b", "##b"]),
            "ab" => WordEncoding(3, ["⋅a", "##b"]),
        )
        count_all_pairs!(corpus, vocab)
        expected_vocab = Dict(
            "⋅a" => 4,
            "##b" => 5,
            ("##b", "##b") => 1,
            ("⋅a", "##b") => 4
        )
        @test expected_vocab == vocab
    end
    
    @testset "overlapping pairs" begin
        vocab = DefaultDict{Union{String, Tuple{String, String}}, Int, Int}(
            0, 
            Dict{Union{String, Tuple{String, String}}, Int}(
              "⋅m" => 1,
              "##o" => 4,
              "##n" => 1,
            )
        )
        corpus = Dict(
            "moooon"  => WordEncoding(1, ["⋅m", "##o", "##o", "##o", "##o", "##n"]),
        )
        # count_all_pairs!(corpus, vocab)
        expected_vocab = Dict(
            "⋅m" => 1,
            "##o" => 4,
            "##n" => 1,
            ("##m", "##o") => 1,
            ("##o", "##o") => 4,
            ("##o", "##n") => 1
        )
        @test expected_vocab == vocab skip=true 
    end
end

@testset "merge pairs" verbose=true begin
    @testset "1 of each" begin
        vocab = DefaultDict{Union{String, Tuple{String, String}}, Int, Int}(
            0, 
            Dict{Union{String, Tuple{String, String}}, Int}(
                "⋅a" => 2,
                "##b" => 3,
                ("##b", "##b") => 1,
                ("⋅a", "##b") => 2
            )
        )
        corpus = Dict(
            "abb"  => WordEncoding(1, ["⋅a", "##b", "##b"]),
            "ab" => WordEncoding(1, ["⋅a", "##b"]),
        )

        update!(("⋅a", "##b"), vocab, corpus);    

        expected_vocab = DefaultDict{Union{String, Tuple{String, String}}, Int, Int}(
            0, 
            Dict{Union{String, Tuple{String, String}}, Int}(
                "⋅a" => 0,
                "##b" => 1,
                "⋅ab" => 2,
                ("##b", "##b") => 0,
                ("⋅ab", "##b") =>1,
            )
        )
        expected_corpus = Dict(
            "abb" => WordEncoding(1, ["⋅ab", "##b"]),
            "ab"  => WordEncoding(1, ["⋅ab"])
        )
        @test vocab == expected_vocab
        @test corpus == expected_corpus
    end

    @testset "different counts" begin
        vocab = DefaultDict{Union{String, Tuple{String, String}}, Int, Int}(
            0, 
            Dict{Union{String, Tuple{String, String}}, Int}(
              "⋅a" => 4,
              "##b" => 5,
              ("##b", "##b") => 1,
              ("⋅a", "##b") => 4,
            )
        )
        corpus = Dict(
            "abb"  => WordEncoding(1, ["⋅a", "##b", "##b"]),
            "ab" => WordEncoding(3, ["⋅a", "##b"]),
        )

        update!(("⋅a", "##b"), vocab, corpus);   

        expected_vocab = DefaultDict{Union{String, Tuple{String, String}}, Int, Int}(
            0, 
            Dict{Union{String, Tuple{String, String}}, Int}(
                "⋅a" => 0,
                "##b" => 1,
                "⋅ab" => 4,
                ("##b", "##b") => 0,
                ("⋅ab", "##b") =>1,
            )
        )
        expected_corpus = Dict(
            "abb" => WordEncoding(1, ["⋅ab", "##b"]),
            "ab"  => WordEncoding(3, ["⋅ab"])
        )
        @test vocab == expected_vocab
        @test corpus == expected_corpus
    end
    
    @testset "overlapping pairs" begin
        vocab = DefaultDict{Union{String, Tuple{String, String}}, Int, Int}(
            0, 
            Dict{Union{String, Tuple{String, String}}, Int}(
              "⋅m" => 1,
              "##o" => 4,
              "##n" => 1,
              ("⋅m", "##o") => 1,
              ("##o", "##o") => 3,
              ("##o", "##n") => 2,
            )
        )
        corpus = Dict(
            "moooon"  => WordEncoding(1, ["⋅m", "##o", "##o", "##o", "##o", "##n"]),
        )

        #update!(("##o", "##o"), vocab, corpus)

        expected_vocab = Dict(
            "⋅m" => 1,
            "##o" => 0,
            "##n" => 1,
            "##oo" => 2,
            ("⋅m", "##o") => 0,
            ("⋅m", "##oo") => 1,
            ("##oo", "##oo") => 2,
            ("##o", "##n") => 0,
            ("##oo", "##n") => 0,
        )
        expected_corpus = Dict(
            "moooon"  => WordEncoding(1, ["⋅m", "##oo", "##oo","##n"]),
        )
        @test vocab == expected_vocab skip=true
        @test corpus == expected_corpus skip=true
    end
end

hugging_face_words = Dict(
    "huggingface" => 1,
    "hugging" => 1,
    "face" => 1,
    "hug" => 1,
    "hugger" => 1,
    "learning" => 2,
    "learner" => 2,
    "learners" => 2,
    "learn" => 1,
)
hugging_face_symbols = [
    "##n", "##f", "##h", "##i", "##r", "##a", "##c", "##u", "##e", "##s", 
    "##g", "##l", 
    "⋅n", "⋅f", "⋅h", "⋅i", "⋅r", "⋅a", "⋅c", "⋅u", "⋅e", "⋅s", 
    "⋅g", "⋅l"
]
hugging_face_corpus = Dict(
    "learner"     => WordEncoding(2, ["⋅l", "##e", "##a", "##r", "##n", "##e", "##r"]),
    "hugger"      => WordEncoding(1, ["⋅h", "##u", "##g", "##g", "##e", "##r"]),
    "face"        => WordEncoding(1, ["⋅f", "##a", "##c", "##e"]),
    "hug"         => WordEncoding(1, ["⋅h", "##u", "##g"]),
    "learners"    => WordEncoding(2, ["⋅l", "##e", "##a", "##r", "##n", "##e", "##r", "##s"]),
    "huggingface" => WordEncoding(1, ["⋅h", "##u", "##g", "##g", "##i", "##n", "##g", "##f", "##a", "##c", "##e"]),
    "hugging"     => WordEncoding(1, ["⋅h", "##u", "##g", "##g", "##i", "##n", "##g"]),
    "learn"       => WordEncoding(1, ["⋅l", "##e", "##a", "##r", "##n"]),
    "learning"    => WordEncoding(2, ["⋅l", "##e", "##a", "##r", "##n", "##i", "##n", "##g"]),
)


@testset "HuggingFace step by step" begin
    words = deepcopy(hugging_face_words)
    symbols = deepcopy(hugging_face_symbols)
    corpus = deepcopy(hugging_face_corpus)

    bpe = BytePairEncoder(symbols, startsym="⋅", endsym=nothing)
   
    expected_vocab = Dict(
        "##e" => 14, 
        "##r" => 12, 
        "##g" => 11, 
        "##n" => 11, 
        "##a" => 9, 
        "⋅l" => 7, 
        "##i" => 4, 
        "⋅h" => 4, 
        "##u" => 4, 
        "##s" => 2,
        "##c" => 2, 
        "⋅f" => 1, 
        "##f" => 1, 
    )
    vocab = count_tokens(corpus)
    @test vocab == expected_vocab

    count_all_pairs!(corpus, vocab)
    expected_pairs = Dict(
        ("⋅l", "##e") => 7,
        ("##r", "##n") => 7,
        ("##e", "##a") => 7,
        ("##a", "##r") => 7,
        ("##e", "##r") => 5,
        ("##u", "##g") => 4,
        ("##n", "##e") => 4,
        ("⋅h", "##u") => 4,
        ("##n", "##g") => 4,
        ("##i", "##n") => 4,
        ("##g", "##g") => 3,
        ("##n", "##i") => 2,
        ("##a", "##c") => 2,
        ("##r", "##s") => 2,
        ("##c", "##e") => 2,
        ("##g", "##i") => 2,
        ("##g", "##f") => 1,
        ("##g", "##e") => 1,
        ("⋅f", "##a") => 1,
        ("##f", "##a") => 1,
    )
    expected_vocab = merge(expected_vocab, expected_pairs)
    @test vocab == expected_vocab

    scores = score_pairs(vocab);
    pair = argmax(scores)
    expected_pairs = [("⋅l", "##e"),("##r", "##n"),("##e", "##a"),("##a", "##r")]
    @test pair in expected_pairs

    pair = ("⋅l", "##e")
    update!(pair, vocab, corpus);

    @test vocab[("⋅l", "##e")] == 0
    @test vocab["⋅l"] == 0
    @test vocab["##e"] == 7
    @test vocab["⋅le"] == 7
    @test corpus["learner"] == WordEncoding(2, ["⋅le", "##a", "##r", "##n", "##e", "##r"])
    @test corpus["learners"] == WordEncoding(2, ["⋅le", "##a", "##r", "##n", "##e", "##r", "##s"])
    @test corpus["learn"] == WordEncoding(1, ["⋅le", "##a", "##r", "##n"])
    @test corpus["learning"] == WordEncoding(2, ["⋅le", "##a", "##r", "##n", "##i", "##n", "##g"])
end

@testset "HuggingFace 5 iters" begin
    words = deepcopy(hugging_face_words)
    symbols = deepcopy(hugging_face_symbols)
    corpus = deepcopy(hugging_face_corpus)

    bpe, vocab, corpus = learn_bpe(symbols, words, startsym="⋅", 5)

    expected_vocab = Dict(
        "##g" => 11,
        "⋅learn" => 7,
        "##er" => 5,
        "⋅h" => 4,
        "##n" => 4,
        "##i" => 4,
        "##c" => 2,
        "##e" => 2,
        "##a" => 2,
        "##f" => 1,
        "##u" => 4,
        "⋅f" => 1,
        "##s" => 2
        )
    expected_corpus = Dict(
        "learner"     => WordEncoding(2, ["⋅learn", "##er"]),
        "hugger"      => WordEncoding(1, ["⋅h", "##u", "##g", "##g", "##er"]),
        "face"        => WordEncoding(1, ["⋅f", "##a", "##c", "##e"]),
        "hug"         => WordEncoding(1, ["⋅h", "##u", "##g"]),
        "learners"    => WordEncoding(2, ["⋅learn", "##er", "##s"]),
        "huggingface" => WordEncoding(1, ["⋅h", "##u", "##g", "##g", "##i", "##n", "##g", "##f", "##a", "##c", "##e"]),
        "hugging"     => WordEncoding(1, ["⋅h", "##u", "##g", "##g", "##i", "##n", "##g"]),
        "learn"       => WordEncoding(1, ["⋅learn"]),
        "learning"    => WordEncoding(2, ["⋅learn", "##i", "##n", "##g"]),
    )
    expected_rules = [
        ("⋅l", "##e"),
        ("##r", "##n"),
        ("⋅le", "##a"),
        ("⋅lea", "##rn"),
        ("##e", "##r"),
    ]

    @test vocab == expected_vocab
    @test corpus == expected_corpus 
    @test bpe.rules == expected_rules 
end

@testset "HuggingFace 49 iters" verbose=true begin
    words = deepcopy(hugging_face_words)
    symbols = deepcopy(hugging_face_symbols)
    corpus = deepcopy(hugging_face_corpus)

    bpe, vocab, corpus = learn_bpe(symbols, words, startsym="⋅", 49)

    expected_vocab = Dict(
        "⋅huggingface" => 1,
        "⋅hugging" => 1,
        "⋅face" => 1,
        "⋅hug" => 1,
        "⋅hugger" => 1,
        "⋅learning" => 2,
        "⋅learner" => 2,
        "⋅learners" => 2,
        "⋅learn" => 1,
    )
    expected_corpus = Dict(
        "learner"     => WordEncoding(2, ["⋅learner"]),
        "hugger"      => WordEncoding(1, ["⋅hugger"]),
        "face"        => WordEncoding(1, ["⋅face"]),
        "hug"         => WordEncoding(1, ["⋅hug"]),
        "learners"    => WordEncoding(2, ["⋅learners"]),
        "huggingface" => WordEncoding(1, ["⋅huggingface"]),
        "hugging"     => WordEncoding(1, ["⋅hugging"]),
        "learn"       => WordEncoding(1, ["⋅learn"]),
        "learning"    => WordEncoding(2, ["⋅learning"]),
    )

    @test vocab == expected_vocab
    @test corpus == expected_corpus 
end

@testset "encode" begin
    bpe = BytePairEncoder(
        ["⋅a", "⋅b", "##a", "##b", "##c", " "],
        [("##b", "##c"), ("⋅a", "##b"), ("##b", "##a"), ("##a", "##a"), ("⋅a", "##bc")],
        Dict{String, Vector{String}}(),
        "⋅",
        nothing,
        "[UNK]"
    )
    word = "abc"
    tokens = bpe(word)
    expected_tokens = ["⋅abc"]
    @test tokens == expected_tokens
    decoded = decode(bpe, tokens)
    @test decoded == word

    word = "abaa"
    tokens = bpe(word)
    expected_tokens = ["⋅ab", "##aa"]
    @test tokens == expected_tokens
    decoded = decode(bpe, tokens)
    @test decoded == word

    word = "aba!bc"
    tokens = bpe(word)
    expected_tokens = ["⋅ab", "##a", "[UNK]", "##bc"]
    @test tokens == expected_tokens
    decoded = decode(bpe, tokens)
    @test decoded == "aba[UNK]bc"

    word = "aba bc"
    tokens = bpe(word)
    expected_tokens = ["⋅ab", "##a", " ", "##bc"]
    @test tokens == expected_tokens
    decoded = decode(bpe, tokens)
    @test decoded == "aba bc"

    word = "bcca"
    tokens = bpe(word)
    expected_tokens = ["⋅b", "##c", "##c", "##a"]
    @test tokens == expected_tokens
    decoded = decode(bpe, tokens)
    @test decoded == word
end
