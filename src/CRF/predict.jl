# Decoding is done by using Viterbi Algorithm
# as it computes in polynomial time

"""
Probabilities for the first tag in the tagging sequence.
"""
function preds_first(a::CRF, x)
    s, f = a.s, a.f
    f(x) * s
end

# TODO: Improve speed, by reducing unnecessary operations.
"""
Probabilities for the tags other than the starting one.
"""
function preds_single(a::CRF, x)
    W, b, f = a.W, a.b, a.f
    f(x) * W + b
end

"""
Return the (normalized) probability of
a particular label sequence for given inputs sequence.
"""
function label_sequence_pred(a::CRF, x_seq, label_seq)
    length(x_seq) == 0 && throw("Lengths of input sequence and labels, do not match")
end

"""
Predict the most probable label sequence.
"""
function viterbi_decode(a::CRF, x_seq, mode = "label")
end
