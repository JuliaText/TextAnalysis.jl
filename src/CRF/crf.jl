using Flux
using Flux: param, identity, onehot, onecold, @treelike

"""
Linear Chain - CRF Layer.

For input sequence `x`,
predicts the most probable tag sequence `y`,
over the set of all possible tagging sequences `Y`.

In this CRF, two kinds of potentials are defined,
emission and Transition.
"""
mutable struct CRF{S}
    W::S        # Transition Scores
    n::Int      # Num Labels
end

"""
Second last index for start tag,
last one for stop tag .
"""
function CRF(n::Integer; initW=rand)
    W = initW(n + 2, n + 2)
    W[:, n + 1] .= -10000
    W[n + 2, :] .= -10000

    return CRF(param(W), n)
end

function Base.show(io::IO, c::CRF)
    print(io, "CRF with ", c.n + 2, " distinct tags (including START and STOP tags).")
end

function (a::CRF)(x_seq)
    viterbi_decode(a, x_seq)
end
