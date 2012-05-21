# Documentation

* Update documentation to show `remove_articles`, `remove_prepositions`, `remove_pronouns` and `remove_stopwords`.

# General

* Support both sparse and non-sparse matrices.
* Provide basic document similarity metrices.
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

# Sparse Matrix Support

* Easily implemented:

    load("extras/sparse.jl")
    dtm = spzeros(n, m)
