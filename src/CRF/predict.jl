# Decoding is done by using Viterbi Algorithm
# Computes in polynomial time

"""
Scores for the first tag in the tagging sequence.
"""
function preds_first(c::CRF, y)
    c.W[c.n + 1, onecold(y, 1:length(y))]
end

"""
Scores for the last tag in the tagging sequence.
"""
function preds_last(c::CRF, y)
    c.W[onecold(y, 1:length(y)), c.n + 2]
end

"""
Scores for the tags other than the starting one.
"""
function preds_single(c::CRF, y, y_prev)
    c.W[onecold(y_prev, 1:length(y_prev)), onecold(y, 1:length(y))]
end

# Helper for forward pass, returns max_probs and corresponding arg_max for all the labels
function forward_pass_unit(k)
    α_idx = [i[1]  for i in argmax(k, dims=1)]
    α = [k[j, i] for (i,j) in enumerate(α_idx)]
    return α, α_idx
end

"""
Computes the forward pass for viterbi algorithm.
"""
function _decode(c::CRF, x, init_vit_vars)
    α_idx = zeros(Int, c.n + 2, length(x))

    forward_var, α_idx[:, 1] = forward_pass_unit(Tracker.data((c.W .+ x[1]') .+ init_vit_vars))

    for i in 2:length(x)
        forward_var, α_idx[:, i] = forward_pass_unit(Tracker.data((c.W .+ x[i]') .+ forward_var'))
    end

    labels = zeros(Int, length(x))
    labels[end] = argmax(forward_var + Tracker.data(c.W[:, c.n + 2])')[2]

    for i in reverse(2:length(x))
        labels[i - 1] =  α_idx[labels[i], i]
    end

    @assert α_idx[labels[1], 1] == c.n + 1 # Check for START Tag
    return onehotseq(labels, c.n)
end

onehotseq(seq, num_labels) = [onehot(i, 1:num_labels) for i in seq]

"""
    viterbi_decode(::CRF, input_sequence)

Predicts the most probable label sequence of `input_sequence`.
"""
function viterbi_decode(c::CRF, x_seq, init_vit_vars)
    length(x_seq) == 0 && throw("Input sequence is empty")
    return _decode(cpu(c), cpu.(x_seq), cpu(init_vit_vars))
end

# function predict(c::CRF, x_seq)
#     viterbi_decode(c, x_seq)
# end
