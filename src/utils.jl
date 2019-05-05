# JuliaText TextAnalysis.jl Utility Functions

function jackknife_avg(scores)

    #= The jackknife is a resampling technique especially useful for variance and bias estimation. 
    Currently being used for averaging in ROUGE scores in evaluate.jl
    :param scores: List of integers to average
    :type scores: Array{Int64,1} =#
    
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
