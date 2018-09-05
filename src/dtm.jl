##############################################################################
#
# Basic DocumentTermMatrix type
#
##############################################################################

mutable struct DocumentTermMatrix
    dtm::SparseMatrixCSC{Int, Int}
    terms::Vector{String}
    column_indices::Dict{String, Int}
end

##############################################################################
#
# Construct a DocumentTermMatrix from a Corpus
#
##############################################################################

# create col index lookup dictionary from a (sorted?) vector of terms
function columnindices(terms::Vector{String})
    column_indices = Dict{String, Int}()
    for i in 1:length(terms)
        term = terms[i]
        column_indices[term] = i
    end
    column_indices
end

function DocumentTermMatrix(crps::Corpus, terms::Vector{String})
    column_indices = columnindices(terms)

    m = length(crps)
    n = length(terms)

    rows = Array{Int}(undef, 0)
    columns = Array{Int}(undef, 0)
    values = Array{Int}(undef, 0)
    for i in 1:m
        doc = crps.documents[i]
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
        dtm = sparse(rows, columns, values, m, n)
    else
        dtm = spzeros(Int, m, n)
    end
    DocumentTermMatrix(dtm, terms, column_indices)
end
DocumentTermMatrix(crps::Corpus) = DocumentTermMatrix(crps, lexicon(crps))

DocumentTermMatrix(crps::Corpus, lex::AbstractDict) = DocumentTermMatrix(crps, sort(collect(keys(lex))))

DocumentTermMatrix(dtm::SparseMatrixCSC{Int, Int},terms::Vector{String}) = DocumentTermMatrix(dtm, terms, columnindices(terms))

##############################################################################
#
# Access the DTM of a DocumentTermMatrix
#
##############################################################################

function dtm(d::DocumentTermMatrix, density::Symbol)
    if density == :sparse
        return d.dtm
    else
        return Matrix(d.dtm)
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

function dtm_entries(d::AbstractDocument, lex::Dict{String, Int})
    ngs = ngrams(d)
    indices = Array{Int}(undef, 0)
    values = Array{Int}(undef, 0)
    terms = sort(collect(keys(lex)))
    column_indices = columnindices(terms)

    for ngram in keys(ngs)
        if haskey(column_indices, ngram)
            push!(indices, column_indices[ngram])
            push!(values, ngs[ngram])
        end
    end
    return (indices, values)
end

function dtv(d::AbstractDocument, lex::Dict{String, Int})
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

function hash_dtm(crps::Corpus, h::TextHashFunction)
    n, p = length(crps), cardinality(h)
    res = zeros(Int, n, p)
    for i in 1:length(crps)
        doc = crps.documents[i]
        res[i, :] = hash_dtv(doc, h)
    end
    return res
end

hash_dtm(crps::Corpus) = hash_dtm(crps, hash_function(crps))

hash_tdm(crps::Corpus) = hash_dtm(crps)' #'

##############################################################################
#
# Produce entries for on-line analysis when DTM would not fit in memory
#
##############################################################################

mutable struct EachDTV
    crps::Corpus
end

start(edt::EachDTV) = 1

function next(edt::EachDTV, state::Int)
    return (dtv(edt.crps.documents[state], lexicon(edt.crps)), state + 1)
end

done(edt::EachDTV, state::Int) = state > length(edt.crps.documents)

mutable struct EachHashDTV
    crps::Corpus
end

start(edt::EachHashDTV) = 1

function next(edt::EachHashDTV, state::Int)
    (hash_dtv(edt.crps.documents[state]), state + 1)
end

done(edt::EachHashDTV, state::Int) = state > length(edt.crps.documents)

each_dtv(crps::Corpus) = EachDTV(crps)

each_hash_dtv(crps::Corpus) = EachHashDTV(crps)

##
## getindex() methods
##

Base.getindex(dtm::DocumentTermMatrix, k::AbstractString) = dtm.dtm[:, dtm.column_indices[k]]
Base.getindex(dtm::DocumentTermMatrix, i::Any) = dtm.dtm[i]
Base.getindex(dtm::DocumentTermMatrix, i::Any, j::Any) = dtm.dtm[i, j]
