##############################################################################
#
# Basic Corpus type
#
##############################################################################

mutable struct Corpus{T <: AbstractDocument}
    documents::Vector{T}
    total_terms::Int
    lexicon::Dict{String, Int}
    inverse_index::Dict{String, Vector{Int}}
    h::TextHashFunction
end

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

##############################################################################
#
# Construct a Corpus from a directory of text files
#
##############################################################################

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
# Convert a Corpus to a DataFrame
#
##############################################################################

function Base.convert(::Type{DataFrame}, crps::Corpus)
    df = DataFrame()
    n = length(crps)
    df[:Language] = Array{Union{String,Missing}}(n)
    df[:Name] = Array{Union{String,Missing}}(n)
    df[:Author] = Array{Union{String,Missing}}(n)
    df[:TimeStamp] = Array{Union{String,Missing}}(n)
    df[:Length] = Array{Union{Int,Missing}}(n)
    df[:Text] = Array{Union{String,Missing}}(n)
    for i in 1:n
        d = crps.documents[i]
        df[i, :Language] = string(language(d))
        df[i, :Name] = name(d)
        df[i, :Author] = author(d)
        df[i, :TimeStamp] = timestamp(d)
        df[i, :Length] = length(d)
        df[i, :Text] = text(d)
    end
    return df
end

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

lexicon_size(crps::Corpus) = length(keys(crps.lexicon))
lexical_frequency(crps::Corpus, term::AbstractString) =
    (get(crps.lexicon, term, 0) / crps.total_terms)

##############################################################################
#
# Work with the Corpus's inverse index
#
# TODO: offer progressive update that only changes based on current document
#
##############################################################################

inverse_index(crps::Corpus) = crps.inverse_index

function update_inverse_index!(crps::Corpus)
    idx = Dict{String, Array{Int, 1}}()
    for i in 1:length(crps)
        doc = crps.documents[i]
        ngram_arr = isa(doc, NGramDocument) ? collect(keys(ngrams(doc))) : tokens(doc)
        ngram_arr = convert(Array{String,1}, ngram_arr)
        for ngram in ngram_arr
            if haskey(idx, ngram)
                push!(idx[ngram], i)
            else
                idx[ngram] = [i]
            end
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

##############################################################################
#
# Standardize the documents in a Corpus to a common type
#
##############################################################################

function standardize!(crps::Corpus, ::Type{T}) where T <: AbstractDocument
    for i in 1:length(crps)
        crps.documents[i] = convert(T, crps.documents[i])
    end
end
