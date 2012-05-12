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
