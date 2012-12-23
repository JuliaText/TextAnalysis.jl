##############################################################################
#
# Split string into tokens on whitespace
#
##############################################################################

function tokenize{S <: Language}(::Type{S}, s::String)
  words = convert(Array{UTF8String, 1}, split(s, r"\s+"))
  return words
end
