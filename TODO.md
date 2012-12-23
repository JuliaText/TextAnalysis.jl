# TOP PRIORITIES

* Create hierarchy of Document types
* Make Corpus allow any element of Document type hierarchy
* Insist that Corpus maintain lexicon that is updated with each new document
















# Questions

* Store text in memory or just filenames?
* Store documents, n-grams or other representations?
* Use hashing to perform dimensionality reduction?
* Dense or sparse matrix representation?

# Sparse Matrix Support

* Tried to switch system over to using sparse matrices by default: changes recorded in `sparse_changes.diff`.
* Currently there are many problems with this approach.
* End-user will sometimes (often?) need to call `convert(Array{Int,2}, dtm.counts)` before working with matrix.
* TF-IDF no longer works using sparse matrices.
* Re-approach later.

# Documentation

* Update documentation to show `remove_articles`, `remove_prepositions`, `remove_pronouns` and `remove_stopwords`.

# General

* Add `remove_short_tokens()` for NGramDocument and NGramCorpus
* Add `remove_long_tokens()` for NGramDocument and NGramCorpus
* Support both sparse and non-sparse matrices.
* Provide basic document similarity metrics.
* Provide document clustering/dimensionality reduction algorithms:
  * k-Means
  * LSA
  * pLSA
  * Fixed Topic LDA
    * Gibbs sampling already exists.
	  * Figure out why inference for beta in LDA is acceptable, when theta inference is so poor.
	* Add variational inference and SVD inference.
  * Infinite Topic LDA
* Need to experiment with better tokenizers.
* Provide methods for adding items to a DTM after the fact.
* Add a []-hash like method for n-gram documents.
* Improve removal operations like prepositions and punctuation.

# Text Regression

* Implement generic ridge/LASSO and cross-validation, then implement text regression algorithms.

# Word Removal

* Provide generic lists of Wikipedia frequencies of top 100,000 words. Allow users to filter out words based on frequencies, rather than using a "stopword" definition.
