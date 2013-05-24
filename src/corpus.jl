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

function DirectoryCorpus(dirname::String)
    # Recursive descent of directory
    # Add all non-hidden files to Corpus

    docs = {}

    function add_files(dirname::String)
        if !isdir(dirname)
            error("DirectoryCorpus() can only be called on directories")
        end

        starting_dir = pwd()

        cd(dirname)
        for filename in readdir(".")
            if isfile(filename) && !ismatch(r"^\.", filename)
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
length(crps::Corpus) = length(crps.documents)

##############################################################################
#
# Convert a Corpus to a DataFrame
#
##############################################################################

function convert(::Type{DataFrame}, crps::Corpus)
    df = DataFrame()
    n = length(crps)
    df["Language"] = DataArray(UTF8String, n)
    df["Name"] = DataArray(UTF8String, n)
    df["Author"] = DataArray(UTF8String, n)
    df["TimeStamp"] = DataArray(UTF8String, n)
    df["Length"] = DataArray(Int, n)
    df["Text"] = DataArray(UTF8String, n)
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

start(crps::Corpus) = 1
next(crps::Corpus, ind::Int) = (crps.documents[ind], ind + 1)
done(crps::Corpus, ind::Int) = ind > length(crps.documents)

##############################################################################
#
# Treat a Corpus as a container
#
##############################################################################

push!(crps::Corpus, d::AbstractDocument) = push!(crps.documents, d)
pop!(crps::Corpus) = pop!(crps.documents)

unshift!(crps::Corpus, d::AbstractDocument) = unshift!(crps.documents, d)
shift!(crps::Corpus) = shift!(crps.documents)

function insert!(crps::Corpus, index::Int, d::AbstractDocument)
    insert!(crps.documents, index, d)
end
delete!(crps::Corpus, index::Integer) = delete!(crps.documents, index)

##############################################################################
#
# Indexing into a Corpus
# 
# (a) Numeric indexing just provides the n-th document
# (b) String indexing is effectively a trivial search engine
#
##############################################################################

ref(crps::Corpus, ind::Real) = crps.documents[ind]
ref{T <: Real}(crps::Corpus, inds::Vector{T}) = crps.documents[inds]
ref(crps::Corpus, r::Ranges) = crps.documents[r]
ref(crps::Corpus, term::String) = get(crps.inverse_index, term, Int[])

##############################################################################
#
# Assignment into a Corpus
#
##############################################################################

function assign(crps::Corpus, d::AbstractDocument, ind::Real)
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
    crps.lexicon = Dict{UTF8String,Int}()
    for doc in crps
        update_lexicon!(crps, doc)
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
            if haskey(crps.inverse_index, ngram)
                push!(crps.inverse_index[ngram], i)
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
