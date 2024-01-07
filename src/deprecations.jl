
## Deprecations for Languages

function tokenize(::Type{S}, s::T) where {S <: Language, T <: AbstractString}
    depwarn("Use of Languages as types is deprecated. Use instances.",  Symbol(S))
    tokenize(S(), s)
end

function ngramize(::Type{S}, words::Vector{T}, n::Int) where {S <: Language, T <: AbstractString}
    depwarn("Use of Languages as types is deprecated. Use instances.",  Symbol(S))
    ngramize(S(), words, n)
end

function onegramize(::Type{S}, words::Vector{T}) where {S <: Language, T <: AbstractString}
    depwarn("Use of Languages as types is deprecated. Use instances.",  Symbol(S))
    onegramize(S(), words)
end

#pre-processing functions

function remove_whitespace!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_whitespace! is deprecated, Use prepare! instead."
    prepare!(entity, strip_whitespace)
end
function remove_punctuation!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_punctuation! is deprecated, Use prepare! instead."
    prepare!(entity, strip_punctuation)
end
function remove_nonletters!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_nonletters! is deprecated, Use prepare! instead."
    prepare!(entity, strip_non_letters)
end
function remove_numbers!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_numbers! is deprecated, Use prepare! instead."
    prepare!(entity, strip_numbers)
end
function remove_articles!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_articles! is deprecated, Use prepare! instead."
    prepare!(entity, strip_articles)
end
function remove_indefinite_articles!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_indefinite_articles! is deprecated, Use prepare! instead."
    prepare!(entity, strip_indefinite_articles)
end
function remove_definite_articles!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_definite_articles! is deprecated, Use prepare! instead."
    prepare!(entity, strip_definite_articles)
end
function remove_prepositions!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_prepositions! is deprecated, Use prepare! instead."
    prepare!(entity, strip_prepositions)
end
function remove_pronouns!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_pronouns! is deprecated, Use prepare! instead."
    prepare!(entity, strip_pronouns)
end
function remove_stop_words!(entity::(Union{AbstractDocument,Corpus}))
    @warn "remove_stop_words! is deprecated, Use prepare! instead."
    prepare!(entity, strip_stopwords)
end
