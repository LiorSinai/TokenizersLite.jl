## Neural Machine Translation of Rare Words with Subword Units https://arxiv.org/abs/1508.07909
import Base.show

struct BytePairEncoder{T} <: AbstractTokenizer
    symbols::Vector{T}
    rules::Vector{Tuple{T, T}}
    cache::Dict{T, Vector{T}}
    startsym::Union{T, Nothing}
    endsym::Union{T, Nothing}
    unksym::T
end

alphabet = "abcdefghijklmnopqrstuvwxyz"
punctuation = ",.?!:;\$€£&"
default_symbols = sort(vcat(
    map(c-> string(c), collect(punctuation)),
    map(c-> "##" * string(c), collect(alphabet)),
    map(c-> "⋅" * string(c), collect(alphabet))
    ), by=x->length(x), rev=true)

BytePairEncoder() = BytePairEncoder(
    String[],
    Tuple{String, String}[], 
    Dict{String, Vector{String}}(),
    nothing,
    nothing,
    "[UNK]"
    )

BytePairEncoder(symbols;startsym="⋅", endsym=nothing, unksym="[UNK]") = BytePairEncoder(
    symbols,
    Tuple{String, String}[], 
    Dict{String, Vector{String}}(),
    startsym,
    endsym,
    unksym
    )

function Base.show(io::IO, bpe::BytePairEncoder{T}) where T
    print(io, "BytePairEncoder{$T}(")
    print(io, "length(rules)=$(length(bpe.rules))")
    print(io, ", length(cache)=$(length(bpe.cache))")
    print(io, ", unksym=$(bpe.unksym)")
    bpe.startsym === nothing || print(io, ", startsym=$(bpe.startsym)")
    bpe.endsym === nothing || print(io, ", endsym=$(bpe.endsym)")
    print(io, ", symbols=$(bpe.symbols)")
    print(io, ")")
end

"""
    (bpe)(x)

Encode the given data using the BPE rules. 
"""
function (bpe::BytePairEncoder{T})(x) where T
    encode(bpe, x)
end

"""
    encode(bpe, x)

Encode the given data using the BPE rules. ## indicates a substring token
"""
function encode(bpe::BytePairEncoder{T}, word::T) where T 
    if haskey(bpe.cache, word)
        tokens = bpe.cache[word]
    else
        tokens = init_encode(bpe, word)
        for pair in bpe.rules 
            update_tokens!(tokens, pair)
            if length(tokens) == 1
                break
            end
        end
        bpe.cache[word] = tokens
    end
    tokens
end

function encode(bpe::BytePairEncoder{T}, seq::Vector{T}) where T
    tokens = T[]
    for word in seq
        push!(tokens, encode(bpe, word)...)
    end
    tokens
end

"""
    similar(bpe)

Returns a similar BytePairEncoder with an empty cache with minimal size.
Use `empty!(bpe.cache)` if want to clear the cache without reducing the allocated memory. 
"""
function similar(bpe::BytePairEncoder)
    BytePairEncoder(
        bpe.symbols,
        bpe.rules, 
        Dict{String, Vector{String}}(),
        bpe.startsym,
        bpe.endsym,
        bpe.unksym
    )
end

function init_encode(bpe::BytePairEncoder{T}, word::AbstractString) where T
    tokens = map(c-> string(c), collect(word))
    if !isnothing(bpe.startsym)
        tokens[1] = bpe.startsym * tokens[1]
    end
    if !isnothing(bpe.endsym)
        tokens[end] = tokens[end] * bpe.endsym
    end
    for (idx, token) in enumerate(tokens)
        if !(token in bpe.symbols) 
            if ("##" * token in bpe.symbols)
                tokens[idx] = "##" * token
            else
                tokens[idx] = bpe.unksym
            end
        end
    end    
    tokens
end

function update_tokens!(tokens::Vector, pair::Tuple)
    new_token = merge_pair(pair)
    offset = 0
    for idx in 1:(length(tokens) - 1)
        i = idx + offset
        j = i + 1
        if ((tokens[i] == pair[1]) && (tokens[j] == pair[2]))
            tokens[j] = new_token
            deleteat!(tokens, i)
            offset -= 1
        end
    end
end

function merge_pair(pair::Tuple)
    if !startswith(pair[2], "##")
        throw("second ngram in $pair should start with ##")
    end
    pair[1] * pair[2][3:end]
end

function decode(bpe::BytePairEncoder{T}, tokens::Vector{String}) where T 
    sentence = ""
    for (idx, token) in enumerate(tokens)
        if token in bpe.symbols
            sentence *= token
        else
            if !isnothing(bpe.startsym) && startswith(token, bpe.startsym)
                head = 1
            elseif startswith(token, "##")
                head = 2
            else
                head = 0
            end
            if !isnothing(bpe.endsym) && endswith(token, bpe.endsym)
                tail = 1
            else
                tail = 0
            end
            if (head < 2) && (idx != 1) 
                sentence *= " "
            end
            sentence *= chop(token, head=head, tail=tail)
        end
    end
    sentence
end
