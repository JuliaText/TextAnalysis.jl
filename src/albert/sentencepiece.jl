# will be replace with Sentencepiece 
struct WordPiece
  vocab::Vector{String}
  unk_idx::Int
  max_char::Int
  WordPiece(vocab::Vector{String}, unk_idx::Int , max_char::Int) = new(vocab, unk_idx, max_char)
end

Base.show(io::IO, wp::WordPiece) = print(io, "WordPiece(vocab_size=$(length(wp.vocab)), unk=$(wp.vocab[wp.unk_idx]), max_char=$(wp.max_char))")


"""
    WordPiece(vocab::Vector{String}, unk::String = "[UNK]"; max_char::Int=200)

WordPiece implementation.

    (wp::WordPiece)(token)

split given token.

    (wp::WordPiece)(tokens::Vector{String})

split given tokens

    (wp::WordPiece)(type, tokens::Vector{String})

split given tokens, if `type` is `Int`, return pieces indices instead of strings pieces.

    (wp::WordPiece)(tks::Vector{T}, token::String)

split given token and add result to `tks`. if `T` is `Int`, add indices instead of strings pieces.
"""
WordPiece(vocab::Vector{String}, unk::String = "<unk>"; max_char::Int=200) = WordPiece(vocab, findfirst(isequal(unk), vocab), max_char)

Basic.Vocabulary(wp::WordPiece) = Vocabulary(wp.vocab, wp.vocab[wp.unk_idx])

struct _wp_equal{first} <: Function
  ss::String
  base::Int
  bound::Int
  ncode::Int
  _wp_equal{T}(ss, base, bound) where T = new{T}(ss, base, bound, getstrind(ss, bound+1)-getstrind(ss, base))
end

function getstrind(s, n)
  i = 1
  @inbounds while n > 1
    i = nextind(s, i)
    n-=1
  end
  i
end

_cmp(x, y, xbase, ybase, len) = ccall(:memcmp, Int32, (Ptr{UInt8}, Ptr{UInt8}, UInt),
                                      pointer(x, xbase),
                                      pointer(y, ybase),
                                      len)

function (wq::_wp_equal{first})(s) where first
  if first
    start = 1
  else
    start = 3
    iszero(_cmp(s, "", 1, 1, 2)) || return false
  end

  wq.bound - wq.base == length(s) - start || return false
  return iszero(_cmp(wq.ss, s,
                   getstrind(wq.ss, wq.base),
                   start,
                   wq.ncode
                   ))
end


(wp::WordPiece)(token) = wp(Vector{String}(), token)

(wp::WordPiece)(tokens::Vector{String}) = wp(String, tokens)

function (wp::WordPiece)(type::Type{T}, tokens::Vector{String}) where T
  tks = Vector{T}()
  sizehint!(tks, length(tokens))
  for tk ∈ tokens
    wp(tks, tk)
  end
  tks
end

function (wp::WordPiece)(tks::Vector{T}, token::String) where T
  s = 1
  tok_len = length(token)
  subtok = Vector{Int}()

  sizehint!(subtok, 1)

  if tok_len <= wp.max_char
    failed = false
    while s <= tok_len
      e = tok_len
      failed = true
      while s <= e
        if s != 1
          ss = findfirst(_wp_equal{false}(token, s, e), wp.vocab)
        else
          ss = findfirst(_wp_equal{true}(token, s, e), wp.vocab)
        end

        if ss === nothing
          e -= 1
        else
          push!(subtok, ss)
          failed = false
          s = e + 1
          break
        end
      end

      failed && break
    end
  else
    failed = true
  end

  if !failed
    len = length(tks)
    resize!(tks, len+length(subtok))
    for (i, tokid) ∈ enumerate(subtok)
      if T === Int
        @inbounds tks[len + i] = tokid
      else
        @inbounds tks[len + i] = wp.vocab[tokid]
      end
    end
  else
    if T === Int
      push!(tks, wp.unk_idx)
    else
      @inbounds push!(tks, wp.vocab[wp.unk_idx])
    end
  end

  tks
end

function load(path)
vocab = readlines(path)
vocabnew = split.(vocab , "\t")
vo = []
for i in 1:30000
    vocab1 = vocabnew[i][1]
    vocab1 = replace(vocab1,"▁"=>"_")
    push!(vo,vocab1)
end
vocab1 = convert(Array{String,1},vo)
#vocab1 = vocab1[2:30001]
logprob = []
for i in 1:30000
    logp = vocabnew[i][2]
    push!(logprob,logp)    
end
logp = convert(Array{String,1},logprob)
logp =parse.(Float64,logprob)
#logp = logp[2:end]
spm = Sentencepiecemodel(vocab1,logp)
return spm
end


# to get index of given string
function getindex(sp::Sentencepiecemodel,text)
    findall(x->x==text, sp.vocab)[1]
end
"""
struct Nodes 
    text::String
    score::Float32
    index::Int64
    start::Int
    en::Int
end
Utility structure, To hold the results of the forward pass (the forward Viterbi lattice)
hold the token token string, score, vocabulary index, start and end character position
    
"""
struct Nodes 
    text::String
    score::Float32
    index::Int64
    start::Int
    en::Int
end

"""
    decode_forward(sp::Sentencepiecemodel,text::String)
Return all possible ngrams generated from sequence of items, as an Array{String,1}
# Example
```julia-repl
julia> seq = ["To","be","or","not"]
julia> a = everygram(seq,min_len=1, max_len=-1)
 10-element Array{Any,1}:
  "or"          
  "not"         
  "To"          
  "be"                  
  "or not" 
  "be or"       
  "be or not"   
  "To be or"    
  "To be or not"
```
   
"""
function decode_forward(sp::Sentencepiecemodel,text::String)
    results = Array{Nodes,1}(undef,length(text))
    scores = fill(-Inf ,length(text))
    scores[1] =0
    for char_end in 1:length(text)
        for char_start in 1:char_end
            if text[char_start:char_end] in sp.vocab
                subtokenid = getindex(sp,text[char_start:char_end])[1]
                local_score = scores[char_start]+ sp.logprob[subtokenid]
                 if local_score > scores[char_end]   
                    results[char_end]=Nodes(text[char_start:char_end],local_score,subtokenid,char_start,char_end)
                    scores[char_end]=local_score
                end
            end
        end
        if scores[char_end] == -Inf
            results[char_end] = Nodes(text[char_end-1:char_end],-Inf,1,char_end-1,char_end)
            scores[char_end] =0
        end
        if scores[char_end] == 0
            results[char_end] = Nodes(text[char_end:char_end],-Inf,1,char_end,char_end)
        end
    end
    return(results)
end
"""
    decode_forward(sp::Sentencepiecemodel,text::String)
Return all possible ngrams generated from sequence of items, as an Array{String,1}
"""


function Decode_backward1(sp::Sentencepiecemodel,nodes)
    next_nodes=nodes[end]
    best_seq =[]
    
    while next_nodes.start > 1
        node_value = next_nodes
        next_nodes = nodes[(node_value.start)-1]
        push!(best_seq,node_value)
    end
    push!(best_seq,next_nodes)
    return(best_seq)
end
"""
    Tokenizer(sp::Sentencepiecemodel,text)
given spm path and text it tokenized you string
It does all the preprocessing step needed 
"""

function Tokenizer(sp::Sentencepiecemodel,text)
    tks=[]
    text = replace(text," " => "_")
    if text[1] != '_'
        text = "_"*text
    end
    output = decode_forward(sp,text)
    tokens = Decode_backward1(sp,output)
    tokens = reverse(tokens)
    for node in tokens
        push!(tks,node.text)
    end
    tks = string.(tks)
    return(tks)
    
end
 """
    ids_from_tokens(tk::Array{String,1})
given tokens it provide its indices
"""
      
function ids_from_tokens(tk)
idlist=[]
for i in tk
    idx = getindex(spm,i)
    push!(idlist,idx)
end
return convert.(Int,idlist)
end
