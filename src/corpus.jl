##############################################################################
#
# Basic Corpus type
#
##############################################################################

type Corpus
	documents::Vector{GenericDocument}
	total_terms::Int
	lexicon::Dict{UTF8String, Int}
	inverse_index::Dict{UTF8String, Vector{Int}}
	h::TextHashFunction
end
function Corpus(docs::Vector{GenericDocument})
	Corpus(docs,
		   0,
		   Dict{UTF8String, Int}(),
		   Dict{UTF8String, Vector{Int}}(),
		   TextHashFunction())
end
function Corpus(docs::Vector{Any})
	Corpus(convert(Array{GenericDocument,1}, docs),
		   0,
		   Dict{UTF8String, Int}(),
		   Dict{UTF8String, Vector{Int}}(),
		   TextHashFunction())
end

##############################################################################
#
# Construct a Corpus from a directory of text files
#
##############################################################################

function DirectoryCorpus(directory_name::String)
	# Recursive descent of directory
	# Add all non-hidden files to Corpus
	docs = {}
	function include_document(filename::String)
		global docs
		if isfile(filename) && !ismatch(r"^\.", filename)
			push(docs, FileDocument(filename))
		end
	end
	load("FileFind")
	FileFind.find(directory_name, include_document)
	return Corpus(docs)
end

##############################################################################
#
# Basic Corpus properties
#
##############################################################################

documents(c::Corpus) = c.documents
length(crps::Corpus) = length(crps.documents)

##############################################################################
#
# Convert a Corpus to a DataFrame
#
##############################################################################

function DataFrame(crps::Corpus)
	df = DataFrame()
	n = length(crps)
	df["Language"] = DataVec(UTF8String, n)
	df["Name"] = DataVec(UTF8String, n)
	df["Author"] = DataVec(UTF8String, n)
	df["TimeStamp"] = DataVec(UTF8String, n)
	df["Length"] = DataVec(Int, n)
	df["Text"] = DataVec(UTF8String, n)
	for i in 1:n
		d = crps[i]
		df[i, "Language"] = string(language(d))
		df[i, "Name"] = name(d)
		df[i, "Author"] = author(d)
		df[i, "TimeStamp"] = timestamp(d)
		df[i, "Length"] = length(d)
		df[i, "Text"] = text(d)
	end
	return df
end

##############################################################################
#
# Treat a Corpus as an iterable
#
##############################################################################

function start(crps::Corpus)
	return 1
end

function next(crps::Corpus, ind::Int)
	(crps.documents[ind], ind + 1)
end

function done(crps::Corpus, ind::Int)
	return ind > length(crps.documents)
end

##############################################################################
#
# Treat a Corpus as a container
#
##############################################################################

function push(crps::Corpus, d::AbstractDocument)
	push(crps.documents, d)
end

function pop(crps::Corpus)
	pop(crps.documents)
end

function enqueue(crps::Corpus, d::AbstractDocument)
	enqueue(crps.documents, d)
end

function shift(crps::Corpus)
	shift(crps.documents)
end

function insert(crps::Corpus, index::Int, d::AbstractDocument)
	insert(crps.documents, index, d)
end

function del(crps::Corpus, index::Int)
	del(crps.documents, index)
end

##############################################################################
#
# Indexing into a Corpus
# 
# (a) Numeric indexing just provides the n-th document
# (b) String indexing is effectively a trivial search engine
#
##############################################################################

function ref(crps::Corpus, ind::Int)
	return crps.documents[ind]
end

function ref(crps::Corpus, inds::Vector{Int})
	return crps.documents[inds]
end

function ref(crps::Corpus, r::Range1)
	return crps.documents[r]
end

function ref(crps::Corpus, term::String)
	return get(crps.inverse_index, term, Int[])
end

##############################################################################
#
# Assignment into a Corpus
#
##############################################################################

function assign(crps::Corpus, d::AbstractDocument, ind::Int)
	crps.documents[ind] = d
	return d
end

##############################################################################
#
# Basic Corpus properties
#
# TODO: Offer progressive update that only changes based on current document
#
##############################################################################

lexicon(crps::Corpus) = crps.lexicon

function update_lexicon!(crps::Corpus)
	crps.total_terms = 0
	crps.lexicon = Dict{UTF8String,Int}()
	for doc in crps
		ngs = ngrams(doc)
		for ngram in keys(ngs)
			crps.total_terms += ngs[ngram]
			if has(crps.lexicon, ngram)
				crps.lexicon[ngram] += ngs[ngram]
			else
				crps.lexicon[ngram] = ngs[ngram]
			end
		end
	end
end

lexicon_size(crps::Corpus) = length(keys(crps.lexicon))

function lexical_frequency(crps::Corpus, term::String)
	return get(crps.lexicon, term, 0) / crps.total_terms
end

##############################################################################
#
# Work with the Corpus's inverse index
#
# TODO: offer progressive update that only changes based on current document
#
##############################################################################

inverse_index(crps::Corpus) = crps.inverse_index

function update_inverse_index!(crps::Corpus)
	crps.inverse_index = Dict{UTF8String, Array{Int, 1}}()
	for i in 1:length(crps)
		doc = crps[i]
		ngs = ngrams(doc)
		for ngram in keys(ngs)
			if has(crps.inverse_index, ngram)
				push(crps.inverse_index[ngram], i)
			else
				crps.inverse_index[ngram] = [i]
			end
		end
	end
end

index_size(crps::Corpus) = length(keys(crps.inverse_index))

##############################################################################
#
# Every Corpus prespecifies a hash function for hash trick analysis
#
##############################################################################

function hash_function(crps::Corpus)
	return crps.h
end
function hash_function!(crps::Corpus, f::TextHashFunction)
	crps.h = f
	return
end

##############################################################################
#
# Standardize the documents in a Corpus to a common type
#
##############################################################################

function standardize!{T <: AbstractDocument}(crps::Corpus, ::Type{T})
	for i in 1:length(crps)
		crps[i] = convert(T, crps[i])
	end
end
