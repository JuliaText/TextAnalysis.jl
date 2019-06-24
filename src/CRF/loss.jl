unit_scores(a::CRF, x, prev) = log_sum_exp(preds_single(a, x) .+ prev')

# For stable implementation, done in log space
function forward_algorithm(a::CRF, x)
    log_α_forward = log(sum(preds_first(a, x[:,1])))

    for i in 2:size(x, 2)
        log_α_forward = unit_scores(a, x[:,1], log_α_forward)
    end

    # println(log_α_forward)
    # println("_____--------------------____________---")
    return log_α_forward
end

# Normalization (partition) function - `Z`
partition_function(a::CRF, input_seq, label_seq) = sum(exp.(forward_algorithm(a, input_seq)))

# Calculating the score of the desired label_seq against input_seq.
function score_sequence(a::CRF, input_seq, label_seq)
    score = sum(preds_first(a, input_seq[:, 1])' .* label_seq[1])

    for i in 2:length(label_seq)
        score *= sum(preds_single(a, input_seq[:, i]) .* (label_seq[i] * label_seq[i-1]'))
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
