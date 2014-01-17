##############################################################################
#
# Split string into tokens on whitespace
#
##############################################################################

function tokenize{S <: Language}(::Type{S}, s::String)
    return matchall(r"[^\s]+", s)
end
