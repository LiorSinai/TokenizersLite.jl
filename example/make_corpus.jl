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
min_document_frequency = 10

checksum = readdir(path)[1]
filepath = joinpath(path, checksum, filename)

df = DataFrame(Arrow.Table(filepath))
sentences = df[:, "review_body"]
@time word_counts = count_word_frequencies(sentences, max_length=length(sentences), pattern=r"[A-Za-z][A-Za-z]+\b")

words_out = filter(x->x[2][2] ≥ min_document_frequency, word_counts)
println("Found $(length(word_counts)) unique words",
    " of which $(length(words_out)) have a document frequency ≥ $min_document_frequency")

open(out_filename,"w") do file
    for (word, freqs) in sort(collect(words_out), by=x->(-x[2][1], x[1]))
        println(file, "$word $(freqs[1])")
    end
 end