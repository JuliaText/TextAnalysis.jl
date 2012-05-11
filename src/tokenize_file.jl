# Could do most removal operations at this point.
function tokenize_file(filename::String)
  f = open(filename, "r")
  text = readall(f)
  close(f)
  tokenize(text)
end
