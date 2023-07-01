using TokenizersLite
using TokenizersLite: encode_corpus, count_tokens, count_all_pairs!, score_pairs, update!, audit

words = Dict(
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

nrules = 30 # maximum is 50

alphabet = collect(Set(join(keys(words),"")))
symbols = sort(vcat(
    map(c-> "##" * string(c), collect(alphabet)),
    map(c-> "⋅" * string(c), collect(alphabet))
    ), by=x->length(x), rev=true)
bpe = BytePairEncoder(symbols)
corpus = encode_corpus(words, bpe)
vocab = count_tokens(corpus)
count_all_pairs!(corpus, vocab)
for i in 1:nrules
    scores = score_pairs(vocab);
    if isempty(scores)
        println("Breaking loop at i=$i. No more pairings left.")
        break
    end
    pair = argmax(scores)
    println("$i merging $pair")
    update!(pair, vocab, corpus);
    audit(vocab, corpus)
    push!(bpe.rules, pair)
end
vocab_out = Dict(filter(x->x[1] isa String && x[2] > 0, vocab))

bpe.rules