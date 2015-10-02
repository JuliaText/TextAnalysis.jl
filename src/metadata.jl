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

function language!{T <: Language}(d::AbstractDocument, nv::Type{T})
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
# TODO: Add vectorized setters
#
##############################################################################

names(c::Corpus) = map(d -> name(d), documents(c))
languages(c::Corpus) = map(d -> language(d), documents(c))
authors(c::Corpus) = map(d -> author(d), documents(c))
timestamps(c::Corpus) = map(d -> timestamp(d), documents(c))
