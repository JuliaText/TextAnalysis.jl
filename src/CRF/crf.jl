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
mutable struct CRF # Calculates Argmax( log ∑ )
    num_labels::Int # number of possible tags / labels, including Start and End
    num_features::Int
    W::Array{Float32,2} # Size of W = Number of feature
    b::Array{Float32,2} # b is of `n` length2
    f::Function # Feature function
end

function CRF(num_labels::Int, num_features::Int, f::Function)
    return CRF(num_labels, num_features, rand(num_features, num_labels * num_labels),
                rand(num_features, num_labels * num_labels), f)
end
