##############################################################################
#
# Split string into tokens on whitespace
#
##############################################################################

function tokenize{S <: Language}(::Type{S}, s::String)
    return convert(Array{UTF8String, 1}, matchall(r"[^\s]+", s))
end
