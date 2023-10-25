
"""
    weighted_lcs(X, Y, weight_score::Bool, returns_string::Bool, weigthing_function::Function)

Compute the Weighted Longest Common Subsequence of X and Y.
"""
function weighted_lcs(X, Y, weighted=true, f=sqrt)
    result = weighted_lcs_inner(X, Y, weighted, f)

    return result.c_table[end, end]
end

function weighted_lcs_tokens(X, Y, weighted=true, f=sqrt)
    m, n, c_table, _w_table = weighted_lcs_inner(X, Y, weighted, f)

    # if weighted == true 
    #     lcs_length = c_table[m, n]^(2) # ?....
    # end
    lcs_length = m
    lcs = String["" for i in 1:(lcs_length+1)]
    i = m + 1
    j = n + 1

    while i > 1 && j > 1
        if X[i-1] == Y[j-1]
            lcs[lcs_length+1] = X[i-1]
            i -= 1
            j -= 1
            lcs_length -= 1
        elseif c_table[i-1, j] > c_table[i, j-1]
            i -= 1
        else
            j -= 1
        end
    end

    return lcs  # the lcs string
end

function weighted_lcs_inner(X, Y, weighted=true, f=sqrt)
    m, n = length(X), length(Y)
    c_table = zeros(Float32, m + 1, n + 1)
    w_table = zeros(Int32, m + 1, n + 1)
    increment = 1

    for i in 2:(m+1)
        for j in 2:(n+1)
            if X[i-1] == Y[j-1]
                k = w_table[i-1, j-1]
                if weighted == true
                    increment = (f(k + 1)) - (f(k))
                end
                c_table[i, j] = c_table[i-1, j-1] + increment
                w_table[i, j] = k + 1
            else
                c_table[i, j] = max(c_table[i-1, j], c_table[i, j-1])
                # w_table[i, j] = 0  # no match at i,j
            end
        end
    end

    (m=m, n=n, c_table=c_table, w_table=w_table)
end


"""
    fmeasure_lcs(RLCS, PLCS, β)

Compute the F-measure based on WLCS.

# Arguments

- `RLCS` - Recall Factor
- `PLCS` - Precision Factor
- `β` - Parameter
"""
function fmeasure_lcs(RLCS::Real, PLCS::Real, β=1.0)::Real
    divider = RLCS + (β^2) * PLCS
    return iszero(divider) ? 0.0 : (1 + β^2) * RLCS * PLCS / divider
end
