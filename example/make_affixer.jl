using TokenizersLite

name = "amazon_reviews_train_en"
path_words = joinpath("corpus/", name * ".txt")
directory = "outputs/affixes"
path_encodings = joinpath(directory, name * "_encodings.txt")
path_vocab = joinpath(directory, name * "_vocab.txt")
path_affixes = "src/AffixTokenization/affixes.txt"

vocab = load_word_counts(path_words)
#prefixes, suffixes = load_affixes(path_affixes)
prefixes, suffixes = TokenizersLite.get_default_affixes()
vocab_out, corpus = trim_vocab(vocab, ["un", "in"], suffixes) # prefixes tend to have many mistakes e.g. im-age, en-try
save_encodings(corpus, path_encodings)
save_vocab(vocab_out, path_vocab)

tokenizer = load_affix_tokenizer(path_vocab)
