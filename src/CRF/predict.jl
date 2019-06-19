# Decoding is done by using Viterbi Algorithm
# as it computes in polynomial time

"""
Probabilities for the first tag in the tagging sequence.
"""
function preds_first(a::CRF, x)
    s, f = a.s, a.f
    dot.(f(x), s)
end

"""
Probabilities for the tags other than the starting one.
"""
function preds_single(a::CRF, x)
    W, b, f = a.W, a.b, a.f
    f(x) * W + b
end

# TODO: Parallel
# Helper for forward pass, returns max_probs and corresponding arg_max for all the labels
function forward_unit_max(a::CRF, x, prev)
    preds = log_sum_exp(preds_single(a, x) .+ prev)

    max_values = zeros(length(prev))
    label_indices = zeros(length(prev))

    for j in 1:length(prev)
        k = preds[:, j:j + length(prev) - 1]
        i = ceil(j/length(prev))

        max_values[i], label_indices[i] = findmax()
    end

    return log_sum_exp(max_values), label_indices
end

"""
Computes the forward pass for viterbi algorithm.
"""
function forward_pass(a::CRF, x)
    α_val = log_sum_exp(preds_first(a, x[1, :]))
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
function backward_pass(a::CRF, (α_idx_last, α_idx))[
    labels = zeros(size(α_idx,1))
    labels[end] = α_idx_last

    for i in reverse(1:size(α_idx,1) - 1)
        labels[i] = α_idx[labels[i + 1]]
    end
end

"""
    viterbi_decode(::CRF, input_sequence)

Predicts the most probable label sequence of `input_sequence`.
"""
function viterbi_decode(a::CRF, x_seq::Array{Number, 2})
    size(x_seq,1) == 0 && throw("Input sequence is empty")
    α_star, α_max = backward_pass(a, forward_pass(a, x_seq))
end

function predict(a::CRF, x_seq)
    viterbi_decode(a, x_seq)
end
