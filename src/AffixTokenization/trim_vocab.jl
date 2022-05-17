function encode_corpus(vocab::Dict)
    tokenized_corpus = Dict{String, WordEncoding}()
    for key in keys(vocab)
        tokenized_corpus[key] = WordEncoding(vocab[key], [key])
    end
    tokenized_corpus
end

function trim_vocab(vocab::Dict, prefixes::Vector, suffixes::Vector)
    corpus = encode_corpus(vocab)
    vocab = DefaultDict(0, vocab)
    protected = Set{String}()
    println("Starting trim with $(length(vocab)) words")
    for (i, word) in enumerate(sort(collect(keys(corpus)), by=x->length(x), rev=true))
        if word in protected
            continue # another word has been split into this word
        end
        prefix, suffix, candidate = match_affixes(word, prefixes, suffixes, keys(vocab))
        if (prefix != "") || (suffix != "")
            vocab[candidate] += corpus[word].frequency
            push!(protected, candidate)
            delete!(vocab, word)
            tokens = []
            if prefix != ""
                push!(tokens, prefix)
                vocab[prefix] += corpus[word].frequency
            end
            push!(tokens, candidate)
            if suffix != ""
                push!(tokens, suffix)
                vocab[suffix] += corpus[word].frequency
            end
            corpus[word] = WordEncoding(corpus[word].frequency, tokens)
        end
    end
    num_affixes = count(s->startswith(s[1], "-") || endswith(s[1], "-"), vocab)
    println("Ending trim with $(length(vocab)) words including $num_affixes affixes")
    Dict(vocab), corpus
end


function trim_vocab(vocab::Dict)
    prefixes, suffixes = get_default_affixes()
    trim_vocab(vocab, prefixes, suffixes)
end
      