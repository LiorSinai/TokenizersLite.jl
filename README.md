## TokenizerLite

Basic tokenizers for NLP models.

Two strategies:
- Byte Pair Encoding
- Affixes

These tokenizers are used in my TransformersLite repository at [https://github.com/LiorSinai/TransformersLite](https://github.com/LiorSinai/TransformersLite).

Two sentence tokenizers (Sentence Boundary Detection) models:
- A simple model which uses 1 regex pattern. Will give false positives for acronyms or abbreviations.
- A more complex model which uses more rules and hard-coded lists to account for non-breaking prefixes. Will give false positives for these prefixes at the end of a sentence. 

## Byte Pair Encoding

The training algorithm first splits words into letters. 
Letters at the end and/or start of words are paired with `⋅` and words in the middle are paired with `##` e.g. `code` becomes `[⋅c, ##o, ##d,##e]`. The algorithm then iteratively groups letters into pairs. 
At the end of each round, it joins the most common pair to create a new token e.g. `[⋅c, ##o]` becomes `⋅co`. 
Then it joins all these pairs in the dataset, updates the counts and starts again.

By setting the numbers of joinings (`nrules`) one can control the number of tokens in the final vocabulary.

The implementation here fails with 3 or more overlapping pairs e.g. when two `o`'s are joined in `[m,o,o,o,o,o,n]`.

This algorithm was originally developed as a text compression algorithm and its results and applicability to natural language processing (NLP) are not always obvious. It should still be viewed as a text compression algorithm with some words forming out of the process but the smaller tokens cannot be expected to have meaning. 

## Affix tokenizer

This uses grammar rules and a fix list of affixes to break up words. E.g. `jumped` becomes `[jump, ed]`. A word is only broken up if the non-affix candidate is present in the vocabulary.
More complex rules are needed for doubling of constants and silent letters e.g. `baked` -> `[bake, ed]`. 

This strategy will fail in many cases e.g. `armor`->`[arm, or]` or `image`->`[im, age]`.
However for the most part it works well. The suffixes of `-s`, `-ed` and `-ly` made up the bulk of the separations in test datasets.

A disadvantage of this algorithm is that the size of the resulting vocabulary cannot be controlled.

## Case Study

The example folder uses the Amazon Reviews dataset from [HuggingFace](https://huggingface.co/datasets/amazon_reviews_multi).

## Installation

Download the GitHub repository (it is not registered). Then in the Julia repl:
```Julia
julia> ] #enter package mode
(@v1.x) pkg> dev path\\to\\TokenizersLite
```

Done. 

## Run

```bash
julia example/make_corpus.js
julia example/make_bpe.js
julia example/make_affixer.js
julia example/demo.js
```

## To do

- add support for symbols