* Support both sparse and non-sparse matrices.
* Provide basic document similarity metrices.
* Provide simple clustering:
  * k-Means
  * TD-IDF
  * pLSA
  * Fixed Topic LDA
  * Infinite Topic LDA

* Need to experiment with other data structures for representing a corpus.
* Need to experiment with better tokenizers.
* Need to decide when corpus cleaning should take place.
  * Possible at corpus creation and also after. Allowing both will make EDA easier.

* Provide methods for adding items to a corpus after the fact. (Extends lexicon)
* Provide methods for adding items to a DTM after the fact. (Keeps existing lexicon? Extends lexicon?)

* Implement LASSO and then implement text regression.

* Figure out why inference for beta in LDA is acceptable, but theta inference is very poor.

# Revised Implementation
* DTM, TDM, TD-IDF
* Decide whether n-gram representation should include (n-1),(n-2),(...)-grams.
* Add print(), show() and [] methods.
* Switch over to type mechanism suggested by Stefan.

* Add remove_ methods for NGramDocument and NGramCorpus.
* Add Corpus(Document) and not just Corpus(Array{Document,1})

# Stopwords
* Provide stopwords. But also provide Wikipedia frequencies of top 100,000 words. Allow users to filter on frequencies, rather than "stopword" definition.
* Provide pronouns, prepositions, articles, etc. Allow users to remove only those.

# Remove Operations
* `remove_sparse_terms(dtm)`

# Sparse Matrix Support
* `load("extras/sparse.jl")`
* `dtm = spzeros(n, m)`
