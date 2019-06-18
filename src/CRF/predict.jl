# Decoding is done by using Viterbi Algorithm
# as it computes in polynomial time

"""
Probabilities for the first tag in the tagging sequence.
"""
function preds_first(a::CRF, x)
    s, f = a.s, a.f
    f(x) * s
end

"""
Probabilities for the tags other than the starting one.
"""
function preds_single(a::CRF, x)
    W, b, f = a.W, a.b, a.f
    f(x) * W + b
end

# """
# Compute the (normalized) probability of
# a particular label sequence for given inputs sequence.
# """
# function label_sequence_pred(a::CRF, x_seq, label_seq)
#     length(x_seq) == length(label_seq) || throw("Lengths of input sequence and labels, do not match")
#     length(x_seq) == 0 && throw("Lengths of input sequence is zero")
#
#     forward_mat = zeros(length(x_seq), size(a.s, 2))
#     forward_mat[1] = preds_firstLinearAlgebra(a, x_seq[1])
#
#      for i in 2:length(x_seq)
#         forward_mat[i,:] = log_sum_exp(preds_single(a,x_seq[i]) + forward_mat[i-1])
#     end
# end

# Helper for forward pass, returns max_probs and corresponding arg_max for all the labels
function forward_unit_max(a::CRF, x, prev)
    preds = preds_single(a, x)

    max_values = zeros(length(prev))
    label_indices = zeros(length(prev))

    for j in range(1, step=length(prev), size(a.W, 2))
        k = preds[j:j + length(prev) - 1]
        i = ceil(j/length(prev))
        max_values[i], label_indices[i] = findmax(maxprev .* k)
    end
    return max_values, label_indices
end

function forward_pass(a::CRF, x_seq)
    α_val = zeros(length(x_seq), size(a.s, 2))
    α_max = zeros(length(x_seq), size(a.s, 2))

    α_val[1,:] = findmax(preds_first(a, x_seq[1])

    for i in 2:length(x_seq)
        α_val[i,:], α_max[i,:] = forward_unit_max(a, x[i], α_1[i-1,:])
    end
end

function backward_pass(a::CRF, α_val, α_max)

    # for last element, simply look up α

end
"""
Predict the most probable label sequence.
"""
function viterbi_decode(a::CRF, x_seq)
    length(x_seq) == 0 && throw("Input sequence is empty")
    α_star, α_max = backward_pass(a, forward_pass(a,x_seq))
end
