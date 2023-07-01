
using DataFrames
using Arrow
using Printf
using TokenizersLite
using TokenizersLite: load_vocab

path = "path\\to\\amazon_reviews_multi\\en\\1.0.0\\"
filename = "amazon_reviews_multi-train.arrow"

checksum = readdir(path)[1]
filepath = joinpath(path, checksum, filename)

df = DataFrame(Arrow.Table(filepath))
pattern = r"[A-Za-z][A-Za-z]+\b"
transform!(df, :review_body =>  ByRow(s -> length(s)) => :review_length);transform!(df, :review_body =>  ByRow(s -> length(findall(pattern, s))) => :review_word_count);
transform!(df, :review_body =>  ByRow(s -> length(s)) => :review_length);

## Bytpe Pair Encoding
directory = "outputs\\bpe"
path_rules = joinpath(directory, "amazon_reviews_train_en_rules.txt")
path_vocab = joinpath(directory, "amazon_reviews_train_en_vocab.txt")
vocab = load_vocab(path_vocab)
bpe = load_bpe(path_rules, startsym="⋅")

## AffixTokenizer
directory = "outputs/affixes"
path_vocab = joinpath(directory, "amazon_reviews_train_en_vocab.txt")
affixer = load_affix_tokenizer(path_vocab)

# examples
idx = 400
# idx = argmax(df[:, :review_length])
println(idx)

print("original: ")
document = df[idx, "review_body"]
println(document)
println("")

print("processed: ")
document = TokenizersLite.preprocess(document) 
println(document)
println("")

print("words: ")
words = map(m->string(m.match), eachmatch(pattern, document))
println(join(words, "|"))
println("")

print("BPE tokens: ")
tokens = bpe(words)
println(join(tokens, "|"))
println("")

print("affixer tokens: ")
tokens = affixer(words)
println(join(tokens, "|"))
