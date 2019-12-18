"""
    log_sum_exp(z::Array)

A stable implementation f(x) = log ∘ sum ∘ exp (x).
Since exponentiation can lead to very large numbers.
"""
log_sum_exp(z) = log_sum_exp(z, maximum(z, dims = 1))
log_sum_exp(z, m) = log.(sum(exp.(z .- m), dims = 1)) .+ m
