# TODO Figure out the following:
# * strip_sparse_terms - to utilize `words_remove` and `sparse_terms` (of preprocessing.jl).
# * strip_frequent_terms - to utilize `words_remove` and `frequent_terms` (of preprocessing.jl).
# * strip_html_tags
# * strip_non_letters
# * strip_case
"""
Preprocessing functions

* corrupt_utf8
* whitespace
* punctuation
* numbers
* indefinite_articles
* definite_articles
* articles
* stopwords
* prepositions
* pronouns


Turns a string into a readable and writable stream of `Char`s,
used for preprocessing and flushing out the processes text.

Utility functions (lexers) such as `spaces` and `number` read characters from the stream
and match against it.

Functions (lexers) return `true` or `false` to indicate whether they matched anything
in the input stream. They can therefore be combined easily, e.g.

    spacesornumber(ts) = whtiespace(ts) || numbers(ts)

either deletes two consectutively read whitespaces or removes a number character, if matched.

For certain cases like `strip_pronouns`, `strip_prepositions`, `strip_stopwords`, etc.
These are stored into a `SortedSet` for faster preprocessing and
matches words / tokens against the characters in the stream
in the function `words_remove`.
"""
mutable struct PreprocessBuffer
    input::Vector{Char}
    idx::Int
end

PreprocessBuffer(input) = PreprocessBuffer(input, 1)

PreprocessBuffer(input::AbstractString) = PreprocessBuffer(collect(input))

Base.getindex(ps::PreprocessBuffer, i = ps.idx) = ps.input[i]

isdone(ps::PreprocessBuffer) = ps.idx > length(ps.input)

# TODO: Remove whitespace at the end, beginning and multiple whitepsaces into one.
"""
    corrupt_utf8(ps::PreprocessBuffer)

Removes the corrupt UTF8 chars.
"""
function corrupt_utf8(ps)
    isvalid(ps[ps.idx]) && return false

    deleteat!(ps.input, ps.idx)
    return true
end

"""
    whitespace(ps::PreprocessBuffer)

Squash multiple whitespaces to a single one.
And remove all leading and trailing whitespaces.
"""
function whitespace(ps)
    isspace(ps[ps.idx]) || return false

    ps.idx != 1 && !isspace(ps[ps.idx - 1]) && return next(ps)

    deleteat!(ps.input, ps.idx)
    return true

    # If prev is whitespace then delete.
end

"""
    trailing_whitespace(ps::PreprocessBuffer)

Remove the whitespaces at the end of the input stream.
"""
function trailing_whitespace(ps)
    isspace(ps[length(ps.input)]) || return
    i = length(ps.input) - 1

    while (i > 0) && isspace(ps[i])
        i -= 1
    end

    deleteat!(ps.input, i + 1: length(ps.input))
end

"""
    punctuation(ps::PreprocessBuffer)

Remove punctuations, as matched by `ispunct`.
"""
function punctuation(ps)
    ispunct(ps[]) || return false

    deleteat!(ps.input, ps.idx)
    return true
end

"""
    numbers(::PreprocessBuffer)

Removes all numbers.
"""
function numbers(ps)
    isdigit(ps[]) || return false

    deleteat!(ps.input, ps.idx)
    return true
end

"""
Helper function for words_remove.
Matches the next token in the stream against the `ws::SortedSet`.
Returns whether it matched and the idx of the token end
"""
function next_token(ps::PreprocessBuffer, ws)
    i = ps.idx
    while i <= length(ps.input) && isletter(ps[i])
        i += 1
    end
    i < length(ps.input) && isdigit(ps[i]) && return false, i

    String(ps.input[ps.idx:i-1]) ∈ ws && return true, i
    return false, i
end

"""
Matches true for characters corresponding to Regex("[a-zA-Z0-9_]")
"""
word_character(ch) = isascii(ch) && (isuppercase(ch) || islowercase(ch) ||
                                            isdigit(ch) || ch == '_')

"""
    words_remove(::PreprocessBuffer, ws)

Removes words from the PreprocessBuffer.
"""
function words_remove(ps, ws)
    ps.idx != 1 && word_character(ps[ps.idx - 1]) && return false
    isletter(ps[ps.idx]) || return false

    match, i = next_token(ps, ws)

    if match == false
        ps.idx = i
    else
        deleteat!(ps.input, ps.idx:i - 1)
    end

    return true
end

function next(ps::PreprocessBuffer)
    ps.idx += 1
    return true
end

"""
    fastpreprocess(::StringDocument, flags)
    fastpreprocess(::Corpus, flags)
    fastpreprocess(::String, lang::T, flags) where T <: Language
    fastpreprocess(::String, ::SortedSet, flags)

## Preprocessing functions currently available

* corrupt_utf8
* whitespace
* punctuation
* numbers

### Flags for functions requiring `words_remove`

* strip_indefinite_articles
* strip_definite_articles
* strip_articles
* strip_stopwords
* strip_prepositions
* strip_pronouns

## Usage


## Note:

This does not work for Corpora consisting of `FileDocument`,
`TokenDocument` or `NGramDocument`

"""
fastpreprocess(txt::String, lang = Languages.English(), flags = 0) = fastpreprocess(txt, build_set(flags, lang))

function build_set(flags, lang = Languages.English())
    ws = SortedSet()

    ((flags & strip_indefinite_articles) > 0) && union!(ws, indefinite_articles(lang))
    ((flags & strip_definite_articles) > 0) && union!(ws, definite_articles(lang))

    ((flags & strip_prepositions) > 0) && union!(ws, prepositions(lang))
    ((flags & strip_pronouns) > 0) && union!(ws, pronouns(lang))
    ((flags & strip_stopwords) > 0) && union!(ws, stopwords(lang))
    ws
end

# TODO: Check case insensitive in words
function fastpreprocess(txt::String, ws::SortedSet)
    length(txt) < 1 && return
    ps = PreprocessBuffer(txt)

    while !isdone(ps)
        whitespace(ps) ||
        corrupt_utf8(ps) ||
        punctuation(ps) ||
        numbers(ps) ||
        words_remove(ps, ws) || next(ps)
    end

    trailing_whitespace(ps)
    return String(ps.input)
end

function fastpreprocess(doc::StringDocument, flags = 0)
    doc.text =  fastpreprocess(doc.text, build_set(flags, language(doc)))
end

# Only for String Document
function fastpreprocess(crps::Corpus, flags = 0)
    ws = build_set(flags, language(crps[1]))

    for doc in crps
        doc.text = fastpreprocess(doc.text, ws)
    end
    crps
end

# HTML placed before words
