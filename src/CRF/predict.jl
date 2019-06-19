# Decoding is done by using Viterbi Algorithm
# as it computes in polynomial time

"""
Probabilities for the first tag in the tagging sequence.
"""
function preds_first(a::CRF, x)
    s, f = a.s, a.f
    sum(s .* f(x), dims=1)
end

"""
Probabilities for the tags other than the starting one.
"""
function preds_single(a::CRF, x)
    W, b, f = a.W, a.b, a.f
    sum(W .* f(x) + b, dims=1)
end

# TODO: Parallel
# Helper for forward pass, returns max_probs and corresponding arg_max for all the labels
function forward_unit_max(a::CRF, x, prev)
    preds = preds_single(a, x)
    n = length(prev)

    max_values = zeros(n)
    label_indices = zeros(n)

    for j in range(1, step=n, length(preds))
        i = Int(ceil(j/n))
        k = preds[j:j + n - 1] + prev
        max_values[i], label_indices[i] = findmax(k.data)
    end

    return max_values, label_indices
end

"""
Computes the forward pass for viterbi algorithm.
"""
function forward_pass(a::CRF, x)
    α_val = dropdims(preds_first(a, x[1,:]), dims=1)
    α_idx = zeros(size(x, 1), size(a.s, 2))

    for i in 2:size(x, 1)
        α_val, α_idx[i,:] = forward_unit_max(a, x[i, :], α_val)
    end

    return findmax(α_val)[2], α_idx
end

# TODO: Speeding up.
"""
Computes the forward pass for viterbi algorithm.
"""
function backward_pass(a::CRF, (α_idx_last, α_idx))
    labels = Array{Int32, 1}(undef, size(α_idx,1))
    labels[end] = α_idx_last

    for i in reverse(2:size(α_idx,1))
        labels[i-1] =  α_idx[i, labels[i]]
    end

    return reverse(labels)
end

"""
    viterbi_decode(::CRF, input_sequence)

Predicts the most probable label sequence of `input_sequence`.
"""
function viterbi_decode(a::CRF, x_seq::Array{Any, 1})
    size(x_seq,1) == 0 && throw("Input sequence is empty")
    α_star, α_max = backward_pass(a, forward_pass(a, x_seq))
end

function predict(a::CRF, x_seq)
    viterbi_decode(a, x_seq)
end
