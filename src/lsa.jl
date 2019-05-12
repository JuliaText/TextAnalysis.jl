##############################################################################
#
# LSA
#
##############################################################################
"""
```
lsa(crps)
lsa(dtm)
```
Performs Latent Semantic Analysis or LSA on a corpus.

Parameters:
	-  cprs	    = A Corpus type object
	-  dtm	    = A DocumentTermMatrix object
"""
lsa(dtm::DocumentTermMatrix) = svd(tf_idf(dtm))
lsa(crps::Corpus) = svd(tf_idf(DocumentTermMatrix(crps)))
