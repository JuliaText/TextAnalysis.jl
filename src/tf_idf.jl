##############################################################################
#
# TD-IDF
#
##############################################################################

function tf_idf!(dtm::Matrix{Int64})
	error("not yet implemented")
end

function tf_idf!(dtm::SparseMatrixCSC{Int64})
	error("not yet implemented")
end

function tf_idf!(dtm::DocumentTermMatrix)
	tf_idf(dtm.dtm)
end
