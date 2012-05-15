type DocumentTermMatrix
  #tokens::Array{String,1} # TMP redefine because keys(Dict) is Array{Any,1}.
  tokens::Array{Any,1}
  counts::Array{Int,2}
end

function td_idf(dtm::DocumentTermMatrix)
end
