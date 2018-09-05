##############################################################################
#
# Split string into tokens on whitespace
#
##############################################################################

tokenize(lang::S, s::T) where {S <: Language, T <: AbstractString} = WordTokenizers.tokenize(s)

sentence_tokenize(lang::S, s::T) where {S <: Language, T<:AbstractString} = WordTokenizers.split_sentences(s)
