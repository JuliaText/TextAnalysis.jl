"""
    forward_score(c::CRF, x::Array)

Compute the Normalization / partition function
or the Forward Algorithm score - `Z`
"""
function forward_score(c::CRF, x, init_α)
    forward_var = log_sum_exp((c.W .+ x[1]') .+ init_α)

    for i in 2:length(x)
        forward_var = log_sum_exp((c.W .+ x[i]') .+ forward_var')
    end

    return log_sum_exp(c.W[:, c.n + 2] + forward_var')[1]
end

"""
    score_sequence(c::CRF, xs, label_seq)

Calculating the score of the desired `label_seq` against sequence `xs`.
Not exponentiated as required for negative log likelihood,
thereby preventing operation.

`label_seq`<:Array/ CuArray
eltype(label_seq) = Flux.OneHotVector
"""
function score_sequence(c::CRF, x, label_seq)
    score = preds_first(c, label_seq[1]) + onecold(label_seq[1], x[1])

    for i in 2:length(label_seq)
        score += preds_single(c, label_seq[i], label_seq[i-1]) +
                    onecold(label_seq[i], x[i])
    end

    return score + preds_last(c, label_seq[end])
end

# REGULARIZATION TERM
crf_loss(c::CRF, x, label_seq, init_α) = forward_score(c, x, init_α) - score_sequence(c, x, label_seq)
