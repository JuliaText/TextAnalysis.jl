##############################################################################
#
# All Document types share a common metadata profile using DocumentMetadata
#
##############################################################################

type DocumentMetadata
	language::AbstractKind
	name::UTF8String
	author::UTF8String
	timestamp::UTF8String
end
DocumentMetadata() = DocumentMetadata(EnglishLanguage,
									  utf8("Unnamed Document"),
	                                  utf8("Unknown Author"),
	                                  utf8("Unknown Time"))

##############################################################################
#
# The abstract Document type
#
##############################################################################

abstract AbstractDocument

##############################################################################
#
# StringDocument type and constructors
#
##############################################################################

type StringDocument <: AbstractDocument
	text::UTF8String
	metadata::DocumentMetadata
end
StringDocument{T <: String}(txt::T) = StringDocument(utf8(txt), DocumentMetadata())
StringDocument(io::IOStream) = StringDocument(readall(io), DocumentMetadata())

##############################################################################
#
# FileDocument type and constructors
#
##############################################################################

type FileDocument <: AbstractDocument
	filename::UTF8String
	metadata::DocumentMetadata
end
FileDocument(f::UTF8String) = FileDocument(f, DocumentMetadata())
FileDocument(f::ByteString) = FileDocument(utf8(f), DocumentMetadata())

##############################################################################
#
# TokenDocument type and constructors
#
##############################################################################

type TokenDocument <: AbstractDocument
	tokens::Vector{UTF8String}
	metadata::DocumentMetadata
end
function TokenDocument{T <: String}(txt::T, dm::DocumentMetadata)
	TokenDocument(tokenize(dm.language, utf8(txt)), dm)
end
function TokenDocument{T <: String}(txt::T)
	dm = DocumentMetadata()
	TokenDocument(tokenize(dm.language, utf8(txt)), dm)
end
function TokenDocument{T <: String}(tkns::Vector{T})
	dm = DocumentMetadata()
	TokenDocument(convert(Array{UTF8String, 1}, tkns), dm)
end
function TokenDocument(io::IOStream)
	dm = DocumentMetadata()
	text = readall(io)
	TokenDocument(tokenize(dm.language, utf8(txt)), dm)
end

##############################################################################
#
# NGramDocument type and constructors
#
##############################################################################

type NGramDocument <: AbstractDocument
	ngrams::Dict{UTF8String, Int}
	n::Int
	metadata::DocumentMetadata
end
function NGramDocument{T <: String}(txt::T, dm::DocumentMetadata)
	NGramDocument(ngramize(dm.language, utf8(txt), 1), 1, dm)
end
function NGramDocument{T <: String}(txt::T, n::Int)
	dm = DocumentMetadata()
	NGramDocument(ngramize(dm.language, tokenize(dm.language, utf8(txt)), n), n, dm)
end
function NGramDocument{T <: String}(txt::T)
	dm = DocumentMetadata()
	NGramDocument(ngramize(dm.language, tokenize(dm.language, utf8(txt)), 1), 1, dm)
end
function NGramDocument(io::IOStream)
	dm = DocumentMetadata()
	txt = readall(io)
	NGramDocument(ngramize(dm.language, tokenize(dm.language, utf8(txt)), 1), 1, dm)
end
function NGramDocument{T <: String}(ng::Dict{T, Int}, n::Int)
	dm = DocumentMetadata()
	NGramDocument(convert(Dict{UTF8String, Int}, ng), n, dm)
end
function NGramDocument{T <: String}(ng::Dict{T, Int})
	dm = DocumentMetadata()
	NGramDocument(convert(Dict{UTF8String, Int}, ng), 1, dm)
end

##############################################################################
#
# text()/text!(): Access to document text as a string
#
##############################################################################

function text(sd::StringDocument)
	return sd.text
end

function text(fd::FileDocument)
	if isfile(fd.filename)
		return readall(fd.filename)
	else
		error("Can't find file: $(fd.filename)")
	end
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

function text!(fd::FileDocument, new_text::String)
	info("Creating a new file for editing: $(fd.filename).textanalysis")
	if isfile(fd.filename)
		if !ismatch(r".textanalysis$", fd.filename)
			fd.filename = strcat(fd.filename, ".textanalysis")
		end
		io = open(fd.filename, "w")
		print(io, new_text)
		close(io)
	else
		error("Can't find file: $(fd.filename)")
	end
end

function text!(td::Union(TokenDocument, NGramDocument), new_text::String)
	error("The text of a $(typeof(d)) cannot be edited")
end

##############################################################################
#
# tokens()/tokens!(): Access to document text as a token array
#
##############################################################################

function tokens(d::Union(StringDocument, FileDocument))
	tokenize(language(d), text(d))
end

function tokens(d::TokenDocument)
	d.tokens
end

function tokens(d::NGramDocument)
	error("The tokens of an NGramDocument cannot be reconstructed")
end

function tokens!(d::Union(StringDocument, FileDocument, NGramDocument),
	             new_tokens::Vector{UTF8String})
	error("The tokens of a $(typeof(d)) cannot be directly edited")
end

function tokens!(d::TokenDocument, new_tokens::Vector{UTF8String})
	d.tokens = new_tokens
end

##############################################################################
#
# ngrams()/ngrams!(): Access to document text as n-gram counts
#
##############################################################################

function ngrams(d::Union(FileDocument, StringDocument, TokenDocument), n::Int)
	ngramize(language(d), tokens(d), n)
end

function ngrams(d::NGramDocument, n::Int)
	error("The n-gram complexity of an NGramDocument cannot be increased")
end

function ngrams(d::Union(FileDocument, StringDocument, TokenDocument))
	ngrams(d, 1)
end

function ngrams(d::NGramDocument)
	d.ngrams
end

function ngrams!(d::Union(FileDocument, StringDocument, TokenDocument),
	             new_ngrams::Dict{UTF8String, Int})
	error("The n-grams of $(typeof(d)) cannot be directly edited")
end

function ngrams!(d::NGramDocument, new_ngrams::Dict{UTF8String, Int})
	d.ngrams = new_ngrams
end

##############################################################################
#
# Length describes length of document in characters
#
##############################################################################

length(d::Union(StringDocument, FileDocument, TokenDocument)) = length(text(d))
length(d::NGramDocument) = error("NGramDocument's do not have a well-defined length")

##############################################################################
#
# Length describes length of document in characters
#
##############################################################################

ngram_complexity(fd::FileDocument) = error("FileDocument's have no n-gram complexity")
ngram_complexity(sd::StringDocument) = error("StringDocument's have no n-gram complexity")
ngram_complexity(td::TokenDocument) = error("TokenDocument's have no n-gram complexity")
ngram_complexity(ngd::NGramDocument) = ngd.n

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

function Document(str::String)
	if isfile(str)
		FileDocument(str)
	else
		StringDocument(str)
	end
end

function Document{T <: String}(tkns::Vector{T})
	TokenDocument(convert(Array{UTF8String, 1}, tkns))
end

function Document(ng::Dict{UTF8String, Int})
	NGramDocument(ng)
end

##############################################################################
#
# Conversion rules
#
##############################################################################

function convert(::Type{StringDocument}, d::FileDocument)
	d = StringDocument(text(d))
	# TODO: Copy metadata
end

function convert(::Type{TokenDocument}, d::Union(StringDocument, FileDocument))
	d = TokenDocument(tokens(d))
	# TODO: Copy metadata
end

function convert(::Type{NGramDocument}, d::Union(StringDocument, FileDocument))
	d = NGramDocument(ngrams(d))
	# TODO: Copy metadata
end

##############################################################################
#
# ref() methods: StringDocument("This is text and that is not")["is"]
#
##############################################################################

function ref(d::AbstractDocument, term::String)
	ngrams(d)[term]
end
