import Base.show

struct AffixTokenizer <: AbstractTokenizer
    prefixes::Vector{String}
    suffixes::Vector{String}
    vocab::Set{String}
end

AffixTokenizer() = AffixTokenizer(String[], String[], Set{String}())

function Base.show(io::IO, tokenizer::AffixTokenizer)
    print(io, "AffixTokenizer(length(vocab)=$(length(tokenizer.vocab))")
    print(io, ", prefixes=$(tokenizer.prefixes)")
    print(io, ", suffixes=$(tokenizer.suffixes)")
    print(io, ")")
end

"""
    (tokenizer::AffixTokenizer{T})(x)

Encode the given data using grammar rules for prefixes and suffixes. 
"""
function (tokenizer::AffixTokenizer)(x)
    encode(tokenizer, x)
end

"""
    encode(tokenizer::AffixTokenizer, x)

Encode the given data using grammar rules for prefixes and suffixes.
"""
function encode(tokenizer::AffixTokenizer, word::AbstractString)
    if word in tokenizer.vocab
        return [word]
    end
    prefix, suffix, candidate = match_affixes(word, tokenizer.prefixes, tokenizer.suffixes, tokenizer.vocab)
    tokens = String[]
    if prefix != ""
        push!(tokens, prefix)
    end
    push!(tokens, candidate)
    if suffix != ""
        push!(tokens, suffix)
    end
    tokens
end

function encode(tokenizer::AffixTokenizer, seq::Vector{T}) where T
    tokens = T[]
    for word in seq
        push!(tokens, encode(tokenizer, word)...)
    end
    tokens
end

function match_affixes(
    word::AbstractString, 
    prefixes::Vector, 
    suffixes::Vector,
    vocab    
    )
    candidate = word
    for p in sort(prefixes, by=x->(length(x), x), rev=true)
        matched, candidate = match_prefix(candidate, p, vocab)
        if matched 
            prefix = p * "-"
            return prefix, "", candidate
        end
    end
    for s in sort(suffixes, by=x->(length(x), x), rev=true)
        matched, candidate = match_suffix(candidate, s, vocab)
        if matched
            suffix = "-" *  s
            return  "", suffix, candidate
        end
    end
    "", "", candidate
end

function match_prefix(word::AbstractString, prefix::AbstractString, vocab; min_length::Int=3)
    if startswith(word, prefix)
        candidate = chop(word, head=length(prefix), tail=0)
        if (length(candidate) < min_length) || !(candidate in vocab) 
            return false, word
        end
        return true, candidate
    end 
    false, word
end

function match_suffix(word::AbstractString, suffix::AbstractString, vocab; min_length::Int=3)
    if endswith(word, suffix)
        for candidate in suffix_rules(word, suffix)
            if (length(candidate) < min_length) || !(candidate in vocab)
                continue
            end
            return true, candidate
        end
    end 
    false, word
end

function decode(tokenizer::AffixTokenizer, tokens::Vector{String})
    sentence = ""
    for (idx, token) in enumerate(tokens)
        if startswith(token, "-")
            sentence = suffix_reverse_rules(sentence, token[2:end])
        elseif endswith(token, "-")
            sentence *= chop(token, head=0, tail=1)
        else
            sentence *= token
        end
    end
    sentence
end

function suffix_rules(word::AbstractString, suffix::AbstractString)
    candidate = chop(word, head=0, tail=length(suffix))
    if length(candidate) < 3
        return [candidate]
    end
    if suffix[1] == 'e' && candidate[end] == 'i'
        # y->i e.g. apply->applied, berry->berries, candy->candies
        candidate = candidate[1:end-1] * "y"
    elseif suffix[1] in ['e', 'i'] && (candidate[end] == candidate[end - 1]) &&
        (candidate[end] in ['b', 'g', 'l', 'm', 'n', 'p', 'r', 't', 'v'])
        # short vowel with double consonant, e.g. big->bigger, hot->hottest, pup->puppies 
        # confuses: butter->but, better->bet-er, manner->man-er, matter->mat-er, pennies->pen-ies, summer->sum-er, 
        candidate = candidate[1:end-1] 
    elseif (suffix[1] in ['e', 'i']) && (suffix[end] != 's')  &&
        (candidate[end] in ['c', 'd', 'g', 'k', 'l', 'm', 'n', 'p', 's', 'r', 't', 'v', 'z'])
        # drop i e.g. activate->activating, bubble->bubbling, live->living
        # or merge e e.g: assume->assumed, bake->baked, bake->baker, complete->completed
        # confuses: cones->con-es, meter->met-er, sites->sit-es
        return [candidate * "e", candidate] 
    end
    [candidate]
end

function suffix_reverse_rules(word::AbstractString, suffix::AbstractString)
    if length(word) < 3
        return [word]
    end
    if suffix[1] == 'e' && word[end] == 'y'
        # y-> i e.g. apply-ed -> applied, berry-es -> berries, candy-es -> candies
        new_word = chop(word, tail=1) * "i" * suffix
        return new_word
    elseif suffix[1] in ['e', 'i'] && (word[end] in ['b', 'g', 'l', 'm', 'n', 'p', 'r', 't', 'v'])
        # short vowel with double consonant, e.g. big-er -> bigger, hot-est -> hottest, pup-ies -> puppies
        new_word = word * word[end] * suffix 
        return new_word 
    elseif (length(suffix) > 1) && (suffix[1] == word[end] == 'e')
        # merge e e.g: assume-ed->assume, bake-ed -> baked, bake-er -> baker, complete-ed -> completed
        return word * suffix[2:end]
    elseif (length(word) > 1) && (suffix[1] == 'i' && word[end] == 'e')
        # drop e e.g. activate-ing -> activating, bubble-ing -> bubbling, live-ing -> living
        return word[1:end-1] * suffix
    end
    word * suffix
end
