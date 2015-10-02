##############################################################################
#
# Split string into tokens on whitespace
#
##############################################################################

tokenize{S <: Language, T <: AbstractString}(::Type{S}, s::T) = matchall(r"[^\s]+", s)
