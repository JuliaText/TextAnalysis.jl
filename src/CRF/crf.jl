using Flux
using Flux.Tracker
using Flux: params, identity
using LinearAlgebra

"""
Linear Chain - CRF Layer.

For input sequence `x`,
predicts the most probable tag sequence `y`,
over the set of all possible tagging sequences `Y`.
"""
mutable struct CRF{S,A} # Calculates Argmax( log ∑ )
    W::S    # Array{Float32,2} # Size of W = Number of feature
    b::S    # Array{Float32,2} # b is of `n` length
    s::A    # For the first element.
    f::Function # Feature function
end

CRF(num_labels::Int, num_features::Int) = CRF(num_labels::Int, num_features::Int, identity)

function CRF(num_labels::Int, num_features::Int, f::Function;
            initW = rand, initb = zeros, inits = rand)
    return CRF(param(initW(num_features, num_labels * num_labels)),
                param(initb(num_features, num_labels * num_labels)),
                param(inits(num_features, num_labels)), f)
end

function Base.show(io::IO, l::CRF)
    print(io, "CRF with `", Int(sqrt(size(l.W, 2))), "` distinct tags and `",
            size(l.W,1), "` input features and feature function `",
            l.f,"`")
end

function (a::CRF)(x_seq)
    viterbi_decode(a, x_seq)
end

# minimize `-log(p(y|X))`
# function crf_loss(a::CRF, input_seq, label_seq)
#     length(input_seq) == length(label_seq) &&
#             throw("The length of input and label sequence must match")
#
#     loss = 0
#
#     for (input, label) in zip(input_seq, label_seq)
#         loss += preds_single(a, input)
#
# end
