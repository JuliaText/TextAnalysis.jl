##############################################################################
#
# Metadata field getters and setters
#
##############################################################################

import Languages.name

name(d::AbstractDocument) = d.metadata.name
language(d::AbstractDocument) = d.metadata.language
author(d::AbstractDocument) = d.metadata.author
timestamp(d::AbstractDocument) = d.metadata.timestamp

function name!(d::AbstractDocument, nv::AbstractString)
    d.metadata.name = nv
end

function language!{T <: Language}(d::AbstractDocument, nv::T)
    d.metadata.language = nv
end

function author!(d::AbstractDocument, nv::AbstractString)
    d.metadata.author = nv
end

function timestamp!(d::AbstractDocument, nv::AbstractString)
    d.metadata.timestamp = nv
end

##############################################################################
#
# Vectorized getters for an entire Corpus
#
##############################################################################

names(c::Corpus) = map(d -> name(d), documents(c))
languages(c::Corpus) = map(d -> language(d), documents(c))
authors(c::Corpus) = map(d -> author(d), documents(c))
timestamps(c::Corpus) = map(d -> timestamp(d), documents(c))

names!(c::Corpus, nv::AbstractString) = name!.(documents(c), nv)
languages!{T <: Language}(c::Corpus, nv::T) = language!.(documents(c), nv)
authors!(c::Corpus, nv::AbstractString) = author!.(documents(c), nv)
timestamps!(c::Corpus, nv::AbstractString) = timestamp!.(documents(c), nv)

function names!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in enumerate(IndexLinear(), documents(c))
        name!(d, nvs[i])
    end
end

function languages!{T <: Language}(c::Corpus, nvs::Vector{T})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in enumerate(IndexLinear(), documents(c))
        language!(d, nvs[i])
    end
end

function authors!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in enumerate(IndexLinear(), documents(c))
        author!(d, nvs[i])
    end
end

function timestamps!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in enumerate(IndexLinear(), documents(c))
        timestamp!(d, nvs[i])
    end
end
