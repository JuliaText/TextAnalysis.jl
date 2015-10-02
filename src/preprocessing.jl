
const strip_patterns                = @compat(UInt32(0))
const strip_corrupt_utf8            = @compat(UInt32(0x1)) << 0
const strip_case                    = @compat(UInt32(0x1)) << 1
const stem_words                    = @compat(UInt32(0x1)) << 2
const tag_part_of_speech            = @compat(UInt32(0x1)) << 3

const strip_whitespace              = @compat(UInt32(0x1)) << 5
const strip_punctuation             = @compat(UInt32(0x1)) << 6
const strip_numbers                 = @compat(UInt32(0x1)) << 7
const strip_non_letters             = @compat(UInt32(0x1)) << 8

const strip_indefinite_articles     = @compat(UInt32(0x1)) << 9
const strip_definite_articles       = @compat(UInt32(0x1)) << 10
const strip_articles                = (strip_indefinite_articles |
                                       strip_definite_articles)

const strip_prepositions            = @compat(UInt32(0x1)) << 13
const strip_pronouns                = @compat(UInt32(0x1)) << 14

const strip_stopwords               = @compat(UInt32(0x1)) << 16
const strip_sparse_terms            = @compat(UInt32(0x1)) << 17
const strip_frequent_terms          = @compat(UInt32(0x1)) << 18

const strip_html_tags               = @compat(UInt32(0x1)) << 20

const alpha_sparse      = 0.05
const alpha_frequent    = 0.95

const regex_cache = Dict{AbstractString, Regex}()
function mk_regex(regex_string)
    d = haskey(regex_cache, regex_string) ?
            regex_cache[regex_string] :
            (regex_cache[regex_string] = Regex(regex_string))
    (length(regex_cache) > 50) && empty!(regex_cache)
    d
end


##############################################################################
#
# Remove corrupt UTF8 characters
#
##############################################################################
function remove_corrupt_utf8(s::AbstractString)
    r = zeros(Char, endof(s)+1)
    i = 0
    for chr in s
        i += 1
        r[i] = (chr != 0xfffd) ? chr : ' '
    end
    return utf8(CharString(r))
end

remove_corrupt_utf8!(d::FileDocument) = error("FileDocument cannot be modified")

function remove_corrupt_utf8!(d::StringDocument)
    d.text = remove_corrupt_utf8(d.text)
    nothing
end

function remove_corrupt_utf8!(d::TokenDocument)
    for i in 1:length(d.tokens)
        d.tokens[i] = remove_corrupt_utf8(d.tokens[i])
    end
end

function remove_corrupt_utf8!(d::NGramDocument)
    new_ngrams = Dict{AbstractString, Int}()
    for token in keys(d.ngrams)
        new_token = remove_corrupt_utf8(token)
        if haskey(new_ngrams, new_token)
            new_ngrams[new_token] = new_ngrams[new_token] + 1
        else
            new_ngrams[new_token] = 1
        end
    end
    d.ngrams = new_ngrams
end

function remove_corrupt_utf8!(crps::Corpus)
    for doc in crps
        remove_corrupt_utf8!(doc)
    end
end

##############################################################################
#
# Conversion to lowercase
#
##############################################################################

remove_case{T <: AbstractString}(s::T) = lowercase(s)

remove_case!(d::FileDocument) = error("FileDocument cannot be modified")

function remove_case!(d::StringDocument)
    d.text = remove_case(d.text)
    nothing
end

function remove_case!(d::TokenDocument)
    for i in 1:length(d.tokens)
        d.tokens[i] = remove_case(d.tokens[i])
    end
end

function remove_case!(d::NGramDocument)
    new_ngrams = Dict{AbstractString, Int}()
    for token in keys(d.ngrams)
        new_token = remove_case(token)
        if haskey(new_ngrams, new_token)
            new_ngrams[new_token] = new_ngrams[new_token] + 1
        else
            new_ngrams[new_token] = 1
        end
    end
    d.ngrams = new_ngrams
end

function remove_case!(crps::Corpus)
    for doc in crps
        remove_case!(doc)
    end
end

##############################################################################
#
# Stripping HTML tags
#
##############################################################################
const script_tags = Regex("<script\\b[^>]*>([\\s\\S]*?)</script>")
const html_tags = Regex("<[^>]*>")

function remove_html_tags(s::AbstractString)
    s = remove_patterns(s, script_tags)
    remove_patterns(s, html_tags)
end

function remove_html_tags!(d::AbstractDocument)
    error("HTML tags can be removed only from a StringDocument")
end

function remove_html_tags!(d::StringDocument)
    d.text = remove_html_tags(d.text)
    nothing
end

function remove_html_tags!(crps::Corpus)
    for doc in crps
        remove_html_tags!(doc)
    end
end

##############################################################################
#
# Remove specified words
#
##############################################################################
function remove_words!{T <: AbstractString}(entity::(@compat Union{AbstractDocument,Corpus}),
                                    words::Vector{T})
    skipwords = Set{AbstractString}()
    union!(skipwords, words)
    prepare!(entity, strip_patterns, skip_words = skipwords)
end

function remove_whitespace!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_whitespace! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_whitespace)
end
function remove_punctuation!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_punctuation! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_punctuation)
end
function remove_nonletters!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_nonletters! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_non_letters)
end
function remove_numbers!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_numbers! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_numbers)
end
function remove_articles!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_articles)
end
function remove_indefinite_articles!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_indefinite_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_indefinite_articles)
end
function remove_definite_articles!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_definite_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_definite_articles)
end
function remove_prepositions!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_prepositions! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_prepositions)
end
function remove_pronouns!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_pronouns! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_pronouns)
end
function remove_stop_words!(entity::(@compat Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_stop_words! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_stopwords)
end


##############################################################################
#
# Part-of-Speech tagging
#
##############################################################################

tag_pos!(entity) = error("Not yet implemented")



##############################################################################
#
# Drop terms based on frequency
#
##############################################################################

function sparse_terms(crps::Corpus, alpha::Real = alpha_sparse)
    update_lexicon!(crps)
    update_inverse_index!(crps)
    res = Array(UTF8String, 0)
    ndocs = length(crps.documents)
    for term in keys(crps.lexicon)
        f = length(crps.inverse_index[term]) / ndocs
        if f <= alpha
            push!(res, utf8(term))
        end
    end
    return res
end

function frequent_terms(crps::Corpus, alpha::Real = alpha_frequent)
    update_lexicon!(crps)
    update_inverse_index!(crps)
    res = Array(UTF8String, 0)
    ndocs = length(crps.documents)
    for term in keys(crps.lexicon)
        f = length(crps.inverse_index[term]) / ndocs
        if f >= alpha
            push!(res, utf8(term))
        end
    end
    return res
end

# Sparse terms occur in less than x percent of all documents
remove_sparse_terms!(crps::Corpus, alpha::Real = alpha_sparse) = remove_words!(crps, sparse_terms(crps, alpha))

# Frequent terms occur in more than x percent of all documents
remove_frequent_terms!(crps::Corpus, alpha::Real = alpha_frequent) = remove_words!(crps, frequent_terms(crps, alpha))



##############################################################################
#
# Remove parts from document based on flags or regular expressions
#
##############################################################################

function prepare!(crps::Corpus, flags::UInt32; skip_patterns = Set{AbstractString}(), skip_words = Set{AbstractString}())
    ((flags & strip_sparse_terms) > 0) && union!(skip_words, sparse_terms(crps))
    ((flags & strip_frequent_terms) > 0) && union!(skip_words, frequent_terms(crps))

    ((flags & strip_corrupt_utf8) > 0) && remove_corrupt_utf8!(crps)
    ((flags & strip_case) > 0) && remove_case!(crps)
    ((flags & strip_html_tags) > 0) && remove_html_tags!(crps)

    lang = language(crps.documents[1])   # assuming all documents are of the same language - practically true
    r = _build_regex(lang, flags, skip_patterns, skip_words)
    !isempty(r.pattern) && remove_patterns!(crps, r)

    ((flags & stem_words) > 0) && stem!(crps)
    ((flags & tag_part_of_speech) > 0) && tag_pos!(crps)
    nothing
end

function prepare!(d::AbstractDocument, flags::UInt32; skip_patterns = Set{AbstractString}(), skip_words = Set{AbstractString}())
    ((flags & strip_corrupt_utf8) > 0) && remove_corrupt_utf8!(d)
    ((flags & strip_case) > 0) && remove_case!(d)
    ((flags & strip_html_tags) > 0) && remove_html_tags!(d)

    r = _build_regex(language(d), flags, skip_patterns, skip_words)
    !isempty(r.pattern) && remove_patterns!(d, r)

    ((flags & stem_words) > 0) && stem!(d)
    ((flags & tag_part_of_speech) > 0) && tag_pos!(d)
    nothing
end

##
# internal helper methods

function remove_patterns(s::AbstractString, rex::Regex)
    iob = IOBuffer()
    ibegin = 1
    for m in matchall(rex, s)
        len = m.offset-ibegin+1
        if len > 0
            Base.write_sub(iob, s.data, ibegin, len)
            write(iob, ' ')
        end
        ibegin = m.endof+m.offset+1
    end
    len = length(s.data) - ibegin + 1
    (len > 0) && Base.write_sub(iob, s.data, ibegin, len)
    takebuf_string(iob)
end

function remove_patterns{T <: ByteString}(s::SubString{T}, rex::Regex)
    iob = IOBuffer()
    ioffset = s.offset
    data = s.string.data
    ibegin = 1
    for m in matchall(rex, s)
        len = m.offset-ibegin+1
        if len > 0
            Base.write_sub(iob, data, ibegin+ioffset, len)
            write(iob, ' ')
        end
        ibegin = m.endof+m.offset+1
    end
    len = s.endof - ibegin + 1
    (len > 0) && Base.write_sub(iob, data, ibegin+ioffset, len)
    takebuf_string(iob)
end

remove_patterns!(d::FileDocument, rex::Regex) = error("FileDocument cannot be modified")

function remove_patterns!(d::StringDocument, rex::Regex)
    d.text = remove_patterns(d.text, rex)
    nothing
end

function remove_patterns!(d::TokenDocument, rex::Regex)
    for i in 1:length(d.tokens)
        d.tokens[i] = remove_patterns(d.tokens[i], rex)
    end
end

function remove_patterns!(d::NGramDocument, rex::Regex)
    new_ngrams = Dict{AbstractString, Int}()
    for token in keys(d.ngrams)
        new_token = remove_patterns(token, rex)
        if haskey(new_ngrams, new_token)
            new_ngrams[new_token] = new_ngrams[new_token] + 1
        else
            new_ngrams[new_token] = 1
        end
    end
    d.ngrams = new_ngrams
    nothing
end

function remove_patterns!(crps::Corpus, rex::Regex)
    for doc in crps
        remove_patterns!(doc, rex)
    end
end

_build_regex(lang, flags::UInt32) = _build_regex(lang, flags, Set{AbstractString}(), Set{AbstractString}())
_build_regex{T <: AbstractString}(lang, flags::UInt32, patterns::Set{T}, words::Set{T}) = _combine_regex(_build_regex_patterns(lang, flags, patterns, words))

function _combine_regex{T <: AbstractString}(regex_parts::Set{T})
    l = length(regex_parts)
    (0 == l) && return r""
    (1 == l) && return mk_regex(pop!(regex_parts))

    iob = IOBuffer()
    write(iob, "($(pop!(regex_parts)))")
    for part in regex_parts
        write(iob, "|($part)")
    end
    mk_regex(takebuf_string(iob))
end

function _build_regex_patterns{T <: AbstractString}(lang, flags::UInt32, patterns::Set{T}, words::Set{T})
    ((flags & strip_whitespace) > 0) && push!(patterns, "\\s+")
    if (flags & strip_non_letters) > 0
        push!(patterns, "[^a-zA-Z\\s]")
    else
        ((flags & strip_punctuation) > 0) && push!(patterns, "[,;:.!?()]+")
        ((flags & strip_numbers) > 0) && push!(patterns, "\\d+")
    end
    if (flags & strip_articles) > 0
        union!(words, articles(lang))
    else
        ((flags & strip_indefinite_articles) > 0) && union!(words, indefinite_articles(lang))
        ((flags & strip_definite_articles) > 0) && union!(words, definite_articles(lang))
    end
    ((flags & strip_prepositions) > 0) && union!(words, prepositions(lang))
    ((flags & strip_pronouns) > 0) && union!(words, pronouns(lang))
    ((flags & strip_stopwords) > 0) && union!(words, stopwords(lang))

    words_pattern = _build_words_pattern(collect(words))
    !isempty(words_pattern) && push!(patterns, words_pattern)
    patterns
end

function _build_words_pattern{T <: AbstractString}(words::Vector{T})
    isempty(words) && return ""

    iob = IOBuffer()
    write(iob, "\\b(")
    write(iob, words[1])
    l = length(words)
    for idx in 2:l
        write(iob, '|')
        write(iob, words[idx])
    end
    write(iob, ")\\b")
    takebuf_string(iob)
end
