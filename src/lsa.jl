##############################################################################
#
# LSA
#
##############################################################################

lsa(dtm::DocumentTermMatrix) = svd(tf_idf(dtm))
lsa(crps::Corpus) = svd(tf_idf(DocumentTermMatrix(crps)))
