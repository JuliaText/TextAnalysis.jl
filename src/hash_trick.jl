load("src/tokenize.jl")
load("src/hash.jl")

# ncols is size of hashed space.
# n is n for "n-grams".
# function hash_trick{T <: String}(filenames::Vector{T}, ncols::Int64, n::Int64)
#   for filename in filenames
#     row = zeros(Int64, ncols)
#     contents = readall(filename)
#     tokens = tokenize(contents, n)
#     for token in keys(tokens)
#       row[index_hash(token, ncols)] += tokens[token]
#     end
#     produce(row)
#   end
# end

function hash_trick{T <: String}(filenames::Vector{T}, ncols::Int64, n::Int64)
  hashed_dtm = spzeros(Int64, length(filenames), ncols)
  #hashed_dtm = zeros(Int64, length(filenames), ncols)
  for i in 1:length(filenames)
    filename = filenames[i]
    contents = readall(filename)
    contents = contents[1:(end - 2)] # Temporary hack for Newsgroups

    #tokens = Dict() # Must be defined outside try block.
                    # Would be nice if this could be done inside try block.
    local tokens
    try
      tokens = tokenize(contents, n)
    catch
      println("Error tokenizing $filename")
      continue
    end

    try
      for token in keys(tokens)
        hashed_dtm[i, index_hash(token, ncols)] += tokens[token]
      end
    catch
      println("Failed to hash/count tokens for $filename")
      for j in 1:ncols
        hashed_dtm[i, j] = 0
      end
    end
  end

  return hashed_dtm
end

# filenames = ["src/tokenize.jl", "src/document.jl", "src/document_term_matrix.jl"]

# ncols = 100

# n = 2

# hash_trick(filenames, ncols, n)

# cor(hash_trick(filenames, 100, 1)')
# cor(hash_trick(filenames, 100, 2)')
# cor(hash_trick(filenames, 100, 3)')

# cor(hash_trick(filenames, 1000, 1)')
# cor(hash_trick(filenames, 1000, 2)')
# cor(hash_trick(filenames, 1000, 3)')
