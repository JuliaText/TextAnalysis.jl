
const strip_patterns                = uint32(0)
const strip_corrupt_utf8            = uint32(0x1) << 0
const strip_case                    = uint32(0x1) << 1
const stem_words                    = uint32(0x1) << 2
const tag_part_of_speech            = uint32(0x1) << 3

const strip_whitespace              = uint32(0x1) << 5
const strip_punctuation             = uint32(0x1) << 6
const strip_numbers                 = uint32(0x1) << 7
const strip_non_letters             = uint32(0x1) << 8

const strip_indefinite_articles     = uint32(0x1) << 9
const strip_definite_articles       = uint32(0x1) << 10
const strip_articles                = (strip_indefinite_articles | strip_definite_articles)

const strip_prepositions            = uint32(0x1) << 13
const strip_pronouns                = uint32(0x1) << 14

const strip_stopwords               = uint32(0x1) << 16
const strip_sparse_terms            = uint32(0x1) << 17
const strip_frequent_terms          = uint32(0x1) << 18

const alpha_sparse      = 0.05
const alpha_frequent    = 0.95


##############################################################################
#
# Remove corrupt UTF8 characters
#
##############################################################################
function remove_corrupt_utf8(s::String)
    r = Array(Char, endof(s))
    i = 0
    for chr in s
        i += 1
        if chr != 0xfffd
            r[i] = chr
        end
    end
    return utf8(CharString(r[1:i]))
end

function remove_corrupt_utf8!(d::FileDocument)
    error("FileDocument cannot be modified")
end

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
    for token in keys(d.ngrams)
        new_token = remove_corrupt_utf8(token)
        if new_token != token
            if haskey(d.ngrams, new_token)
                d.ngrams[new_token] = d.ngrams[new_token] + d.ngrams[token]
            else
                d.ngrams[new_token] = d.ngrams[token]
            end
            delete!(d.ngrams, token)
        end
    end
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

remove_case = lowercase

function remove_case!(d::FileDocument)
    error("FileDocument cannot be modified")
end

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
    for token in keys(d.ngrams)
        new_token = remove_case(token)
        if new_token != token
            if haskey(d.ngrams, new_token)
                d.ngrams[new_token] = d.ngrams[new_token] + d.ngrams[token]
            else
                d.ngrams[new_token] = d.ngrams[token]
            end
            delete!(d.ngrams, token)
        end
    end
end

function remove_case!(crps::Corpus)
    for doc in crps
        remove_case!(doc)
    end
end

##############################################################################
#
# Remove specified words
#
##############################################################################
function remove_words!{T <: String}(entity::Union(AbstractDocument,Corpus), words::Vector{T})
    skipwords = Set{String}()
    union!(skipwords, words)
    prepare!(entity, strip_patterns, skip_words = skipwords)
end

function remove_whitespace!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_whitespace! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_whitespace)
end
function remove_punctuation!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_punctuation! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_punctuation)
end
function remove_nonletters!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_nonletters! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_non_letters)
end
function remove_numbers!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_numbers! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_numbers)
end
function remove_articles!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_articles)
end
function remove_indefinite_articles!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_indefinite_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_indefinite_articles)
end
function remove_definite_articles!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_definite_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_definite_articles)
end
function remove_prepositions!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_prepositions! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_prepositions)
end
function remove_pronouns!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_pronouns! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_pronouns)
end
function remove_stop_words!(entity::Union(AbstractDocument,Corpus)) 
    Base.warn_once("remove_stop_words! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_stopwords)
end


##############################################################################
#
# Stemming
#
##############################################################################

stem!(entity) = error("Not yet implemented")

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
            push!(res, term)
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
            push!(res, term)
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

function prepare!(crps::Corpus, flags::Uint32; skip_patterns = Set{String}(), skip_words = Set{String}())
    ((flags & strip_sparse_terms) > 0) && union!(skip_words, sparse_terms(crps))
    ((flags & strip_frequent_terms) > 0) && union!(skip_words, frequent_terms(crps))

    ((flags & strip_corrupt_utf8) > 0) && remove_corrupt_utf8!(crps)
    ((flags & strip_case) > 0) && remove_case!(crps)

    lang = language(crps.documents[1])   # assuming all documents are of the same language - practically true
    r = _build_regex(lang, flags, skip_patterns, skip_words)
    !isempty(r.pattern) && remove_patterns!(crps, r)

    ((flags & stem_words) > 0) && stem!(crps)
    ((flags & tag_part_of_speech) > 0) && tag_pos!(crps)
    nothing
end

function prepare!(d::AbstractDocument, flags::Uint32; skip_patterns = Set{String}(), skip_words = Set{String}()) 
    ((flags & strip_corrupt_utf8) > 0) && remove_corrupt_utf8!(d)
    ((flags & strip_case) > 0) && remove_case!(d)

    r = _build_regex(language(d), flags, skip_patterns, skip_words)
    !isempty(r.pattern) && remove_patterns!(d, r)

    ((flags & stem_words) > 0) && stem!(d)
    ((flags & tag_part_of_speech) > 0) && tag_pos!(d)
    nothing
end

##
# internal helper methods
function remove_patterns(s::String, rex::Regex)
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
    for token in keys(d.ngrams)
        new_token = remove_patterns(token, rex)
        if new_token != token
            if haskey(d.ngrams, new_token)
                d.ngrams[new_token] = d.ngrams[new_token] + d.ngrams[token]
            else
                d.ngrams[new_token] = d.ngrams[token]
            end
            delete!(d.ngrams, token)
        end
    end
end

function remove_patterns!(crps::Corpus, rex::Regex)
    for doc in crps
        remove_patterns!(doc, rex)
    end
end

_build_regex(lang, flags::Uint32) = _build_regex(lang, flags, Set{String}(), Set{String}())
_build_regex{T <: String}(lang, flags::Uint32, patterns::Set{T}, words::Set{T}) = _combine_regex(_build_regex_patterns(lang, flags, patterns, words))

function _combine_regex{T <: String}(regex_parts::Set{T})
    l = length(regex_parts)
    (0 == l) && return r""
    (1 == l) && return Regex(pop!(regex_parts), 0)

    iob = IOBuffer()
    write(iob, "($(pop!(regex_parts)))")
    for part in regex_parts
        write(iob, "|($part)")
    end
    Regex(takebuf_string(iob), 0)
end

function _build_regex_patterns{T <: String}(lang, flags::Uint32, patterns::Set{T}, words::Set{T})
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

function _build_words_pattern{T <: String}(words::Vector{T})
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

