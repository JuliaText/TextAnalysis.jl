function forward_algo_unit(a::CRF, x, prev)
    preds = preds_single(a, x)
    n = size(a.s, 2)
    println("----------------")

    unit_scores = []
    global kkk
    kkk = preds

    for j in range(1, step=n, length(preds))
        push!(unit_scores, log_sum_exp(preds[j:j + n - 1] .+ prev))
    end

    println(unit_scores)
    println(typeof(unit_scores))
    return unit_scores
end

# For stable implementation, done in log space
function forward_algorithm(a::CRF, x)
    log_α_forward = log(sum(preds_first(a, x[:,1])))

    for i in 2:size(x, 2)
        log_α_forward = forward_algo_unit(a, x[:,1], log_α_forward)
    end
    sleep(10000)

    return log_α_forward
end

# Normalization (partition) function - `Z`
function partition_function(a::CRF, input_seq, label_seq)
    return log(sum.(forward_algorithm(a, input_seq)))
end

# TODO: Check for possible speedups.
# Calculating the score of the desired label_seq against input_seq.
function score_sequence(a::CRF, input_seq, label_seq)
    score = sum(preds_first(a, input_seq[:, 1])' .* label_seq[1])

    for i in 2:length(label_seq)
        score *= sum(preds_single(a, input_seq[:, i])' .*
                collect(Iterators.flatten((label_seq[i-1] * label_seq[i]')')))
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
