using TokenizersLite

in_directory = "corpus/"
name = "amazon_reviews_train_en" 
filepath = joinpath(in_directory, name * ".txt")
out_directory = "outputs/bpe"
path_vocab = joinpath(out_directory, name * "_vocab.txt")
path_encodings = joinpath(out_directory, name * "_encodings.txt")
path_rules = joinpath(out_directory, name * "_rules.txt")
nrules = 8000
update_interval = 200

words = load_word_counts(filepath)

symbols = TokenizersLite.default_symbols
@time bpe, vocab, corpus = learn_bpe(symbols, words, nrules, update_interval=update_interval)

save_bpe(bpe, path_rules)
save_vocab(vocab, path_vocab)
save_encodings(corpus, path_encodings)