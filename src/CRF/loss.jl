# For stable implementation, done in log space
# Normalization / partition function / Forward Algorithm score - `Z`
function forward_algorithm_stable(c::CRF, x)
    log_α_forward = preds_first(c, x[1])

    for i in 2:length(x)
        log_α_forward = log_sum_exp(log_α_forward .+ preds_single(c, x[i])')
    end

    return log(sum(exp.(log_α_forward)))
end

function forward_algorithm(c::CRF, x)
    log_α_forward = exp.(preds_first(c, x[1]))

    for i in 2:length(x)
        log_α_forward = log_α_forward * exp.(preds_single(c, x[i]))
    end

    return sum(log_α_forward)
end
# Calculating the score of the desired label_seq against input_seq.
# Not exponentiated as required for negative log likelihood,
# thereby preventing operation
#### Does not return exponentiated score.
function score_sequence(c::CRF, input_seq, label_seq)
    score = sum(preds_first(c, input_seq[1])' .* label_seq[1])

    for i in 2:length(label_seq)
        score += sum(preds_single(c, input_seq[i]) .* (label_seq[i-1] * label_seq[i]'))
    end
    return score
end

# REGULARIZATION TERM AND EMISSION SCORES

"""
The partition function is needed to reduce the score_sequence
to probabilities ( b/w 0 and 1 )
"""
crf_loss(c::CRF, input_seq, label_seq) = log(forward_algorithm(c, input_seq)) -
                                         score_sequence(c, input_seq, label_seq)
