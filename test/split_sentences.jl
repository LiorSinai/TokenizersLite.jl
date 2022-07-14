using Test
using TokenizersLite: RuleBasedSentenceSplitter, split_sentences


@testset "basic" begin
    splitter = RuleBasedSentenceSplitter()

    text = "This is a sentence. This is another one. And another."
    expected = ["This is a sentence.", "This is another one.", "And another."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "A good question is \"Where do you start?\". It can be hard to tell."
    expected = ["A good question is \"Where do you start?\".", "It can be hard to tell."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "I laughed. \"How did you think of that?\", I asked."
    expected = ["I laughed.", "\"How did you think of that?\", I asked."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "Outer sentence. (A sentence. (Inner sentence.))) End."
    expected = ["Outer sentence.", "(A sentence.", "(Inner sentence.)))", "End."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "Hey ... Stop it!"
    expected = ["Hey ...", "Stop it!"]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "this product is awful!!! just dont use it."
    expected = ["this product is awful!!!", "just dont use it."]
    result = split_sentences(splitter, text)
    @test result == expected
end;

@testset "numbers" begin
    splitter = RuleBasedSentenceSplitter()

    text = "This is a list. 1. item. 2. item. 3. item."
    expected = ["This is a list.", "1.", "item.", "2.",  "item.", "3.", "item."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "This cost me \$3.61. The other one is cheaper."
    expected = ["This cost me \$3.61.", "The other one is cheaper."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "I have \$10.50 in my wallet."
    expected = ["I have \$10.50 in my wallet."]
    result = split_sentences(splitter, text)
    @test result == expected
end;

@testset "non-breaking prefixes" begin
    splitter = RuleBasedSentenceSplitter()

    text = "Mr. J. Smith is always very helpful."
    expected = ["Mr. J. Smith is always very helpful."]
    result = split_sentences(splitter, text)
    @test result == expected
    
    text = "I enjoyed the Great Gatsby by F. Scott Fitzgerald."
    expected = ["I enjoyed the Great Gatsby by F. Scott Fitzgerald."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "He lives at No. 10 Downing Street."
    expected = ["He lives at No. 10 Downing Street."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "Go choose another one. Eg. the blue one."
    expected = ["Go choose another one.", "Eg. the blue one."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "X.Y.Z Stores are the best."
    expected = ["X.Y.Z Stores are the best."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "I work for the U.S. Government."
    expected = ["I work for the U.S. Government."]
    result = split_sentences(splitter, text)
    @test result == expected
end;

@testset "breaking prefixes" begin
    splitter = RuleBasedSentenceSplitter()

    text = "No. I said no. Stop."
    expected = ["No.", "I said no.", "Stop."]
    result = split_sentences(splitter, text)
    @test result == expected

    text = "I just got a new iPhone X. It is great!"
    expected = ["I just got a new iPhone X.", "It is great!"]
    result = split_sentences(splitter, text)
    @test_broken result == expected

    text = "I work at Apple Ltd. I've been there for 5 years."
    expected = ["I work at Apple Ltd.", "I've been there for 5 years."]
    result = split_sentences(splitter, text)
    @test_broken result == expected
end;
