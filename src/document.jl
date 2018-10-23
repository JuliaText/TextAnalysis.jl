##############################################################################
#
# All Document types share a common metadata profile using DocumentMetadata
#
##############################################################################

mutable struct DocumentMetadata
    language
    name::String
    author::String
    timestamp::String
    id::String
    publisher::String
    edition_year::String
    published_year::String
    documenttype::String
    note::String
end
DocumentMetadata() = DocumentMetadata(
    Languages.English(),
    "Unnamed Document",
    "Unknown Author",
    "Unknown Time",
    "Unknown ID",
    "Unknown Publisher",
    "Unknown Edition Year",
    "Unknown Publishing Year",
    "Unknown Type",
    ""
)

##############################################################################
#
# The abstract Document type
#
##############################################################################

abstract type AbstractDocument; end

##############################################################################
#
# FileDocument type and constructors
#
##############################################################################

mutable struct FileDocument <: AbstractDocument
    filename::String
    metadata::DocumentMetadata
end

function FileDocument(f::AbstractString)
    d = FileDocument(String(f), DocumentMetadata())
    d.metadata.name = f
    return d
end

##############################################################################
#
# StringDocument type and constructors
#
##############################################################################

mutable struct StringDocument{T<:AbstractString} <: AbstractDocument
    text::T
    metadata::DocumentMetadata
end

StringDocument(txt::AbstractString) = StringDocument(txt, DocumentMetadata())

##############################################################################
#
# TokenDocument type and constructors
#
##############################################################################

mutable struct TokenDocument{T<:AbstractString} <: AbstractDocument
    tokens::Vector{T}
    metadata::DocumentMetadata
end
function TokenDocument(txt::AbstractString, dm::DocumentMetadata)
    TokenDocument(tokenize(dm.language, String(txt)), dm)
end
function TokenDocument(tkns::Vector{T}) where T <: AbstractString
    TokenDocument(tkns, DocumentMetadata())
end
TokenDocument(txt::AbstractString) = TokenDocument(String(txt), DocumentMetadata())

##############################################################################
#
# NGramDocument type and constructors
#
##############################################################################

mutable struct NGramDocument{T<:AbstractString} <: AbstractDocument
    ngrams::Dict{T,Int}
    n::Int
    metadata::DocumentMetadata
end
function NGramDocument(txt::AbstractString, dm::DocumentMetadata, n::Integer=1)
    NGramDocument(ngramize(dm.language, tokenize(dm.language, String(txt)), n),
        n, dm)
end
function NGramDocument(txt::AbstractString, n::Integer=1)
    NGramDocument(txt, DocumentMetadata(), n)
end
function NGramDocument(ng::Dict{T, Int}, n::Integer=1) where T <: AbstractString
    NGramDocument(merge(Dict{AbstractString,Int}(), ng), n, DocumentMetadata())
end

##############################################################################
#
# text() / text!(): Access to document text as a string
#
##############################################################################

function text(fd::FileDocument)
    !isfile(fd.filename) && error("Can't find file: $(fd.filename)")
    read(fd.filename, String)
end

text(sd::StringDocument) = sd.text
function text(td::TokenDocument)
    @warn("TokenDocument's can only approximate the original text")
    join(td.tokens, " ")
end
function text(ngd::NGramDocument)
    error("The text of an NGramDocument cannot be reconstructed")
end

text!(sd::StringDocument, new_text::AbstractString) = (sd.text = new_text)
function text!(d::AbstractDocument, new_text::AbstractString)
    error("The text of a $(typeof(d)) cannot be edited")
end

##############################################################################
#
# tokens() / tokens!(): Access to document text as a token array
#
##############################################################################

tokens(d::(Union{FileDocument, StringDocument})) = tokenize(language(d), text(d))
tokens(d::TokenDocument) = d.tokens
function tokens(d::NGramDocument)
    error("The tokens of an NGramDocument cannot be reconstructed")
end

tokens!(d::TokenDocument, new_tokens::Vector{T}) where {T <: AbstractString} = (d.tokens = new_tokens)
function tokens!(d::AbstractDocument, new_tokens::Vector{T}) where T <: AbstractString
    error("The tokens of a $(typeof(d)) cannot be directly edited")
end

##############################################################################
#
# ngrams() / ngrams!(): Access to document text as n-gram counts
#
##############################################################################

function ngrams(d::NGramDocument, n::Integer)
    error("The n-gram complexity of an NGramDocument cannot be increased")
end
ngrams(d::AbstractDocument, n::Integer) = ngramize(language(d), tokens(d), n)
ngrams(d::NGramDocument) = d.ngrams
ngrams(d::AbstractDocument) = ngrams(d, 1)

ngrams!(d::NGramDocument, new_ngrams::Dict{AbstractString, Int}) = (d.ngrams = new_ngrams)
function ngrams!(d::AbstractDocument, new_ngrams::Dict)
    error("The n-grams of $(typeof(d)) cannot be directly edited")
end

##############################################################################
#
# Length describes length of document in characters
#
##############################################################################

function Base.length(d::NGramDocument)
    error("NGramDocument's do not have a well-defined length")
end

Base.length(d::AbstractDocument) = length(text(d))

##############################################################################
#
# Length describes length of document in characters
#
##############################################################################

ngram_complexity(ngd::NGramDocument) = ngd.n

function ngram_complexity(d::AbstractDocument)
    error("$(typeof(d))'s have no n-gram complexity")
end

##############################################################################
#
# Union type that refers to a generic, non-abstract document type
#
##############################################################################

const GenericDocument = Union{
    FileDocument,
    StringDocument,
    TokenDocument,
    NGramDocument
}

##############################################################################
#
# Easier Document() constructor that decides types based on inputs
#
##############################################################################

Document(str::AbstractString) = isfile(str) ? FileDocument(str) : StringDocument(str)
Document(tkns::Vector{T}) where {T <: AbstractString} = TokenDocument(tkns)
Document(ng::Dict{String, Int}) = NGramDocument(ng)

##############################################################################
#
# Conversion rules
#
##############################################################################

function Base.convert(::Type{StringDocument}, d::FileDocument)
    StringDocument(text(d), d.metadata)
end
function Base.convert(::Type{TokenDocument}, d::(Union{FileDocument, StringDocument}))
    TokenDocument(tokens(d), d.metadata)
end
function Base.convert(::Type{NGramDocument},
            d::(Union{FileDocument, StringDocument, TokenDocument}))
    NGramDocument(ngrams(d), 1, d.metadata)
end
Base.convert(::Type{TokenDocument}, d::TokenDocument) = d
Base.convert(::Type{NGramDocument}, d::NGramDocument) = d

##############################################################################
#
# getindex() methods: StringDocument("This is text and that is not")["is"]
#
##############################################################################

Base.getindex(d::AbstractDocument, term::AbstractString) = ngrams(d)[term]
