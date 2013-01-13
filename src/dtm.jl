##############################################################################
#
# Basic DocumentTermMatrix type
#
##############################################################################

type DocumentTermMatrix
	dtm::SparseMatrixCSC{Int, Int}
	terms::Vector{UTF8String}
	column_indices::Dict{UTF8String, Int}
end

##############################################################################
#
# Construct a DocumentTermMatrix from a Corpus
#
##############################################################################

function DocumentTermMatrix(crps::Corpus)
	lex = lexicon(crps)
	terms = sort(keys(lex))
	column_indices = Dict{UTF8String, Int}()
	for i in 1:length(terms)
		term = terms[i]
		column_indices[term] = i
	end
	rows = Array(Int, 0)
	columns = Array(Int, 0)
	values = Array(Int, 0)
	for i in 1:length(crps)
		doc = crps[i]
		ngs = ngrams(doc)
		for ngram in keys(ngs)
			j = get(column_indices, ngram, 0)
			v = ngs[ngram]
			if j != 0
				push!(rows, i)
				push!(columns, j)
				push!(values, v)
			end
		end
	end
	if length(rows) > 0
		dtm = sparse(rows, columns, values)
	else
		dtm = spzeros(Int, length(crps), 0)
	end
	DocumentTermMatrix(dtm, terms, column_indices)
end

##############################################################################
#
# Access the DTM of a DocumentTermMatrix
#
##############################################################################

function dtm(d::DocumentTermMatrix, density::Symbol)
	if density == :sparse
		return d.dtm
	else
		return dense(d.dtm)
	end
end
function dtm(d::DocumentTermMatrix)
	return d.dtm
end
function dtm(crps::Corpus)
	dtm(DocumentTermMatrix(crps))
end

tdm(crps::DocumentTermMatrix, density::Symbol) = dtm(crps, density)' #'
tdm(crps::DocumentTermMatrix) = dtm(crps)' #'
tdm(crps::Corpus) = dtm(crps)' #'

##############################################################################
#
# Produce the signature of a DTM entry for a document
#
# TODO: Make this more efficieny by reusing column_indices
#
##############################################################################

function dtm_entries(d::AbstractDocument, lex::Dict{UTF8String, Int})
	ngs = ngrams(d)
	indices = Array(Int, 0)
	values = Array(Int, 0)
	terms = sort(keys(lex))
	column_indices = Dict{UTF8String, Int}()
	for i in 1:length(terms)
		term = terms[i]
		column_indices[term] = i
	end
	for ngram in keys(ngs)
		if has(column_indices, ngram)
			push!(indices, column_indices[ngram])
			push!(values, ngs[ngram])
		end
	end
	return (indices, values)
end

function dtv(d::AbstractDocument, lex::Dict{UTF8String, Int})
	p = length(keys(lex))
	row = zeros(Int, 1, p)
	indices, values = dtm_entries(d, lex)
	for i in 1:length(indices)
		row[1, indices[i]] = values[i]
	end
	return row
end
function dtv(d::AbstractDocument)
	error("Cannot construct a DTV without a pre-existing lexicon")
end

##############################################################################
#
# The hash trick: use a hash function instead of a lexicon to determine the
# columns of a DocumentTermMatrix-like encoding of the data
#
##############################################################################

function hash_dtv(d::AbstractDocument, h::TextHashFunction)
	p = cardinality(h)
	res = zeros(Int, 1, p)
	ngs = ngrams(d)
	for ng in keys(ngs)
		res[1, index_hash(ng, h)] += ngs[ng]
	end
	return res
end
hash_dtv(d::AbstractDocument) = hash_dtv(d, TextHashFunction())

function hash_dtm(crps::Corpus)
	h = hash_function(crps)
	n, p = length(crps), cardinality(h)
	res = zeros(Int, n, p)
	for i in 1:length(crps)
		doc = crps[i]
		res[i, :] = hash_dtv(doc, h)
	end
	return res
end

hash_tdm(crps::Corpus) = hash_dtm(crps)' #'

##############################################################################
#
# Produce entries for on-line analysis when DTM would not fit in memory
#
# TODO: Fill in definitions
#
##############################################################################

# each_dtv(crps)
# each_tdv(crps)
# each_hash_dtv(crps)
# each_hash_tdv(crps)
