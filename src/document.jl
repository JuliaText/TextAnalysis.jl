##############################################################################
#
# All Document types share a common metadata profile using DocumentMetadata
#
##############################################################################

mutable struct DocumentMetadata
    language::Language
    title::AbstractString
    author::AbstractString
    timestamp::AbstractString
    custom::Any

    @doc """
        DocumentMetadata(
            language::Language,
            title::String,
            author::String,
            timestamp::String,
            custom::Any
        )

    Stores basic metadata about Document.

    ...
    # Arguments
    - `language`: What language is the document in? Defaults to Languages.English(), a Language instance defined by the Languages package.
    - `title::String` : What is the title of the document? Defaults to "Untitled Document".
    - `author::String` : Who wrote the document? Defaults to "Unknown Author".
    - `timestamp::String` : When was the document written? Defaults to "Unknown Time".
    - `custom` : user specific data field. Defaults to nothing.
    ...
    """
    DocumentMetadata(
        language::Language=Languages.English(),
        title::AbstractString="Untitled Document",
        author::AbstractString="Unknown Author",
        timestamp::AbstractString="Unknown Time",
        custom::Any=nothing
    ) = new(language, title, author, timestamp, custom)
end

##############################################################################
#
# The abstract Document type
#
##############################################################################

abstract type AbstractDocument; end


mutable struct FileDocument <: AbstractDocument
    filename::String
    metadata::DocumentMetadata
end

"""
    FileDocument(pathname::AbstractString)

Represents a document using a plain text file on disk.

# Example
```julia-repl
julia> pathname = "/usr/share/dict/words"
"/usr/share/dict/words"

julia> fd = FileDocument(pathname)
A FileDocument
 * Language: Languages.English()
 * Title: /usr/share/dict/words
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: A A's AMD AMD's AOL AOL's Aachen Aachen's Aaliyah
```
"""
function FileDocument(pathname::AbstractString)
    doc = FileDocument(String(pathname), DocumentMetadata())
    doc.metadata.title = pathname
    return doc
end


mutable struct StringDocument{T<:AbstractString} <: AbstractDocument
    text::T
    metadata::DocumentMetadata
end

"""
    StringDocument(txt::AbstractString)

Represents a document using a UTF8 String stored in RAM.

# Example
```julia-repl
julia> str = "To be or not to be..."
"To be or not to be..."

julia> sd = StringDocument(str)
A StringDocument{String}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: To be or not to be...
```
"""
StringDocument(txt::AbstractString) = StringDocument(txt, DocumentMetadata())


mutable struct TokenDocument{T<:AbstractString} <: AbstractDocument
    tokens::Vector{T}
    metadata::DocumentMetadata
end

"""
    TokenDocument(txt::AbstractString)
    TokenDocument(txt::AbstractString, dm::DocumentMetadata)
    TokenDocument(tkns::Vector{T}) where T <: AbstractString

Represents a document as a sequence of UTF8 tokens.

# Example
```julia-repl
julia> my_tokens = String["To", "be", "or", "not", "to", "be..."]
6-element Array{String,1}:
    "To"
    "be"
    "or"
    "not"
    "to"
    "be..."

julia> td = TokenDocument(my_tokens)
A TokenDocument{String}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: ***SAMPLE TEXT NOT AVAILABLE***
```
"""
function TokenDocument(txt::AbstractString, dm::DocumentMetadata)
    TokenDocument(tokenize(dm.language, String(txt)), dm)
end
function TokenDocument(tkns::Vector{T}) where T <: AbstractString
    TokenDocument(tkns, DocumentMetadata())
end
TokenDocument(txt::AbstractString) = TokenDocument(String(txt), DocumentMetadata())


mutable struct NGramDocument{T<:AbstractString} <: AbstractDocument
    ngrams::Dict{T,Int}
    n::Union{Int,Vector{Int}}
    metadata::DocumentMetadata
end

"""
    NGramDocument(txt::AbstractString, n::Integer=1)
    NGramDocument(txt::AbstractString, dm::DocumentMetadata, n::Integer=1)
    NGramDocument(ng::Dict{T, Int}, n::Integer=1) where T <: AbstractString

Represents a document as a bag of n-grams, which are UTF8 n-grams and map to counts.

# Example
```julia-repl
julia> my_ngrams = Dict{String, Int}("To" => 1, "be" => 2,
                                     "or" => 1, "not" => 1,
                                     "to" => 1, "be..." => 1)
Dict{String,Int64} with 6 entries:
  "or"    => 1
  "be..." => 1
  "not"   => 1
  "to"    => 1
  "To"    => 1
  "be"    => 2

julia> ngd = NGramDocument(my_ngrams)
A NGramDocument{AbstractString}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: ***SAMPLE TEXT NOT AVAILABLE***
```
"""
function NGramDocument(txt::AbstractString, dm::DocumentMetadata, n::Integer...=1)
    NGramDocument(ngramize(dm.language, tokenize(dm.language, String(txt)), n...), (length(n) == 1) ? Int(first(n)) : Int[n...], dm)
end
function NGramDocument(txt::AbstractString, n::Integer...=1)
    NGramDocument(txt, DocumentMetadata(), n...)
end
function NGramDocument(ng::Dict{T, Int}, n::Integer...=1) where T <: AbstractString
    NGramDocument(merge(Dict{AbstractString,Int}(), ng), (length(n) == 1) ? Int(first(n)) : Int[n...], DocumentMetadata())
end

##############################################################################
#
# text() / text!(): Access to document text as a string
#
##############################################################################
"""
    text(fd::FileDocument)
    text(sd::StringDocument)
    text(ngd::NGramDocument)

Access the text of Document as a string.

# Example
```julia-repl
julia> sd = StringDocument("To be or not to be...")
A StringDocument{String}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: To be or not to be...

julia> text(sd)
"To be or not to be..."
```
"""
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
"""
    tokens(d::TokenDocument)
    tokens(d::(Union{FileDocument, StringDocument}))

Access the document text as a token array.

# Example
```julia-repl
julia> sd = StringDocument("To be or not to be...")
A StringDocument{String}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: To be or not to be...

julia> tokens(sd)
7-element Array{String,1}:
    "To"
    "be"
    "or"
    "not"
    "to"
    "be.."
    "."
```
"""
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
"""
    ngrams(ngd::NGramDocument, n::Integer)
    ngrams(d::AbstractDocument, n::Integer)
    ngrams(d::NGramDocument)
    ngrams(d::AbstractDocument)

Access the document text as n-gram counts.

# Example
```julia-repl
julia> sd = StringDocument("To be or not to be...")
A StringDocument{String}
 * Language: Languages.English()
 * Title: Untitled Document
 * Author: Unknown Author
 * Timestamp: Unknown Time
 * Snippet: To be or not to be...

julia> ngrams(sd)
 Dict{String,Int64} with 7 entries:
  "or"   => 1
  "not"  => 1
  "to"   => 1
  "To"   => 1
  "be"   => 1
  "be.." => 1
  "."    => 1
```
"""
function ngrams(ngd::NGramDocument, n::Integer)
    error("The n-gram complexity of an NGramDocument cannot be increased")
end
ngrams(d::AbstractDocument, n::Integer...) = ngramize(language(d), tokens(d), n...)
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
