using Flux
using Flux.Tracker
using Flux: params, identity

# First input sequence
# Layer for W, b:weights and biases
# Then calculate prob for the input sequence  W
# Then calculate loss and then update.

"""
Linear Chain - CRF Layer.

For input sequence `x`,
predicts the most probable tag sequence `y`,
over the set of all possible tagging sequences `Y`.
````
"""
mutable struct CRF{S} # Calculates Argmax( log ∑ )
    W::S    # Array{Float32,2} # Size of W = Number of feature
    b::S    # Array{Float32,2} # b is of `n` length2
    f::Function # Feature function
end

CRF(num_labels::Int, num_features::Int) = CRF(num_labels::Int, num_features::Int, identity)

function CRF(num_labels::Int, num_features::Int, f::Function;
             initW = glorot_uniform, initb = zeros)
    return CRF(param(initW(num_features, num_labels * num_labels)),
                param(initb(num_features, num_labels * num_labels)), f)
end

function (a::CRF)(x)
    W, b, f = a.W, a.b, a.f
    W*f(x) .+ b
end

function Base.show(io::IO, l::CRF)
    print(io, "CRF with ", Int(sqrt(size(l.W, 2))), " distinct tags and ",
            size(l.W,1), " input features and feature function ",
            print(io, l.f))
end
