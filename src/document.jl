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
    text::UTF8String
    metadata::DocumentMetadata
end

StringDocument(txt::String) = StringDocument(utf8(txt), DocumentMetadata())

##############################################################################
#
# TokenDocument type and constructors
#
##############################################################################

type TokenDocument <: AbstractDocument
    tokens::Vector{String}
    metadata::DocumentMetadata
end

function TokenDocument(txt::String, dm::DocumentMetadata)
    TokenDocument(tokenize(dm.language, utf8(txt)), dm)
end

function TokenDocument(txt::String)
    dm = DocumentMetadata()
    TokenDocument(tokenize(EnglishLanguage, utf8(txt)), dm)
end

function TokenDocument{T <: String}(tkns::Vector{T})
    dm = DocumentMetadata()
    TokenDocument(tkns, dm)
end

##############################################################################
#
# NGramDocument type and constructors
#
##############################################################################

type NGramDocument <: AbstractDocument
    ngrams::Dict
    n::Int
    metadata::DocumentMetadata
end

function NGramDocument(txt::String, dm::DocumentMetadata)
    NGramDocument(ngramize(dm.language, utf8(txt), 1),
                  1, dm)
end

function NGramDocument(txt::String, n::Integer)
    dm = DocumentMetadata()
    NGramDocument(ngramize(EnglishLanguage,
                           tokenize(dm.language, utf8(txt)), n),
                  n, dm)
end

function NGramDocument(txt::String)
    dm = DocumentMetadata()
    NGramDocument(ngramize(EnglishLanguage,
                           tokenize(dm.language, utf8(txt)), 1),
                  1, dm)
end

function NGramDocument{T <: String}(ng::Dict{T, Int}, n::Int)
    dm = DocumentMetadata()
    NGramDocument(convert(Dict{UTF8String, Int}, ng),
                  n, dm)
end

function NGramDocument{T <: String}(ng::Dict{T, Int})
    dm = DocumentMetadata()
    NGramDocument(convert(Dict{UTF8String, Int}, ng),
                  1, dm)
end

##############################################################################
#
# text() / text!(): Access to document text as a string
#
##############################################################################

function text(fd::FileDocument)
    if isfile(fd.filename)
        return readall(fd.filename)
    else
        error("Can't find file: $(fd.filename)")
    end
end

function text(sd::StringDocument)
    return sd.text
end

function text(td::TokenDocument)
    warn("TokenDocument's can only approximate the original text")
    return join(td.tokens, " ")
end

function text(ngd::NGramDocument)
    error("The text of an NGramDocument cannot be reconstructed")
end

function text!(sd::StringDocument, new_text::String)
    sd.text = new_text
    return sd.text
end

function text!(d::AbstractDocument, new_text::String)
    error("The text of a $(typeof(d)) cannot be edited")
end

##############################################################################
#
# tokens() / tokens!(): Access to document text as a token array
#
##############################################################################

function tokens(d::Union(FileDocument, StringDocument))
    tokenize(language(d), text(d))
end

function tokens(d::TokenDocument)
    d.tokens
end

function tokens(d::NGramDocument)
    error("The tokens of an NGramDocument cannot be reconstructed")
end

function tokens!{T <: String}(d::TokenDocument, new_tokens::Vector{T})
    d.tokens = new_tokens
end

function tokens!{T <: String}(d::AbstractDocument, new_tokens::Vector{T})
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

function ngrams(d::AbstractDocument, n::Integer)
    ngramize(language(d), tokens(d), n)
end

function ngrams(d::NGramDocument)
    d.ngrams
end

function ngrams(d::AbstractDocument)
    ngrams(d, 1)
end

function ngrams!(d::NGramDocument, new_ngrams::Dict{UTF8String, Int})
    d.ngrams = new_ngrams
end

function ngrams!(d::AbstractDocument, new_ngrams::Dict{UTF8String, Int})
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

typealias GenericDocument Union(
    FileDocument,
    StringDocument,
    TokenDocument,
    NGramDocument
)

##############################################################################
#
# Easier Document() constructor that decides types based on inputs
#
##############################################################################

function Document(str::String)
    if isfile(str)
        FileDocument(str)
    else
        StringDocument(str)
    end
end

function Document{T <: String}(tkns::Vector{T})
    TokenDocument(tkns)
end

function Document(ng::Dict{UTF8String, Int})
    NGramDocument(ng)
end

##############################################################################
#
# Conversion rules
#
##############################################################################

function Base.convert(::Type{StringDocument},
                 d::FileDocument)
    new_d = StringDocument(text(d))
    new_d.metadata = d.metadata
    return new_d
end

function Base.convert(::Type{TokenDocument},
                 d::Union(FileDocument, StringDocument))
    new_d = TokenDocument(tokens(d))
    new_d.metadata = d.metadata
    return new_d
end

Base.convert(::Type{TokenDocument}, d::TokenDocument) = d

function Base.convert(::Type{NGramDocument},
                 d::Union(FileDocument, StringDocument, TokenDocument))
    new_d = NGramDocument(ngrams(d))
    new_d.metadata = d.metadata
    return new_d
end

Base.convert(::Type{NGramDocument}, d::NGramDocument) = d

##############################################################################
#
# getindex() methods: StringDocument("This is text and that is not")["is"]
#
##############################################################################

Base.getindex(d::AbstractDocument, term::String) = ngrams(d)[term]
