##############################################################################
#
# Metadata field getters and setters
#
##############################################################################

import Languages.name

title(d::AbstractDocument) = d.metadata.title
language(d::AbstractDocument) = d.metadata.language
author(d::AbstractDocument) = d.metadata.author
timestamp(d::AbstractDocument) = d.metadata.timestamp

function title!(d::AbstractDocument, nv::AbstractString)
    d.metadata.title = nv
end

function language!(d::AbstractDocument, nv::T) where T <: Language
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

titles(c::Corpus) = map(d -> title(d), documents(c))
languages(c::Corpus) = map(d -> language(d), documents(c))
authors(c::Corpus) = map(d -> author(d), documents(c))
timestamps(c::Corpus) = map(d -> timestamp(d), documents(c))

titles!(c::Corpus, nv::AbstractString) = title!.(documents(c), nv)
languages!(c::Corpus, nv::T) where {T <: Language} = language!.(documents(c), Ref(nv)) #Ref to force scalar broadcast
authors!(c::Corpus, nv::AbstractString) = author!.(documents(c), Ref(nv))
timestamps!(c::Corpus, nv::AbstractString) = timestamp!.(documents(c), Ref(nv))

function titles!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        title!(d, nvs[i])
    end
end

function languages!(c::Corpus, nvs::Vector{T}) where T <: Language
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        language!(d, nvs[i])
    end
end

function authors!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        author!(d, nvs[i])
    end
end

function timestamps!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        timestamp!(d, nvs[i])
    end
end
