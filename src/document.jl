##############################################################################
#
# All Document types share a common metadata profile using DocumentMetadata
#
##############################################################################

type DocumentMetadata
    language::DataType
    name::UTF8String
    author::UTF8String
    timestamp::UTF8String
end
DocumentMetadata() = DocumentMetadata(
    EnglishLanguage,
    utf8("Unnamed Document"),
    utf8("Unknown Author"),
    utf8("Unknown Time")
)

##############################################################################
#
# The abstract Document type
#
##############################################################################

abstract AbstractDocument

##############################################################################
#
# FileDocument type and constructors
#
##############################################################################

type FileDocument <: AbstractDocument
    filename::UTF8String
    metadata::DocumentMetadata
end

function FileDocument(f::AbstractString)
    d = FileDocument(utf8(f), DocumentMetadata())
    d.metadata.name = f
    return d
end

##############################################################################
#
# StringDocument type and constructors
#
##############################################################################

type StringDocument <: AbstractDocument
    text::AbstractString
    metadata::DocumentMetadata
end

StringDocument(txt::AbstractString) = StringDocument(utf8(txt), DocumentMetadata())

##############################################################################
#
# TokenDocument type and constructors
#
##############################################################################

type TokenDocument <: AbstractDocument
    tokens::Vector{AbstractString}
    metadata::DocumentMetadata
end
function TokenDocument(txt::AbstractString, dm::DocumentMetadata)
    TokenDocument(tokenize(dm.language, utf8(txt)), dm)
end
function TokenDocument{T <: AbstractString}(tkns::Vector{T})
    TokenDocument(tkns, DocumentMetadata())
end
TokenDocument(txt::AbstractString) = TokenDocument(txt, DocumentMetadata())

##############################################################################
#
# NGramDocument type and constructors
#
##############################################################################

type NGramDocument <: AbstractDocument
    ngrams::Dict{AbstractString,Int}
    n::Int
    metadata::DocumentMetadata
end
function NGramDocument(txt::AbstractString, dm::DocumentMetadata, n::Integer=1)
    NGramDocument(ngramize(dm.language, tokenize(dm.language, utf8(txt)), n),
        n, dm)
end
function NGramDocument(txt::AbstractString, n::Integer=1)
    NGramDocument(txt, DocumentMetadata(), n)
end
function NGramDocument{T <: AbstractString}(ng::Dict{T, Int}, n::Integer=1)
    NGramDocument(merge(Dict{AbstractString,Int}(), ng), n, DocumentMetadata())
end

##############################################################################
#
# text() / text!(): Access to document text as a string
#
##############################################################################

function text(fd::FileDocument)
    !isfile(fd.filename) && error("Can't find file: $(fd.filename)")
    readall(fd.filename)
end

text(sd::StringDocument) = sd.text
function text(td::TokenDocument)
    warn("TokenDocument's can only approximate the original text")
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

tokens(d::(@compat Union{FileDocument, StringDocument})) = tokenize(language(d), text(d))
tokens(d::TokenDocument) = d.tokens
function tokens(d::NGramDocument)
    error("The tokens of an NGramDocument cannot be reconstructed")
end

tokens!{T <: AbstractString}(d::TokenDocument, new_tokens::Vector{T}) = (d.tokens = new_tokens)
function tokens!{T <: AbstractString}(d::AbstractDocument, new_tokens::Vector{T})
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

typealias GenericDocument @compat Union{
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
Document{T <: AbstractString}(tkns::Vector{T}) = TokenDocument(tkns)
Document(ng::Dict{UTF8String, Int}) = NGramDocument(ng)

##############################################################################
#
# Conversion rules
#
##############################################################################

function Base.convert(::Type{StringDocument}, d::FileDocument)
    StringDocument(text(d), d.metadata)
end
function Base.convert(::Type{TokenDocument}, d::(@compat Union{FileDocument, StringDocument}))
    TokenDocument(tokens(d), d.metadata)
end
function Base.convert(::Type{NGramDocument},
            d::(@compat Union{FileDocument, StringDocument, TokenDocument}))
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
