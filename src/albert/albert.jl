using Flux: @functor
using MacroTools: @forward

using Transformers.Basic
using Transformers.Basic: AbstractTransformer
using Transformers.Stacks

struct albert <: AbstractTransformer
  ts::Stack
end

@functor albert

@forward albert.ts Base.getindex, Base.length

"""
    albert(size::Int, head::Int, ps::Int, layer::Int;
        act = gelu, pdrop = 0.1, attn_pdrop = 0.1)
    albert(size::Int, head::Int, hs::Int, ps::Int, layer::Int;
        act = gelu, pdrop = 0.1, attn_pdrop = 0.1)

the Bidirectional Encoder Representations from Transformer(ALBERT) model.


    (bert::albert)(x, mask=nothing; all::Bool=false)

eval the albert layer on input `x`. If length `mask` is given (in shape (1, seq_len, batch_size)), mask the attention with `getmask(mask, mask)`. Moreover, set `all` to `true` to get all
outputs of each transformer layer.
"""
function albert(size::Int, head::Int, ps::Int, layer::Int;
              act = gelu, attn_pdrop = 0)
  rem(size,  head) != 0 && error("size not divisible by head")
  albert(size, head, div(size, head), ps, layer; act=act, attn_pdrop=attn_pdrop)
end

function albert(size::Int, head::Int, hs::Int, ps::Int, layer::Int; act = gelu, attn_pdrop = 0)
  albert(
    Stack(
      @nntopo_str("((x, m) => x':(x, m)) => $layer"),
      [
        Transformer(size, head, hs, ps; future=true, act=act, pdrop=attn_pdrop)
        for i = 1:layer
      ]...
    )
         )
end

function (al::albert)(x::T, mask=nothing; all::Bool=false) where T
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


function Base.show(io::IO, al::albert)
  hs = div(size(al.ts[1].mh.iqproj.W)[1], al.ts[1].mh.head)
  h, ps = size(al.ts[1].pw.dout.W)

  print(io, "albert(")
  print(io, "layers=$(length(al.ts)), ")
  print(io, "head=$(al.ts[1].mh.head), ")
  print(io, "head_size=$(hs), ")
  print(io, "pwffn_size=$(ps), ")
  print(io, "size=$(h))")
end
