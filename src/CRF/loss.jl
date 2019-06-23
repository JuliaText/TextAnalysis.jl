function forward_pass_unit(a::CRF, x, prev)
    preds = preds_single(a, x)
    n = length(prev)

    unit_scores = zeros(n)
    for j in range(1, step=n, length(preds))
        unit_scores[Int(ceil(j/n))] = log_sum_exp(preds[j:j + n - 1] + prev)
    end

    return unit_scores
end

# For stable implementation, done in log space
function forward_pass(a::CRF, input_seq)
    log_α_forward#=[i,:]=# =  repeat(log.(sum((dropdims(preds_first(a, x[1,:]), dims=1)),
                                        dims = 1)), 3)

    for i in 2:size(x, 1)
        log_α_forward = forward_pass_unit(a, x[i, :], log_α_forward)
    end

    return log_α_forward
end

# Normalization (partition) function - `Z`
function partition_function(a::CRF, input_seq, label_seq)
    return log(sum.(forward_pass(a, input_seq)))
end

# TODO: Check for possible speedups.
# Calculating the score of the desired label_seq against input_seq.
function score_sequence(a::CRF, input_seq, label_seq)
    score = preds_first(a, input_seq[1])' * label_seq[1]

    for i in 2:length(input_seq)
        score *= preds_single(a, input_seq[i])' * (label_seq[i-1]' * label_seq[i]')
    end

    return score
end

"""
The partition function is needed to reduce the score_sequence
to probabilities ( b/w 0 and 1 )
"""
function crf_loss(a::CRF, input_seq, label_seq)
    return -log(score_sequence(a, input_seq, label_seq) /
                partition_function(a, input_seq, label_seq))
end
