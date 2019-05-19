"""
	lsa(dtm::DocumentTermMatrix)
	lsa(crps::Corpus)

Performs Latent Semantic Analysis or LSA on a corpus.
"""
lsa(dtm::DocumentTermMatrix) = svd(tf_idf(dtm))
lsa(crps::Corpus) = svd(tf_idf(DocumentTermMatrix(crps)))
