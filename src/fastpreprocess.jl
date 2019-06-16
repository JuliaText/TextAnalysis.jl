# TODO
# * strip_sparse_terms
# * strip_frequent_terms
# * strip_html_tags
# * strip_non_letters
"""
Preprocessing functions

* strip_case

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
"""
mutable struct PreprocessBuffer
    input::Vector{Char}
    buffer::Vector{Char}
    idx::Int
end

PreprocessBuffer(input) = PreprocessBuffer(input, [], 1)

PreprocessBuffer(input::AbstractString) = PreprocessBuffer(collect(input))

Base.getindex(ps::PreprocessBuffer, i = ps.idx) = ps.input[i]

isdone(ps::PreprocessBuffer) = ps.idx > length(ps.input)

"""
    corrupt_utf8(ps::PreprocessBuffer)

Removes the corrupt UTF8 chars.
"""
function corrupt_utf8(ps)
    return false
end

"""
    punctuation(ps::PreprocessBuffer)

Squash multiple whitespaces to a single one.
And remove all leading and trailing whitespaces.
"""
function punctuation(ps)
    return false
end

"""
    numbers(::PreprocessBuffer)

Removes all numbers.
"""
function numbers(ps)
    return false
end

"""
    lookahead(::PreprocessBuffer, s; boundary = false)

Peek at the input to see if `s` is coming up next. `boundary` specifies whether
a word boundary should follow `s`.

```
julia> lookahead(PreprocessBuffer("foo bar"), "foo")
true
julia> lookahead(PreprocessBuffer("foo bar"), "bar")
false
julia> lookahead(PreprocessBuffer("foo bar"), "foo", boundary = true)
true
julia> lookahead(PreprocessBuffer("foobar"), "foo", boundary = true)
false
```
"""
function lookahead(ps::PreprocessBuffer, s; boundary = false)
    ps.idx + length(s) - 1 > length(ps.input) && return false

    for j = 1:length(s)
        ps.input[ps.idx - 1 + j] == s[j] || return false
    end
    if boundary
        next = ps.idx + length(s)
        next > length(ps.input) && return true
        (isletter(ps[next]) || ps[next] == '-') && return false
    end
    return true
end

"""
Helper function for words_remove.
"""
function next_token(ps::PreprocessBuffer)
    i = ps.idx
    while i < length(ps.input) && isletter(ps[i])
        i += 1
    end

    return String(ps.input[ps.idx:i-1])
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

    token = next_token(ps)
    # println(token)

    if token ∉ ws
        append!(ps.buffer, ps.input[ps.idx:ps.idx + length(token) ])
        ps.idx = ps.idx + length(token) + 1
    else
        ps.idx += length(token)
    end

    return true
end

function next(ps::PreprocessBuffer)
    push!(ps.buffer, ps[])
    ps.idx += 1
end

function try_fast(text, lang)
    length(text) < 1 && return

    indef_a = indefinite_articles(lang)
    def_a = definite_articles(lang)
    stop = stopwords(lang)
    prepo = prepositions(lang)
    pron = pronouns(lang)

    ws = SortedSet(vcat(indef_a, def_a, stop, prepo, pron))
    ps = PreprocessBuffer(text)

    # TODO: Check case insensitive in words

    while !isdone(ps)
        corrupt_utf8(ps) ||
        punctuation(ps) ||
        numbers(ps) ||
        words_remove(ps, ws) || next(ps)
    end

    return String(ps.buffer)
end

function try_fast(doc::StringDocument)
    doc.text =  try_fast(doc.text, Languages.English())
end

# Only for String Document
function fastpreprocess(crps::Corpus, flags)

    # strip

end

# HTML placed before words
