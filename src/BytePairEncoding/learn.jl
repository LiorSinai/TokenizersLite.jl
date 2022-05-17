function learn_bpe(
    symbols::Vector{T},
    word_counts::Dict{T, Int}, 
    nrules::Int;
    startsym::Union{T, Nothing}="⋅",
    endsym::Union{T, Nothing}=nothing,
    update_interval::Int = 100
    ) where T
    bpe = BytePairEncoder(symbols, startsym=startsym, endsym=endsym)

    purge_repeat_letters!(word_counts)
    corpus = encode_corpus(word_counts, bpe)
    vocab = count_tokens(corpus)
    count_all_pairs!(corpus, vocab)

    for i in 1:nrules
        scores = score_pairs(vocab);
        if isempty(scores)
            println("Breaking loop at i=$i. No more pairings left.")
            break
        end
        pair = argmax(scores)
        update!(pair, vocab, corpus);
        push!(bpe.rules, pair)
        if (i % update_interval) == 0
            println("$i $pair")
        end
    end
    audit(vocab, corpus)

    vocab_out = filter(x->x[1] isa String && x[2] > 0, vocab)
    bpe, Dict(vocab_out), corpus
end

function encode_corpus(corpus::Dict{T, Int}, bpe::BytePairEncoder{T}) where T
    tokenized_corpus = Dict{String, WordEncoding}()
    for (word, value) in corpus
        ts = init_encode(bpe, word)
        tokenized_corpus[word] = WordEncoding(value, ts)
    end
    tokenized_corpus
end

function count_tokens(corpus::Dict)
    vocab = DefaultDict{Union{String, Tuple{String, String}}, Int}(0)
    for (word, encoding) in corpus
        for token in encoding.tokens
            vocab[token] += encoding.frequency
        end
    end
    vocab
end

function count_all_pairs!(corpus::Dict, vocab::DefaultDict)
    for (word, encoding) in corpus
        idx = 0
        while idx < (length(encoding.tokens) - 1)
            idx += 1 
            ti = encoding.tokens[idx]
            tj =  encoding.tokens[idx + 1]
            vocab[(ti, tj)] += encoding.frequency
            if  idx < (length(encoding.tokens) - 1)
                tk = encoding.tokens[idx + 2]
                if (ti == tj == tk)
                    throw("Overlapping doubles $ti in $(word) not supported")
                end
            end
        end
    end
end

function score_pair(vocab::DefaultDict, pair::Tuple)
    vocab[pair]
end

function score_pairs(vocab::DefaultDict)
    scores = Dict{Tuple{String, String}, Float64}()
    for pair in keys(vocab)
        if pair isa String
            continue
        end
        scores[pair] = score_pair(vocab, pair)
    end
    scores
end

function update!(pair::Tuple, vocab::DefaultDict, corpus::Dict)
    new_pair = merge_pair(pair)
    Δ = 0
    for (word, encoding) in corpus
        length0 = length(encoding.tokens)
        update_tokens!(encoding.tokens, pair)
        if length0 != length(encoding.tokens) 
            Δ += update_vocab_counts!(vocab, pair, encoding) # update counts after merging in case of multiple merges
        end
    end
    @assert Δ == vocab[pair] "Δ=$Δ ↔ tokens[$pair]=$(vocab[pair])"
    vocab[new_pair] = vocab[pair]
    delete!(vocab, pair)
end

function update_vocab_counts!(vocab::DefaultDict, pair::Tuple, encoding::WordEncoding)
    Δ = 0 
    token = merge_pair(pair)
    ntokens = length(encoding.tokens)
    freq = encoding.frequency
    for idx in 1:ntokens
        if (encoding.tokens[idx] == token)
            Δ += freq
            vocab[pair[1]] -= freq
            vocab[pair[2]] -= freq
            if (idx > 1) && (encoding.tokens[idx - 1] != token) # doubles case handled below
                t_prev = encoding.tokens[idx - 1]
                vocab[(t_prev, token)] += freq
                vocab[(t_prev, pair[1])] -= freq
            end
            if (idx < ntokens) 
                t_next = encoding.tokens[idx + 1]
                vocab[(token, t_next)] += freq
                if  (token == t_next) 
                    vocab[(pair[2], pair[1])] -= freq # assumes pair[1] != pair[2]
                else
                    vocab[(pair[2], t_next)] -= freq               
                end
            end
        end # token
    end # idx
    Δ
end

function audit(vocab, corpus)
    vocab2 = count_tokens(corpus)
    count_all_pairs!(corpus, vocab2)
    for key in keys(vocab2)
        if !haskey(vocab, key)
            throw("$key missing from tokens")
        elseif  vocab2[key] != vocab[key]
            throw("Values do not match for key=$key: corpus→$(vocab2[key]), vocab→$(vocab[key])")
        end
    end
end

function purge_repeat_letters!(corpus::Dict; allowed_repeats=2)
    for word in keys(corpus)
        idx = 0
        while idx < length(word)
            repeats = 1
            idx += 1
            c = word[idx]
            while idx < length(word) && word[idx + 1] == c
                idx += 1
                repeats += 1
            end
            if repeats > allowed_repeats
                println("removing $word because of $repeats consecutive \'$c\'s")
                delete!(corpus, word)
            end
        end
    end
end
