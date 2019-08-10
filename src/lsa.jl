"""
	lsa(dtm::DocumentTermMatrix)
	lsa(crps::Corpus)

Performs Latent Semantic Analysis or LSA on a corpus.

"""
lsa(dtm::DocumentTermMatrix) = svd(Matrix(tf_idf(dtm)))
function lsa(crps::Corpus)
	update_lexicon!(crps)
	svd(Matrix(tf_idf(DocumentTermMatrix(crps))))
end
