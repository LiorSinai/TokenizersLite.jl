function count_word_frequencies(corpus; max_length::Int, pattern::Regex=r"\w\w+\b")
    word_counts = Dict{String, Tuple{Int, Int}}()
    print(repeat(" ", 100))
    update = Update(0, max_length, 0.01)
    for idx in 1:max_length
        update(idx)
        sentence = preprocess(corpus[idx])
        uniques = Set{String}()
        for idxs in findall(pattern, sentence)
            word = sentence[idxs]
            if haskey(word_counts, word)
                term_freq, doc_freq = word_counts[word]
                if !(word in uniques)
                    doc_freq += 1
                    push!(uniques, word)
                end
                word_counts[word] = (term_freq + 1, doc_freq)
            else
                word_counts[word] = (1, 1)
                push!(uniques, word)
            end
        end
    end
    println("")
    word_counts
end


function preprocess(s::AbstractString)
    s = lowercase(s)
    s = Unicode.normalize(s, :NFD)
    s = replace(s, r"['`’\u200d\p{M}]" => "") # contractions, zero width joiner and marks from normalization
    s = replace(s, r"[\p{P}\p{S}]+" => " ") # remove Punctuation and Symbols (maths + emojis)
    s = replace(s, r"\n" => " ")
end