
## Deprecations for Languages

function tokenize{S <: Language, T <: AbstractString}(::Type{S}, s::T)
    depwarn("Use of Languages as types is deprecated. Use instances.",  Symbol(S))
    tokenize(S(), s)
end

function ngramize{S <: Language, T <: AbstractString}(::Type{S}, words::Vector{T}, n::Int)
    depwarn("Use of Languages as types is deprecated. Use instances.",  Symbol(S))
    ngramize(S(), words, n)
end

function onegramize{S <: Language, T <: AbstractString}(::Type{S}, words::Vector{T})
    depwarn("Use of Languages as types is deprecated. Use instances.",  Symbol(S))
    onegramize(S(), words)
end

function stem_all{S <: Language}(stemmer::Stemmer, lang::Type{S}, sentence::AbstractString)
    depwarn("Use of Languages as types is deprecated. Use instances.",  Symbol(S))
    stem_all(stemmer, S(), sentence)
end

#pre-processing functions

function remove_whitespace!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_whitespace! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_whitespace)
end
function remove_punctuation!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_punctuation! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_punctuation)
end
function remove_nonletters!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_nonletters! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_non_letters)
end
function remove_numbers!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_numbers! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_numbers)
end
function remove_articles!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_articles)
end
function remove_indefinite_articles!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_indefinite_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_indefinite_articles)
end
function remove_definite_articles!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_definite_articles! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_definite_articles)
end
function remove_prepositions!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_prepositions! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_prepositions)
end
function remove_pronouns!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_pronouns! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_pronouns)
end
function remove_stop_words!(entity::(Union{AbstractDocument,Corpus}))
    Base.warn_once("remove_stop_words! is deprecated, Use prepare! instead.")
    prepare!(entity, strip_stopwords)
end
