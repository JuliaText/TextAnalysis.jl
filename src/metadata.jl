##############################################################################
#
# Metadata field getters and setters
#
##############################################################################

name(d::AbstractDocument) = d.metadata.name
language(d::AbstractDocument) = d.metadata.language
author(d::AbstractDocument) = d.metadata.author
timestamp(d::AbstractDocument) = d.metadata.timestamp

function name!(d::AbstractDocument, nv::String)
	d.metadata.name = nv
	return
end

function language!{T <: Language}(d::AbstractDocument, nv::Type{T})
	d.metadata.language = nv
	return
end

function author!(d::AbstractDocument, nv::String)
	d.metadata.author = nv
	return
end

function timestamp!(d::AbstractDocument, nv::String)
	d.metadata.timestamp = nv
	return
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
