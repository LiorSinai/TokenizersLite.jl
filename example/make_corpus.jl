using DataFrames
using Arrow
using Printf
using TokenizersLite: count_word_frequencies

if !(isdir("corpus"))
    mkdir("corpus")
    println("made driectory: corpus/")
end

path = "path\\to\\amazon_reviews_multi\\en\\1.0.0\\"
filename = "amazon_reviews_multi-train.arrow"
out_filename = "corpus/amazon_reviews_train_en.txt"
min_document_frequency = 30

checksum = readdir(path)[1]
filepath = joinpath(path, checksum, filename)

df = DataFrame(Arrow.Table(filepath))
sentences = df[:, "review_body"]
@time word_counts = count_word_frequencies(sentences, max_length=length(sentences), pattern=r"[A-Za-z][A-Za-z]+\b")

words_out = filter(x->x[2][2] ≥ min_document_frequency, word_counts)
println("Found $(length(word_counts)) unique words",
    " of which $(length(words_out)) have a document frequency ≥ $min_document_frequency")

TERM_FREQUENCY = 1
DOCUMENT_FREQUENCY = 2
words_out = sort(collect(words_out), by=x->(-x[2][DOCUMENT_FREQUENCY], x[1]))
open(out_filename,"w") do file
    for (word, freqs) in words_out
        println(file, "$word $(freqs[DOCUMENT_FREQUENCY])")
    end
 end