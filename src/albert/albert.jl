using Flux
using Flux: @functor
using Transformers.Stacks
using MacroTools: @forward

using Transformers.Basic
using Transformers.Basic: AbstractTransformer
using Transformers.Stacks


struct ALGroup
  ts::Stack
  drop::Dropout
end

@functor ALGroup

@forward ALGroup.ts Base.getindex, Base.length

"""
   ALGroup(size::Int, head::Int, ps::Int, layer::Int,inner_group::Int;
              act = gelu, pdrop = 0.1, attn_pdrop = 0.1)

layer containing non-shared Transformer layers(multi-headed attention layer + feed-forward NN + Dropout )

    (bert::albert)(x, mask=nothing; all::Bool=false)

eval the forward pass on input `x`. If length `mask` is given (in shape (1, seq_len, batch_size)), mask the attention with `getmask(mask, mask)`. Moreover, set `all` to `true` to get all
outputs of each transformer layer.
"""
function ALGroup(size::Int, head::Int, ps::Int, layer::Int,inner_group::Int;
              act = gelu, pdrop = 0.1, attn_pdrop = 0.1)
  rem(size,  head) != 0 && error("size not divisible by head")
  ALGroup(size, head, div(size, head), ps, layer, inner_group; act=act, pdrop=pdrop, attn_pdrop=attn_pdrop)
end

function ALGroup(size::Int, head::Int, hs::Int, ps::Int, layer::Int,inner_group::Int; act = gelu, pdrop = 0.1, attn_pdrop = 0.1)
  ALGroup(
    Stack(
      @nntopo_str("((x, m) => x':(x, m)) => $inner_group"),
      [
        Transformer(size, head, hs, ps; future=true, act=act, pdrop=attn_pdrop) # Transformer Encoder from "Attention is all you need" 
        for i = 1:inner_group
      ]...
    ),
    Dropout(pdrop))
end

function (al::ALGroup)(x::T, mask=nothing; all::Bool=false) where T
  e = x
  if mask === nothing
    t, ts = al.ts(e, nothing)
  else
    t, ts = al.ts(e, getmask(mask, mask))
  end

  if all
    if mask !== nothing
      ts = map(ts) do ti
        ti .* mask
      end
    end
    ts[end], ts
  else
    t = mask === nothing ? t : t .* mask
    t
  end
end

struct albert_transformer <: Transformers.Basic.AbstractTransformer
    linear::Dense
    al::Array{ALGroup,1}
    no_hid::Int
    no_inner::Int
    no_group::Int
end
@functor albert_transformer

"""
    albert_transformer(emb::Int,size::Int, head::Int, ps::Int, layer::Int, inner_group::Int, no_hidden_group::Int; 
act = gelu, pdrop = 0.1, attn_pdrop = 0.1)

the A lite Bidirectional Encoder Representations from Transformer(ALBERT) model.
    
    (altrans::albert_transformer)(x::T, mask=nothing; all::Bool=false) where T

eval the albert layer on input `x`. If length `mask` is given (in shape (1, seq_len, batch_size)), mask the attention with `getmask(mask, mask)`. Moreover, set `all` to `true` to get all
outputs of each transformer layer.

Arguments:

emb  : Dimensionality of vocabulary embeddings
size  : Dimensionality of the encoder layers and the pooler layer
head  : Number of attention heads for each attention layer in the Transformer encoder
ps  : The dimensionality of the “intermediate” (i.e., feed-forward) layer in the 
Transformer encoder.   
layer  : Number of hidden layers in the Transformer encoder
inner_group  : The number of inner repetition of attention and ffn.
no_hidden_group : Number of groups for the hidden layers, parameters in the same group are shared
act  : The non-linear activation function (function or string) in the encoder and pooler. If string, “gelu”, “relu”, “swish” and “gelu_new” are supported
pdrop  :  The dropout probability for all fully connected layers in the embeddings, encoder, and pooler
attn_pdrop  :  The dropout ratio for the attention probabilities.
"""
function albert_transformer(emb::Int,size::Int, head::Int, ps::Int, layer::Int,inner_group::Int,no_hidden_group::Int; act = gelu, pdrop = 0.1, attn_pdrop = 0.1)
    albert_transformer(
    Dense(emb,size),
    [ALGroup(size, head, ps,layer,inner_group,act = act ,pdrop= pdrop ,attn_pdrop = attn_pdrop) for i in 1:no_hidden_group],
    layer,
    inner_group,
    no_hidden_group
    )
end
function (altrans::albert_transformer)(x::T, mask=nothing; all::Bool=false) where T
   hidden_states = @toNd altrans.linear(x)
   for i in 1:altrans.no_hid
        layer_per_group = floor(altrans.no_hid/altrans.no_group)
        group_idx = Int(floor(i/( (altrans.no_hid + 1) / altrans.no_group))) + 1
        hidden_states = altrans.al[group_idx](hidden_states,mask,all = all)
        if all
            hidden_states = altrans.al(hidden_states,mask,all = all)[1]
        end
    end
    return(hidden_states)
end

"""
    masklmloss(embed::Embed{T}, transform,
               t::AbstractArray{T, N}, posis::AbstractArray{Tuple{Int,Int}}, labels) where {T,N}
    masklmloss(embed::Embed{T}, transform, output_bias,
               t::AbstractArray{T, N}, posis::AbstractArray{Tuple{Int,Int}}, labels) where {T,N}

helper function for computing the maks language modeling loss.
Performance `transform(x) .+ output_bias` where `x` is the mask specified by
`posis`, then compute the similarity with `embed.embedding` and crossentropy between true `labels`.
"""
function masklmloss(embed::Embed{T}, transform, t::AbstractArray{T, N}, posis::AbstractArray{Tuple{Int,Int}}, labels) where {T,N}
  masktok = gather(t, posis)
  sim = logsoftmax(transpose(embed.embedding) * transform(masktok))
  return logcrossentropy(labels, sim)
end

function masklmloss(embed::Embed{T}, transform, output_bias, t::AbstractArray{T, N}, posis::AbstractArray{Tuple{Int,Int}}, labels) where {T,N}
  masktok = gather(t, posis)
  sim = logsoftmax(transpose(embed.embedding) * transform(masktok) .+ output_bias)
  return logcrossentropy(labels, sim)
end
# output basic structure of albert transfomer
function Base.show(io::IO, altrans::albert_transformer)
  hs = div(size(altrans.al[1].ts[1].mh.iqproj.W)[1], altrans.al[1].ts[1].mh.head)
  h, ps = size(altrans.al[1].ts[1].pw.dout.W)

  print(io, "albert(")
  print(io, "layers=$(altrans.no_hid), ")
  print(io, "head=$(altrans.al[1].ts[1].mh.head), ")
  print(io, "head_size=$(hs), ")
  print(io, "pwffn_size=$(ps), ")
  print(io, "size=$(h))")
end
