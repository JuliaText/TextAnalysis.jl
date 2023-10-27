mutable struct Corpus{T <: AbstractDocument}
    documents::Vector{T}
    total_terms::Int
    lexicon::Dict{String, Int}
    inverse_index::Dict{String, Vector{Int}}
    h::TextHashFunction
end

"""
    Corpus(docs::Vector{T}) where {T <: AbstractDocument}

Collections of documents are represented using the Corpus type.

# Example
```julia-repl
julia> crps = Corpus([StringDocument("Document 1"),
		              StringDocument("Document 2")])
A Corpus with 2 documents:
 * 2 StringDocument's
 * 0 FileDocument's
 * 0 TokenDocument's
 * 0 NGramDocument's

Corpus's lexicon contains 0 tokens
Corpus's index contains 0 tokens
```
"""
function Corpus(docs::Vector{T}) where {T <: AbstractDocument}
    Corpus(
        docs,
        0,
        Dict{String, Int}(),
        Dict{String, Vector{Int}}(),
        TextHashFunction()
    )
end

Corpus(docs::Vector{Any}) = Corpus(convert(Array{GenericDocument,1}, docs))

"""
    DirectoryCorpus(dirname::AbstractString)

Construct a Corpus from a directory of text files.
"""
function DirectoryCorpus(dirname::AbstractString)
    # Recursive descent of directory
    # Add all non-hidden files to Corpus

    docs = GenericDocument[]

    function add_files(dirname::AbstractString)
        if !isdir(dirname)
            error("DirectoryCorpus() can only be called on directories")
        end

        starting_dir = pwd()

        cd(dirname)
        for filename in readdir(".")
            if isfile(filename) && !occursin(r"^\.", filename)
                push!(docs, FileDocument(abspath(filename)))
            end
            if isdir(filename) && !islink(filename)
                add_files(filename)
            end
        end
        cd(starting_dir)
    end

    add_files(dirname)

    return Corpus(docs)
end

##############################################################################
#
# Basic Corpus properties
#
##############################################################################

documents(c::Corpus) = c.documents
Base.length(crps::Corpus) = length(crps.documents)

##############################################################################
#
# Treat a corpus as a Table
#
##############################################################################

Tables.columnnames(x::AbstractDocument) = (:Language, :Title, :Author, :Timestamp, :Length, :Text)
Tables.getcolumn(d::AbstractDocument, nm::Symbol) = nm === :Language ? string(language(d)) : nm === :Title ? title(d) : nm === :Author ? author(d) : nm === :Timestamp ? timestamp(d) : nm === :Length ? length(d) : nm === :Text ? text(d) : error("invalid column name for document: $nm")
Tables.getcolumn(d::AbstractDocument, i::Int) = Tables.getcolumn(d, Tables.columnnames(d)[i])

Tables.isrowtable(x::Corpus) = true
Tables.rows(x::Corpus) = x
Tables.schema(x::Corpus) = Tables.Schema((:Language, :Title, :Author, :Timestamp, :Length, :Text), (Union{String, Missing}, Union{String, Missing}, Union{String, Missing}, Union{String, Missing}, Union{Int, Missing}, Union{String, Missing}))

##############################################################################
#
# Treat a Corpus as an iterable
#
##############################################################################

function Base.iterate(crps::Corpus, ind=1)
    ind > length(crps.documents) && return nothing
    crps.documents[ind], ind+1
end

##############################################################################
#
# Treat a Corpus as a container
#
##############################################################################

Base.push!(crps::Corpus, d::AbstractDocument) = push!(crps.documents, d)
Base.pop!(crps::Corpus) = pop!(crps.documents)

Base.pushfirst!(crps::Corpus, d::AbstractDocument) = pushfirst!(crps.documents, d)
Base.popfirst!(crps::Corpus) = popfirst!(crps.documents)

function Base.insert!(crps::Corpus, index::Int, d::AbstractDocument)
    insert!(crps.documents, index, d)
end
Base.delete!(crps::Corpus, index::Integer) = delete!(crps.documents, index)

##############################################################################
#
# Indexing into a Corpus
#
# (a) Numeric indexing just provides the n-th document
# (b) String indexing is effectively a trivial search engine
#
##############################################################################

Base.getindex(crps::Corpus, ind::Real) = crps.documents[ind]
Base.getindex(crps::Corpus, inds::Vector{T}) where {T <: Real} = crps.documents[inds]
Base.getindex(crps::Corpus, r::AbstractRange) = crps.documents[r]
Base.getindex(crps::Corpus, term::AbstractString) = get(crps.inverse_index, term, Int[])

##############################################################################
#
# Assignment into a Corpus
#
##############################################################################

function Base.setindex!(crps::Corpus, d::AbstractDocument, ind::Real)
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
"""
    lexicon(crps::Corpus)

Shows the lexicon of the corpus.

Lexicon of a corpus consists of all the terms that occur in any document in the corpus.

# Example
```julia-repl
julia> crps = Corpus([StringDocument("Name Foo"),
                          StringDocument("Name Bar")])
A Corpus with 2 documents:
* 2 StringDocument's
* 0 FileDocument's
* 0 TokenDocument's
* 0 NGramDocument's

Corpus's lexicon contains 0 tokens
Corpus's index contains 0 tokens

julia> lexicon(crps)
Dict{String,Int64} with 0 entries
```
"""
lexicon(crps::Corpus) = crps.lexicon

function update_lexicon!(crps::Corpus, doc::AbstractDocument)
    ngs = ngrams(doc)
    for (ngram, counts) in ngs
        crps.total_terms += counts
        crps.lexicon[ngram] = get(crps.lexicon, ngram, 0) + counts
    end
end

function update_lexicon!(crps::Corpus)
    crps.total_terms = 0
    crps.lexicon = Dict{String,Int}()
    for doc in crps
        update_lexicon!(crps, doc)
    end
end

"""
    lexicon_size(crps::Corpus)

Tells the total number of terms in a lexicon.
"""
lexicon_size(crps::Corpus) = length(keys(crps.lexicon))

"""
    lexical_frequency(crps::Corpus, term::AbstractString)

Tells us how often a term occurs across all of the documents.
"""
lexical_frequency(crps::Corpus, term::AbstractString) =
    (get(crps.lexicon, term, 0) / crps.total_terms)

##############################################################################
#
# Work with the Corpus's inverse index
#
# TODO: offer progressive update that only changes based on current document
#
##############################################################################
"""
    inverse_index(crps::Corpus)

Shows the inverse index of a corpus.

If we are interested in a specific term, we often want to know which documents in a corpus
contain that term. The inverse index tells us this and therefore provides a simplistic sort of search algorithm.
"""
inverse_index(crps::Corpus) = crps.inverse_index

function update_inverse_index!(crps::Corpus)
    idx = Dict{String, Array{Int, 1}}()
    for i in 1:length(crps)
        doc = crps.documents[i]
        ngram_arr = isa(doc, NGramDocument) ? collect(keys(ngrams(doc))) : tokens(doc)
        ngram_arr = convert(Array{String,1}, ngram_arr)
        for ngram in ngram_arr
            key = get!(() -> [], idx, ngram)
            push!(key, i)
        end
    end
    for key in keys(idx)
        idx[key] = unique(idx[key])
    end
    crps.inverse_index = idx
    nothing
end

index_size(crps::Corpus) = length(crps.inverse_index)

##############################################################################
#
# Every Corpus prespecifies a hash function for hash trick analysis
#
##############################################################################

hash_function(crps::Corpus) = crps.h
hash_function!(crps::Corpus, f::TextHashFunction) = (crps.h = f; nothing)

"""
    standardize!(crps::Corpus, ::Type{T}) where T <: AbstractDocument

Standardize the documents in a Corpus to a common type.

# Example
```julia-repl
julia> crps = Corpus([StringDocument("Document 1"),
		              TokenDocument("Document 2"),
		              NGramDocument("Document 3")])
A Corpus with 3 documents:
 * 1 StringDocument's
 * 0 FileDocument's
 * 1 TokenDocument's
 * 1 NGramDocument's

Corpus's lexicon contains 0 tokens
Corpus's index contains 0 tokens


julia> standardize!(crps, NGramDocument)

# After this step, you can check that the corpus only contains NGramDocument's:

julia> crps
A Corpus with 3 documents:
 * 0 StringDocument's
 * 0 FileDocument's
 * 0 TokenDocument's
 * 3 NGramDocument's

Corpus's lexicon contains 0 tokens
Corpus's index contains 0 tokens
```
"""
function standardize!(crps::Corpus, ::Type{T}) where T <: AbstractDocument
    for i in 1:length(crps)
        crps.documents[i] = convert(T, crps.documents[i])
    end
end
