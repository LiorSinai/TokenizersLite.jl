module TokenizersLite

using DataStructures
import Base.show
import Base.similar
import Base.==

struct WordEncoding
    frequency::Int
    tokens::Vector{String}
end

==(w1::T, w2::T) where T <: WordEncoding = (w1.frequency == w2.frequency) && (w1.tokens == w2.tokens)

abstract type AbstractTokenizer end

include("utilities.jl")
include("count_words.jl")

include("BytePairEncoding/BytePairEncoder.jl")
include("BytePairEncoding/learn.jl")
include("BytePairEncoding/persist.jl")

export BytePairEncoder, encode
export learn_bpe
export load_bpe, save_bpe, save_vocab, save_encodings

include("AffixTokenization/AffixTokenizer.jl")
include("AffixTokenization/trim_vocab.jl")
include("AffixTokenization/persist.jl")
include("AffixTokenization/affixes.jl")

export AffixTokenizer, match_prefix, match_suffix, match_affixes
export load_affix_tokenizer
export trim_vocab

include("Sentencizer/SentenceSplitter.jl")
include("Sentencizer/non_breaking_prefixes.jl")
export RuleBasedSentenceSplitter, split_sentences

end
