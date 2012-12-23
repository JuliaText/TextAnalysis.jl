# Implement the hashing trick which allows you to work with text data
# whose lexicon is not known before processing. Useful for creating DTM's
# from a text stream. Also useful because hashing serves as a kind of 
# random projection.

function index_hash(s::String, ncols::Int64)
  return int(rem(hash(s), ncols)) + 1
end
