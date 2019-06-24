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
    # buffer::Vector{Char}
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

    deleteat!(ps, ps.idx)
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

Remove punctuations.
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

# """
#     lookahead(::PreprocessBuffer, s; boundary = false)
#
# Peek at the input to see if `s` is coming up next. `boundary` specifies whether
# a word boundary should follow `s`.
#
# ```
# julia> lookahead(PreprocessBuffer("foo bar"), "foo")
# true
# julia> lookahead(PreprocessBuffer("foo bar"), "bar")
# false
# julia> lookahead(PreprocessBuffer("foo bar"), "foo", boundary = true)
# true
# julia> lookahead(PreprocessBuffer("foobar"), "foo", boundary = true)
# false
# ```
# """
# function lookahead(ps::PreprocessBuffer, s; boundary = false)
#     ps.idx + length(s) - 1 > length(ps.input) && return false
#
#     for j = 1:length(s)
#         ps.input[ps.idx - 1 + j] == s[j] || return false
#     end
#     if boundary
#         next = ps.idx + length(s)
#         next > length(ps.input) && return true
#         (isletter(ps[next]) || ps[next] == '-') && return false
#     end
#     return true
# end

"""
Helper function for words_remove.
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

# ws of type Sorted Set
function fastpreprocess(txt::String, lang)
    length(txt) < 1 && return

    indef_a = indefinite_articles(lang)
    def_a = definite_articles(lang)
    stop = stopwords(lang)
    prepo = prepositions(lang)
    pron = pronouns(lang)

    ws = SortedSet(vcat(indef_a, def_a, stop, prepo, pron))
    ps = PreprocessBuffer(txt)

    # TODO: Check case insensitive in words

    while !isdone(ps)
        whitespace(ps) ||
        corrupt_utf8(ps) ||
        punctuation(ps) ||
        numbers(ps) ||
        words_remove(ps, ws) || next(ps)
    end

    # trailing_whitespace(ps)

    return String(ps.input)
end

function fastpreprocess(doc::StringDocument)
    doc.text =  fastpreprocess(doc.text, Languages.English())
    nothing
end

# Only for String Document
function fastpreprocess(crps::Corpus, flags)
end
# HTML placed before words
