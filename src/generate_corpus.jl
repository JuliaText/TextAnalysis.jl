function generate_corpus(directory_name)
  # Move through a directory of files, reading each of them into a Dict.
  files = map(x -> "$directory_name/$x",
              map(chomp,
                  readlines(`ls $directory_name`)))
  all_tokens = Dict()
  documents = Dict()
  for file in files
    file_tokens = parse_file(file)
    for file_token in file_tokens
      if has(all_tokens, file_token[1])
        all_tokens[file_token[1]] = all_tokens[file_token[1]] + file_token[2]
      else
        all_tokens[file_token[1]] = file_token[2]
      end
    end
    documents[file] = file_tokens
  end
  corpus = Dict()
  corpus["files"] = files
  corpus["tokens"] = all_tokens
  corpus["documents"] = documents
  corpus
end
