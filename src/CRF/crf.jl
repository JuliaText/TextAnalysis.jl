using Flux
using Flux.Tracker
using Flux: params, identity, @treelike
using LinearAlgebra

"""
Linear Chain - CRF Layer.

For input sequence `x`,
predicts the most probable tag sequence `y`,
over the set of all possible tagging sequences `Y`.
"""
mutable struct CRF{S,A, F} # Calculates Argmax( log ∑ )
    W::S    # TrackedArray{Float32,2} # Size of W = Number of feature
    b::S    # TrackedArray{Float32,2} # b is of `n` length
    s::A    # For the first element.
    f::F    # Feature function
end

CRF(num_labels::Integer, num_features::Integer) = CRF(num_labels::Integer, num_features::Integer, identity)

function CRF(num_labels::Integer, num_features::Integer, f::Function;
            initW = rand, initb = zeros, inits = rand)
    return CRF(param(initW(num_features, num_labels, num_labels)),
                param(initb(num_features, num_labels, num_labels)),
                param(inits(num_features, num_labels)), f)
end

function Base.show(io::IO, l::CRF)
    print(io, "CRF with `", size(l.W, 2), "` distinct tags and `",
            size(l.W,1), "` input features and feature function `",
            l.f,"`")
end

function (a::CRF)(x_seq)
    viterbi_decode(a, x_seq)
end
