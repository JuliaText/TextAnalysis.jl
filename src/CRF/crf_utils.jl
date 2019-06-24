# More stable implementation as exponentiation creates large nos.
# where m = maximum(z, dims = 2)
log_sum_exp(z, m ) = log.(sum((exp.(z .- m)), dims = 2)) .+ m
log_sum_exp(z) = log_sum_exp(z, maximum(z, dims = 2))
