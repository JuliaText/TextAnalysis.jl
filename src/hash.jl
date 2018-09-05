##############################################################################
#
# The hash trick: use a hash function instead of a lexicon to determine the
# columns of a DocumentTermMatrix-like encoding of the data
#
# To produce a DTM for a Corpus for which we do not have an existing lexicon,
# we need someway to map the terms from each document into column indices.
#
# We use the now standard "Hash Trick" (CITATION NEEDED), in which we
# hash strings and then reduce the resulting integers modulo N, which
# defines the numbers of columns we want our DTM to have. This amounts to
# doing a non-linear dimensionality reduction with low probability that similar
# terms hash to the same dimension.
#
# To make things easier, we wrap Julia's hash functions in a new type,
# TextHashFunction, which maintains information about the desired cardinality
# of the hashes.
#
##############################################################################

mutable struct TextHashFunction
    hash_function::Function
    cardinality::Int
end

TextHashFunction(cardinality::Int) = TextHashFunction(hash, cardinality)

TextHashFunction() = TextHashFunction(hash, 100)

cardinality(h::TextHashFunction) = h.cardinality

function index_hash(s::AbstractString, h::TextHashFunction)
    return Int(rem(h.hash_function(s), h.cardinality)) + 1
end
