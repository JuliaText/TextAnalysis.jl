mutable struct DocumentTermMatrix{T}
    dtm::SparseMatrixCSC{Int, Int}
    terms::Vector{T}
    column_indices::Dict{T, Int}
end

function serialize(io::AbstractSerializer, dtm::DocumentTermMatrix{T}) where {T}
    Serialization.writetag(io.io, Serialization.OBJECT_TAG)
    serialize(io, DocumentTermMatrix{T})
    serialize(io, dtm.dtm)
    serialize(io, dtm.terms)
    nothing
end

function deserialize(io::AbstractSerializer, ::Type{DocumentTermMatrix{T}}) where {T}
    dtm = deserialize(io)
    terms = deserialize(io)
    column_indices = Dict{T,Int}(term => idx for (idx,term) in enumerate(terms))
    DocumentTermMatrix{T}(dtm, terms, column_indices)
end

"""
    columnindices(terms::Vector{String})

Creates a column index lookup dictionary from a vector of terms.
"""
function columnindices(terms::Vector{T}) where T
    column_indices = Dict{T, Int}()
    for i in 1:length(terms)
        term = terms[i]
        column_indices[term] = i
    end
    column_indices
end

"""
    DocumentTermMatrix(crps::Corpus)
    DocumentTermMatrix(crps::Corpus, terms::Vector{String})
    DocumentTermMatrix(crps::Corpus, lex::AbstractDict)
    DocumentTermMatrix(dtm::SparseMatrixCSC{Int, Int},terms::Vector{String})

Represent documents as a matrix of word counts.

Allow us to apply linear algebra operations and statistical techniques.
Need to update lexicon before use.

# Examples
```julia-repl
julia> crps = Corpus([StringDocument("To be or not to be"),
                      StringDocument("To become or not to become")])

julia> update_lexicon!(crps)

julia> m = DocumentTermMatrix(crps)
A 2 X 6 DocumentTermMatrix

julia> m.dtm
2×6 SparseArrays.SparseMatrixCSC{Int64,Int64} with 10 stored entries:
  [1, 1]  =  1
  [2, 1]  =  1
  [1, 2]  =  2
  [2, 3]  =  2
  [1, 4]  =  1
  [2, 4]  =  1
  [1, 5]  =  1
  [2, 5]  =  1
  [1, 6]  =  1
  [2, 6]  =  1
```
"""
function DocumentTermMatrix(crps::Corpus, terms::Vector{T}) where T
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

DocumentTermMatrix(dtm::SparseMatrixCSC{Int, Int},terms::Vector{T}) where T = DocumentTermMatrix{T}(dtm, terms, columnindices(terms))

"""
    dtm(crps::Corpus)
    dtm(d::DocumentTermMatrix)
    dtm(d::DocumentTermMatrix, density::Symbol)

Creates a simple sparse matrix of DocumentTermMatrix object.

# Examples
```julia-repl
julia> crps = Corpus([StringDocument("To be or not to be"),
                      StringDocument("To become or not to become")])

julia> update_lexicon!(crps)

julia> dtm(DocumentTermMatrix(crps))
2×6 SparseArrays.SparseMatrixCSC{Int64,Int64} with 10 stored entries:
  [1, 1]  =  1
  [2, 1]  =  1
  [1, 2]  =  2
  [2, 3]  =  2
  [1, 4]  =  1
  [2, 4]  =  1
  [1, 5]  =  1
  [2, 5]  =  1
  [1, 6]  =  1
  [2, 6]  =  1

julia> dtm(DocumentTermMatrix(crps), :dense)
2×6 Array{Int64,2}:
 1  2  0  1  1  1
 1  0  2  1  1  1
```
"""
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

function dtm_entries(d::AbstractDocument, lex::Dict{T, Int}) where T
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

"""
    dtv(d::AbstractDocument, lex::Dict{String, Int})

Produce a single row of a DocumentTermMatrix.

Individual documents do not have a lexicon associated with them,
we have to pass in a lexicon as an additional argument.

# Examples
```julia-repl
julia> dtv(crps[1], lexicon(crps))
1×6 Array{Int64,2}:
 1  2  0  1  1  1
```
"""
function dtv(d::AbstractDocument, lex::Dict{T, Int}) where T
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
"""
    hash_dtv(d::AbstractDocument)
    hash_dtv(d::AbstractDocument, h::TextHashFunction)

Represents a document as a vector with N entries.

# Examples
```julia-repl
julia> crps = Corpus([StringDocument("To be or not to be"),
                      StringDocument("To become or not to become")])

julia> h = TextHashFunction(10)
TextHashFunction(hash, 10)

julia> hash_dtv(crps[1], h)
1×10 Array{Int64,2}:
 0  2  0  0  1  3  0  0  0  0

julia> hash_dtv(crps[1])
1×100 Array{Int64,2}:
 0  0  0  0  0  0  0  0  0  0  0  0  0  …  0  0  0  0  0  0  0  0  0  0  0  0
```
"""
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


"""
    hash_dtm(crps::Corpus)
    hash_dtm(crps::Corpus, h::TextHashFunction)

Represents a Corpus as a Matrix with N entries.
"""
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

"""
    prune!(dtm::DocumentTermMatrix{T}, document_positions; compact::Bool=true, retain_terms::Union{Nothing,Vector{T}}=nothing) where {T}

Delete documents specified by `document_positions` from a document term matrix. Optionally compact the matrix by removing unreferenced terms.
"""
function prune!(dtm::DocumentTermMatrix{T}, document_positions; compact::Bool=true, retain_terms::Union{Nothing,Vector{T}}=nothing) where {T}
    if ((document_positions === nothing) || isempty(document_positions))
        dtm_matrix = dtm.dtm
    else
        docrows_to_retain = [!(idx in document_positions) for idx in 1:size(dtm.dtm, 1)]
        dtm_matrix = dtm.dtm[docrows_to_retain, :]
    end

    if compact
        termcols_to_delete = map(x->x==0, sum(dtm_matrix, dims=(1,)))
        if retain_terms !== nothing
            for idx in 1:length(termcols_to_delete)
                (!termcols_to_delete[idx] || !(dtm.terms[idx] in retain_terms)) && continue
                termcols_to_delete[idx] = false
            end
        end
    else
        termcols_to_delete = Bool[]
    end

    if any(termcols_to_delete)
        dtm.dtm = SparseArrays.fkeep!(dtm_matrix, (i,j,x)->!termcols_to_delete[j])
        dtm.terms = [dtm.terms[idx] for idx in 1:length(dtm.terms) if !termcols_to_delete[idx]]
    else
        dtm.dtm = dtm_matrix
    end

    dtm
end

"""
    merge!(dtm1::DocumentTermMatrix{T}, dtm2::DocumentTermMatrix{T}) where {T}

Merge one DocumentTermMatrix instance into another. Documents are appended to the end. Terms are re-sorted.
"""
function merge!(dtm1::DocumentTermMatrix{T}, dtm2::DocumentTermMatrix{T}) where {T}
    # add space for new rows columns to dtm1
    ncombined_docs = size(dtm1.dtm,1) + size(dtm2.dtm,1)
    termset1 = Set(dtm1.terms)
    termset2 = Set(dtm2.terms)
    termset = union(termset1, termset2)
    if termset1 == termset
        # no new terms added
        combined_terms = dtm1.terms
        ncombined_terms = length(dtm1.terms)
    else
        combined_terms = sort!(collect(termset))
        ncombined_terms = length(combined_terms)
    end

    function permute_terms!(dtm_to_permute, terms)
        terms_perm = indexin(terms, combined_terms)
        append!(terms_perm, setdiff(1:ncombined_terms, terms_perm))
        permute!(combined_dtm, 1:ncombined_docs, convert(Vector{Int},terms_perm))
    end

    combined_dtm = spzeros(Int, ncombined_docs, ncombined_terms)
    dtm1_indices = CartesianIndices((1:size(dtm1.dtm,1),1:size(dtm1.dtm,2)))
    copyto!(combined_dtm, dtm1_indices, dtm1.dtm, dtm1_indices)
    (combined_terms !== dtm1.terms) && permute_terms!(combined_dtm, dtm1.terms) # permute only if we need to

    # append entries from dtm2
    resized_dtm2 = spzeros(Int, size(dtm2.dtm,1), ncombined_terms)
    dtm2_indices = CartesianIndices((1:size(dtm2.dtm,1), 1:size(dtm2.dtm,2)))
    copyto!(resized_dtm2, dtm2_indices, dtm2.dtm, dtm2_indices)
    permute_terms!(resized_dtm2, dtm2.terms)
    dtm1_indices = CartesianIndices(((size(dtm1.dtm,1)+1):ncombined_docs, 1:ncombined_terms))
    dtm2_indices = CartesianIndices((1:size(resized_dtm2,1), 1:size(resized_dtm2,2)))
    copyto!(combined_dtm, dtm1_indices, resized_dtm2, dtm2_indices)

    # set new terms and recompute column_indices
    dtm1.dtm = combined_dtm
    dtm1.terms = combined_terms
    dtm1.column_indices = Dict{T,Int}(term => idx for (idx,term) in enumerate(combined_terms))

    dtm1
end
