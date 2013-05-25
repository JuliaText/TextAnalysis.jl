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
    error("FileDocument's cannot be modified")
end

function remove_corrupt_utf8!(d::StringDocument)
    d.text = remove_corrupt_utf8(d.text)
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

##############################################################################
#
# Remove white space
#
##############################################################################

const WHITESPACE_REGEX = Regex("\\s+", 0)
#remove_whitespace(s::String) = replace(s, r"\s+", " ")
remove_whitespace(s::String) = replace(s, WHITESPACE_REGEX, " ")

function remove_whitespace!(d::FileDocument)
    error("FileDocument's cannot be modified")
end

function remove_whitespace!(d::StringDocument)
    d.text = remove_whitespace(d.text)
end

function remove_whitespace!(d::TokenDocument)
    for i in 1:length(d.tokens)
        d.tokens[i] = remove_whitespace(d.tokens[i])
    end
end

function remove_whitespace!(d::NGramDocument)
    for token in keys(d.ngrams)
        new_token = remove_whitespace(token)
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

##############################################################################
#
# Remove punctuation
#
##############################################################################

const PUNCTUATION_REGEX = Regex("[,;:.!?()]+", 0)
#remove_punctuation(s::String) = replace(s, r"[,;:.!?()]+", "")
remove_punctuation(s::String) = replace(s, PUNCTUATION_REGEX, "")

function remove_punctuation!(d::FileDocument)
    error("FileDocument's cannot be modified")
end

function remove_punctuation!(d::StringDocument)
    d.text = remove_punctuation(d.text)
end

function remove_punctuation!(d::TokenDocument)
    for i in 1:length(d.tokens)
        d.tokens[i] = remove_punctuation(d.tokens[i])
    end
end

function remove_punctuation!(d::NGramDocument)
    for token in keys(d.ngrams)
        new_token = remove_punctuation(token)
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

##############################################################################
#
# Remove non-letters
#
##############################################################################

const NONLETTER_REGEX = Regex("[^a-zA-Z\s]", 0)
#remove_nonletters(s::String) = replace(s, r"[^a-zA-Z]", "")
remove_nonletters(s::String) = replace(s, NONLETTER_REGEX, "")

function remove_nonletters!(d::FileDocument)
    error("FileDocument's cannot be modified")
end

function remove_nonletters!(d::StringDocument)
    d.text = remove_nonletters(d.text)
end

function remove_nonletters!(d::TokenDocument)
    for i in 1:length(d.tokens)
        d.tokens[i] = remove_nonletters(d.tokens[i])
    end
end

function remove_nonletters!(d::NGramDocument)
    for token in keys(d.ngrams)
        new_token = remove_nonletters(token)
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

##############################################################################
#
# Conversion to lowercase
#
##############################################################################

remove_case = lowercase

function remove_case!(d::FileDocument)
    error("FileDocument's cannot be modified")
end

function remove_case!(d::StringDocument)
    d.text = remove_case(d.text)
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

##############################################################################
#
# Remove numbers
#
# TODO: Currently removes all numeric characters.
#       Should we just remove purely numeric tokens?
#
##############################################################################

const NUMBER_REGEX = Regex("\d+", 0)
#remove_numbers(s::String) = replace(s, r"\d+", "")
remove_numbers(s::String) = replace(s, NUMBER_REGEX, "")

function remove_numbers!(d::FileDocument)
    error("FileDocument's cannot be modified")
end

function remove_numbers!(d::StringDocument)
      d.text = remove_numbers(d.text)
end

function remove_numbers!(d::TokenDocument)
    for i in 1:length(d.tokens)
        d.tokens[i] = remove_numbers(d.tokens[i])
    end
end

function remove_numbers!(d::NGramDocument)
    for token in keys(d.ngrams)
        new_token = remove_numbers(token)
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

##############################################################################
#
# Remove specified words
#
##############################################################################

function remove_words{T <: String}(s::String, words::Vector{T})
    for word in words
        #s = replace(s, Regex(strcat("\\b", word, "\\b")), " ")
        s = replace(s, Regex(string("\\b", word, "\\b"), 0), " ")
    end
    return s
end

function remove_words!(d::FileDocument)
    error("FileDocument's cannot be modified")
end

function remove_words!{T <: String}(d::StringDocument, words::Vector{T})
    d.text = remove_words(d.text, words)
end

function remove_words!{T <: String}(d::TokenDocument, words::Vector{T})
    for i in 1:length(d.tokens)
        d.tokens[i] = remove_words(d.tokens[i], words)
    end
end

function remove_words!{T <: String}(d::NGramDocument, words::Vector{T})
    for token in keys(d.ngrams)
        new_token = remove_words(token, words)
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

##############################################################################
#
# Remove articles, indefinite articles, definite articles,
# prepositions, pronouns and stop words
#
##############################################################################

function remove_articles!(d::AbstractDocument)
    remove_words!(d, articles(language(d)))
end

function remove_indefinite_articles!(d::AbstractDocument)
    remove_words!(d, indefinite_articles(language(d)))
end

function remove_definite_articles!(d::AbstractDocument)
    remove_words!(d, definite_articles(language(d)))
end

function remove_prepositions!(d::AbstractDocument)
    remove_words!(d, prepositions(language(d)))
end

function remove_pronouns!(d::AbstractDocument)
    remove_words!(d, pronouns(language(d)))
end

function remove_stop_words!(d::AbstractDocument)
    remove_words!(d, stopwords(language(d)))
end

##############################################################################
#
# Stemming
#
##############################################################################

stem!(fd::AbstractDocument) = error("Not yet implemented")

##############################################################################
#
# Part-of-Speech tagging
#
##############################################################################

tag_pos!(fd::AbstractDocument) = error("Not yet implemented")

##############################################################################
#
# Call preprocessing step on each document in a Corpus
#
##############################################################################

for f in (:remove_whitespace!,
          :remove_corrupt_utf8!,
          :remove_punctuation!,
          :remove_case!,
          :remove_numbers!,
          :remove_nonletters!,
          :stem!,
          :tag_pos!,
          :remove_articles!,
          :remove_indefinite_articles!,
          :remove_definite_articles!,
          :remove_prepositions!,
          :remove_pronouns!,
          :remove_stop_words!)
    @eval begin
        function ($f)(crps::Corpus)
            for doc in crps
                ($f)(doc)
            end
        end
    end
end

function remove_words!{T <: String}(crps::Corpus, words::Vector{T})
    for doc in crps
        remove_words!(doc, words)
    end
end

##############################################################################
#
# Drop terms based on frequency
#
##############################################################################

function sparse_terms(crps::Corpus, alpha::Real)
    update_lexicon!(crps)
    update_inverse_index!(crps)
    t = crps.total_terms
    res = Array(UTF8String, 0)
    for term in keys(crps.lexicon)
        f = length(crps.inverse_index[term]) / length(crps.documents)
        if f <= alpha
            push!(res, term)
        end
    end
    return res
end
sparse_terms(crps::Corpus) = sparse_terms(crps, 0.05)

function frequent_terms(crps::Corpus, alpha::Real)
    update_lexicon!(crps)
    update_inverse_index!(crps)
    t = crps.total_terms
    res = Array(UTF8String, 0)
    for term in keys(crps.lexicon)
        f = length(crps.inverse_index[term]) / length(crps.documents)
        if f >= alpha
            push!(res, term)
        end
    end
    return res
end
frequent_terms(crps::Corpus) = frequent_terms(crps, 0.05)

# Sparse terms occur in less than x percent of all documents
function remove_sparse_terms!(crps::Corpus, alpha::Real)
    remove_words!(crps, sparse_terms(crps, alpha))
end
function remove_sparse_terms!(crps::Corpus)
    remove_sparse_terms!(crps, 0.05)
end

# Frequent terms occur in more than x percent of all documents
function remove_frequent_terms!(crps::Corpus, alpha::Real)
    remove_words!(crps, frequent_terms(crps, alpha))
end
function remove_frequent_terms!(crps::Corpus)
    remove_frequent_terms!(crps, 0.95)
end
