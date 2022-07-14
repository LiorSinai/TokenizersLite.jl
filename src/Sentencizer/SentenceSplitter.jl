abstract type SentenceSplitter end

"""
    RuleBasedSentenceSplitter()
    RuleBasedSentenceSplitter(non_breaking_prefixes, non_breaking_numeric_prefixes)

Rule based Sentence Boundary Detection. 
Inspired by https://github.com/mediacloud/sentence-splitter
For English only and works on non-standard grammar e.g. no capital letters.
"""
struct RuleBasedSentenceSplitter <: SentenceSplitter
    non_breaking_prefixes::Set{String}
    non_breaking_numeric_prefixes::Set{String}
end

function RuleBasedSentenceSplitter()
    prefixes = get_default_non_breaking_prefixes()
    numeric_prefixes = get_default_non_breaking_numeric_prefixes()
    RuleBasedSentenceSplitter(prefixes, numeric_prefixes)
end

function Base.show(io::IO, splitter::RuleBasedSentenceSplitter)
    print(io, "RuleBasedSentenceSplitter(")
    print(io, "non_breaking_prefixes=")
    print(io, splitter.non_breaking_prefixes)
    print(io, ", non_breaking_numeric_prefixes=")
    print(io, splitter.non_breaking_numeric_prefixes)
    print(io, ")")
end

function (splitter::RuleBasedSentenceSplitter)(text::String)
    split_sentences(splitter, text)
end

"""
    split_sentences(splitter, text)

Split text into sentences using rule based Sentence Boundary Detection. 
"""
function split_sentences(splitter::RuleBasedSentenceSplitter, text::String)
    text = pattern_splits(text)

    # periods
    words = split(text, r" +")
    text = ""
    for i in 1:(length(words) - 1)
        m = match(r"([\w\.\-]*)(['\"\({Pf}]*)(\.+)$", words[i])
        if !isnothing(m)
            prefix = m.captures[1]
            starting_punct = m.captures[2]

            if is_prefix_honorific(prefix, starting_punct, splitter.non_breaking_prefixes)
                # non-breaking prefix
            elseif !isnothing(match(r"(\w\.)(\w\.)+$", words[i]))
                # acronym
            elseif !isnothing(match(r"^(['\"\(\p{Pi}]*\w)", words[i + 1]))
                if !is_numeric(prefix, starting_punct, splitter.non_breaking_numeric_prefixes, words[i + 1])
                    words[i] = words[i] * "\n"
                end
            end
        end
        text = text * words[i] * " "
    end

    # We stopped one token from the end
    text = text * last(words)

    # Clean up spaces at head and tail of each line as well as any double-spacing
    text = replace(text, r" +" => s" ")
    text = replace(text, r"\n " => s"\n")
    text = replace(text, r" \n" => s"\n")
    text = strip(text)

    split(text, "\n")
end

function pattern_splits(text::String)
    # Non-period end of sentence punctuation followed by sentence starters
    text = replace(text, r"([?!;]) +(['\"\p{Ps}\p{Pi}]*\w)" => s"\g<1>\n\g<2>")

    # multiple periods followed by sentence starters
    text = replace(text, r"(\.\.+) +(['\"\p{Ps}\p{Pi}]*\w)" => s"\g<1>\n\g<2>")

    # Sentences at end of quotes or brackets followed by sentence starters
    text = replace(text, r"([.?!;] *['\"\p{Pe}\p{Pf}]+) +(['\"\p{Ps}\p{Pi}]*\w)" => s"\g<1>\n\g<2>")

    # Period followed by start punctuation
    text = replace(text, r"(\.) +(['\"\p{Ps}\p{Pi}]+\w)" => s"\g<1>\n\g<2>")

    text
end

function is_prefix_honorific(
    prefix::SubString{String}, 
    starting_punct::SubString{String}, 
    non_breaking_prefixes::Set{String}
    )
    # Check if prefix is known and starting_punct is empty
    if prefix != ""
        if prefix in non_breaking_prefixes
            if starting_punct == ""
                return true
            end
        end
    end
    return false
end

function is_numeric(
    prefix::SubString{String}, 
    starting_punct::SubString{String}, 
    non_breaking_prefixes::Set{String},
    next_word::SubString{String}
    )
    # Check if prefix is known and starting_punct is empty and it is followed by a number
    if prefix != ""
        if prefix in non_breaking_prefixes
            if starting_punct == ""
                if !isnothing(match( r"^[0-9]+", next_word))
                    return true
                end
            end
        end
    end
    return false
end

"""
    SimpleSentenceSplitter()

Very simple Sentence Boundary Detection using a single regex pattern. Does not work for acronyms or abbreviations.
""" 
struct SimpleSentenceSplitter <: SentenceSplitter
end

function split_sentences(splitter::SimpleSentenceSplitter, text::String)
    # End of sentence punctuation followed by sentence starters
    text = replace(text, r"([.?!;]) +(['\"\p{Ps}\p{Pi}]*\w)" => s"\g<1>\n\g<2>")
    split(text, "\n")
end

function (splitter::SimpleSentenceSplitter)(text::String)
    split_sentences(splitter, text)
end