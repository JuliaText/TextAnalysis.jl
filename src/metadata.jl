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
id(d::AbstractDocument) = d.metadata.id
publisher(d::AbstractDocument) = d.metadata.publisher
published_year(d::AbstractDocument) = d.metadata.published_year
edition_year(d::AbstractDocument) = d.metadata.edition_year
documenttype(d::AbstractDocument) = d.metadata.documenttype
note(d::AbstractDocument) = d.metadata.note

function name!(d::AbstractDocument, nv::AbstractString)
    d.metadata.name = nv
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

function id!(d::AbstractDocument, nv::AbstractString)
    d.metadata.id = nv
end

function publisher!(d::AbstractDocument, nv::AbstractString)
    d.metadata.publisher = nv
end

function published_year!(d::AbstractDocument, nv::AbstractString)
    d.metadata.published_year = nv
end

function edition_year!(d::AbstractDocument, nv::AbstractString)
    d.metadata.edition_year = nv
end

function documenttype!(d::AbstractDocument, nv::AbstractString)
    d.metadata.documenttype = nv
end

function note!(d::AbstractDocument, nv::AbstractString)
    d.metadata.note = nv
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
ids(c::Corpus) = map(d -> id(d), documents(c))
publishers(c::Corpus) = map(d -> publisher(d), documents(c))
published_years(c::Corpus) = map(d -> published_year(d), documents(c))
edition_years(c::Corpus) = map(d -> edition_year(d), documents(c))
documenttypes(c::Corpus) = map(d -> documenttype(d), documents(c))
notes(c::Corpus) = map(d -> note(d), documents(c))

names!(c::Corpus, nv::AbstractString) = name!.(documents(c), nv)
languages!(c::Corpus, nv::T) where {T <: Language} = language!.(documents(c), Ref(nv)) #Ref to force scalar broadcast
authors!(c::Corpus, nv::AbstractString) = author!.(documents(c), Ref(nv))
timestamps!(c::Corpus, nv::AbstractString) = timestamp!.(documents(c), Ref(nv))
ids!(c::Corpus, nv::AbstractString) = id!.(documents(c), nv)
publishers!(c::Corpus, nv::AbstractString) = publisher!.(documents(c), nv)
published_years!(c::Corpus, nv::AbstractString) = published_year!.(documents(c), nv)
edition_years!(c::Corpus, nv::AbstractString) = edition_year!.(documents(c), nv)
documenttypes!(c::Corpus, nv::AbstractString) = documenttype!.(documents(c), nv)
notes!(c::Corpus, nv::AbstractString) = note!.(documents(c), nv)

function names!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        name!(d, nvs[i])
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

function ids!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        id!(d, nvs[i])
    end
end

function publishers!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        publisher!(d, nvs[i])
    end
end

function published_years!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        published_year!(d, nvs[i])
    end
end

function edition_years!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        edition_year!(d, nvs[i])
    end
end

function documenttypes!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        documenttype!(d, nvs[i])
    end
end

function notes!(c::Corpus, nvs::Vector{String})
    length(c) == length(nvs) || throw(DimensionMismatch("dimensions must match"))
    for (i, d) in pairs(IndexLinear(), documents(c))
        note!(d, nvs[i])
    end
end
