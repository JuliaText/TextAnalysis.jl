# The jackknife is a resampling technique especially useful for variance and bias estimation.
"""
    jackknife_avg(`scores`)

Apply jackknife on the input list of `scores`
"""
function jackknife_avg(scores)
    if length(collect(Set(scores))) == 1
        #= In case the elements of the array are all equal=#
        return scores[1]
    else
        #=store the maximum scores
        from the m different sets of m-1 scores.
        such that m is the len(score_list)=#
        average = []
        for i in scores
            # dummy : list a particular combo of m-1 scores
            dummy = [j for j in scores if i != j]
            append!(average, max(dummy...))
            end

        return sum(average)/length(average)
    end
end

"""
    weighted_lcs(X, Y, weight_score::Bool, returns_string::Bool, weigthing_function::Function)

Compute the Weighted Longest Common Subsequence of X and Y.
"""
function weighted_lcs(X, Y, weighted=true, f=sqrt)
    result = weighted_lcs_inner(X, Y, weighted, f)

    return result.lcs_length
end

function weighted_lcs_tokens(X, Y, weighted=true, f=sqrt)
    m, n, c_table, w_table, lcs_length = weighted_lcs_inner(X, Y, weighted, f)

    # if weighted == true 
    #     lcs_length = c_table[m, n]^(2) # ?....
    # end

    lcs = ["" for i in 1:(lcs_length+1)]
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
    c_table = zeros(Int32, m + 1, n + 1)
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
                w_table[i, j] = 0  # no match at i,j
            end
        end
    end

    (m=m, n=n, c_table=c_table, w_table=w_table, lcs_length=c_table[m+1, n+1])
end


"""
    fmeasure_lcs(RLCS, PLCS, β)

Compute the F-measure based on WLCS.

# Arguments

- `RLCS` - Recall Factor
- `PLCS` - Precision Factor
- `β` - Parameter
"""
function fmeasure_lcs(RLCS, PLCS, β=1)
    try
        return ((1 + β^2) * RLCS * PLCS) / (RLCS + (β^2) * PLCS)
    catch ex
        if ex isa DivideError
            return 0
        else
            rethrow(ex)
        end
    end
end
