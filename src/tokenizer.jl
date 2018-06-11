##############################################################################
#
# Split string into tokens on whitespace
#
##############################################################################

tokenize{S <: Language, T <: AbstractString}(lang::S, s::T) = WordTokenizers.tokenize(s)

sentence_tokenize{S <: Language, T<:AbstractString}(lang::S, s::T) = WordTokenizers.split_sentences(s)
