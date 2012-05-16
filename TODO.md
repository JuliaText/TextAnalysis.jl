# General

* Support both sparse and non-sparse matrices.
* Provide basic document similarity metrices.
* Provide document clustering algorithms:
  * k-Means
  * TD-IDF
  * pLSA
  * Fixed Topic LDA
  * Infinite Topic LDA

* Need to experiment with better tokenizers.
* Provide methods for adding items to a DTM after the fact.

* Implement generic ridge/LASSO and cross-validation, then implement text regression algorithms.

* Figure out why inference for beta in LDA is acceptable, when theta inference is so poor.

* Implement TD-IDF
* Decide whether n-gram representation should include (n-1),(n-2),(...)-grams.
* Add `print()`, `show()` and `[]` methods.

* Add more `add_` and `remove_` methods for `NGramDocument` and `NGramCorpus`.
* Add `Corpus(Document)` and not just `Corpus(Array{Document,1})`.
* Add a `remove_sparse_terms(dtm)` method.

# Stopword Removal

* Provide generic lists of stopwords and tools for removing them.
* Provide generic lists of Wikipedia frequencies of top 100,000 words. Allow users to filter out words based on frequencies, rather than using a "stopword" definition.
* Provide generic lists of pronouns, prepositions, articles, etc. Allow users to remove only those words and not all stopwords.

# Sparse Matrix Support

* Easily implemented:

    load("extras/sparse.jl")
    dtm = spzeros(n, m)
