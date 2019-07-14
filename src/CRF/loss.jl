# For stable implementation, done in log space
# Normalization / partition function / Forward Algorithm score - `Z`
function forward_algorithm(c::CRF, x)
    log_α_forward = exp.(preds_first(c, x[1]))

    for i in 2:length(x)
        log_α_forward = log_α_forward * exp.(preds_single(c, x[i]))
    end
    return log_sum_exp(log_α_forward)
end

# forward_algorithm_score(c::CRF, input_seq) = log_sum_exp(forward_algorithm(c, input_seq))

# Calculating the score of the desired label_seq against input_seq.
# Not exponentiated as required for leg log likelihood,
# thereby preventing operation
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
crf_loss(c::CRF, input_seq, label_seq) = forward_score(c, input_seq) -
                                         score_sequence(c, input_seq, label_seq)
