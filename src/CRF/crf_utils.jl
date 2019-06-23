# More stable implementation as exponentiation creates large nos.
function log_sum_exp(z)
    # @assert eltype(z) <: Number
    m = maximum(z)
    global kkk
    kkk = z
    println(log(sum(exp.(z .- m))))
    println(m)
    log(sum(exp.(z .- m))) + m
end
