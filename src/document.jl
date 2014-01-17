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
DocumentMetadata() = DocumentMetadata(EnglishLanguage, utf8("Unnamed Document"), utf8("Unknown Author"), utf8("Unknown Time"))

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

function FileDocument(f::String)
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
    text::String
    metadata::DocumentMetadata
end

StringDocument(txt::String) = StringDocument(utf8(txt), DocumentMetadata())
StringDocument(txt::MutableString) = StringDocument(txt, DocumentMetadata())

##############################################################################
#
# TokenDocument type and constructors
#
##############################################################################

type TokenDocument <: AbstractDocument
    tokens::Vector{String}
    metadata::DocumentMetadata
end
TokenDocument(txt::String, dm::DocumentMetadata) = TokenDocument(tokenize(dm.language, utf8(txt)), dm)
TokenDocument(txt::String) = TokenDocument(txt, DocumentMetadata())
TokenDocument{T <: String}(tkns::Vector{T}) = TokenDocument(tkns, DocumentMetadata())

##############################################################################
#
# NGramDocument type and constructors
#
##############################################################################

type NGramDocument <: AbstractDocument
    ngrams::Dict{String,Int}
    n::Int
    metadata::DocumentMetadata
end
NGramDocument(txt::String, dm::DocumentMetadata, n::Integer=1) = NGramDocument(ngramize(dm.language, tokenize(dm.language, utf8(txt)), n), n, dm)
NGramDocument(txt::String, n::Integer=1) = NGramDocument(txt, DocumentMetadata(), n)
NGramDocument{T <: String}(ng::Dict{T, Int}, n::Integer=1) = NGramDocument(merge(Dict{String,Int}(), ng), n, DocumentMetadata())

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
text(td::TokenDocument) = (warn("TokenDocument's can only approximate the original text"); join(td.tokens, " "))
text(ngd::NGramDocument) = error("The text of an NGramDocument cannot be reconstructed")

text!(sd::StringDocument, new_text::String) = (sd.text = new_text)
text!(d::AbstractDocument, new_text::String) = error("The text of a $(typeof(d)) cannot be edited")

##############################################################################
#
# tokens() / tokens!(): Access to document text as a token array
#
##############################################################################

tokens(d::Union(FileDocument, StringDocument)) = tokenize(language(d), text(d))
tokens(d::TokenDocument) = d.tokens
tokens(d::NGramDocument) = error("The tokens of an NGramDocument cannot be reconstructed")

tokens!{T <: String}(d::TokenDocument, new_tokens::Vector{T}) = (d.tokens = new_tokens)
tokens!{T <: String}(d::AbstractDocument, new_tokens::Vector{T}) = error("The tokens of a $(typeof(d)) cannot be directly edited")

##############################################################################
#
# ngrams() / ngrams!(): Access to document text as n-gram counts
#
##############################################################################

ngrams(d::NGramDocument, n::Integer) = error("The n-gram complexity of an NGramDocument cannot be increased")
ngrams(d::AbstractDocument, n::Integer) = ngramize(language(d), tokens(d), n)
ngrams(d::NGramDocument) = d.ngrams
ngrams(d::AbstractDocument) = ngrams(d, 1)

ngrams!(d::NGramDocument, new_ngrams::Dict{String, Int}) = (d.ngrams = new_ngrams)
ngrams!(d::AbstractDocument, new_ngrams::Dict) = error("The n-grams of $(typeof(d)) cannot be directly edited")

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

typealias GenericDocument Union(FileDocument, StringDocument, TokenDocument, NGramDocument)

##############################################################################
#
# Easier Document() constructor that decides types based on inputs
#
##############################################################################

Document(str::String) = isfile(str) ? FileDocument(str) : StringDocument(str)
Document{T <: String}(tkns::Vector{T}) = TokenDocument(tkns)
Document(ng::Dict{UTF8String, Int}) = NGramDocument(ng)

##############################################################################
#
# Conversion rules
#
##############################################################################

convert(::Type{StringDocument}, d::FileDocument) = StringDocument(text(d), d.metadata)
convert(::Type{TokenDocument}, d::Union(FileDocument, StringDocument)) = TokenDocument(tokens(d), d.metadata)
convert(::Type{TokenDocument}, d::TokenDocument) = d
convert(::Type{NGramDocument}, d::Union(FileDocument, StringDocument, TokenDocument)) = NGramDocument(ngrams(d), 1, d.metadata)
convert(::Type{NGramDocument}, d::NGramDocument) = d

##############################################################################
#
# getindex() methods: StringDocument("This is text and that is not")["is"]
#
##############################################################################

Base.getindex(d::AbstractDocument, term::String) = ngrams(d)[term]
