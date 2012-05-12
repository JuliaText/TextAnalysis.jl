function generate_corpus(directory_name)
  # Move through a directory of files, reading each of them into a Dict.
  files = map(x -> "$directory_name/$x",
              map(chomp,
                  readlines(`ls $directory_name`)))
  tokens = Dict()
  documents = Dict()
  for file in files
    file_tokens = tokenize_file(file)
    for file_token in file_tokens
      if has(tokens, file_token[1])
        tokens[file_token[1]] = tokens[file_token[1]] + file_token[2]
      else
        tokens[file_token[1]] = file_token[2]
      end
    end
    documents[file] = file_tokens
  end
  corpus = TextCorpus(files, tokens, documents)
  corpus
end
