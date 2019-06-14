function log_sum_exp(z)
    @assert eltype(z) <: Number
    m = maximum(z)
    log(sum(exp.(z .- m)))
end
