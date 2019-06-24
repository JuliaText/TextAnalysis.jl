# JuliaText TextAnalysis.jl Utility Functions

# The jackknife is a resampling technique especially useful for variance and bias estimation. 
#Currently being used for averaging in ROUGE scores in evaluate.jl
# :param scores: List of integers to average
#:type scores: Array{Int64,1}

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

# Returns an array of ngram tokens from the ngram doc. 
# param ngram_doc : Output from the function ngrams(StringDocument(text), n)
function listify_ngrams(ngram_doc)
    flattened = []
    for item in ngram_doc
        for i in 1:item[2]
            push!(flattened, item[1])
        end
    end
    return flattened
end

#This function returns the longest common subsequence
#of two strings using the dynamic programming algorithm.
# param X : first string in tokenized form
#type (X) : Array{SubString{String},1}
# param Y : second string in tokenized form
#type (Y) : Array{SubString{String},1}
# param weighted : Weighted LCS is done if weighted is True (default)
#type (weighted) : Boolean
# param return_string : Function returns weighted LCS length when set to False (default).
#                       Function returns longest common substring when set to True.
#type (return_string) : Boolean
# param f: weighting function. The weighting function f must have the property
#          that f(x+y) > f(x) + f(y) for any positive integers x and y. 
#type (f) : generic function which takes a float as an input and returns a float.

function weighted_lcs(X, Y, weighted = true, return_string = false, f = sqrt)
    
    
    m, n = length(X), length(Y)
    c_table = [zeros(n+1) for i in 1:m+1]
    w_table = [zeros(n+1) for i in 1:m+1]
    
    for i in 1:(m+1)
        
        for j in 1:(n+1)
            
            if i == 1 || j == 1
                continue
            
            elseif X[i-1] == Y[j-1]
                
                k = w_table[i-1][j-1]
                if weighted == true
                    increment = (f(k+1)) - (f(k)) 
                else
                    increment = 1
                end
                c_table[i][j] = c_table[i-1][j-1] + increment
                w_table[i][j] = k + 1
                
            else
                
                if c_table[i-1][j] > c_table[i][j-1]
                    c_table[i][j] = c_table[i-1][j]
                    w_table[i][j] = 0  # no match at i,j
                else
                    c_table[i][j] = c_table[i][j-1]
                    w_table[i][j] = 0  # no match at i,j
                end
            
            end
        
        end
    
    end
    
    lcs_length = (c_table[m+1][n+1])
    if return_string == false
        return lcs_length
    end
    
    if weighted == true
        lcs_length = c_table[m][n]^(2)
    end
    
    lcs_length = round(Int64, lcs_length)
    lcs_length = convert(Int64, lcs_length)
    lcs = ["" for i in  1:(lcs_length+1)]
    lcs[lcs_length+1] = ""
    i = m + 1
    j = n + 1
    
    while i>1 && j>1
        if X[i-1] == Y[j-1]
            lcs[lcs_length+1] = X[i-1]
            i -= 1
            j -= 1
            lcs_length -= 1

        elseif c_table[i-1][j] > c_table[i][j-1]
            i -= 1
        else
            j -= 1
        end
    end
    
    return (join(lcs, " "))  # the lcs string
end

     
# F-measure based on WLCS
# param beta : user defined parameter
#type (beta) : float
    
# param r_lcs : recall factor
#type (r_lcs) : float
   
# param p_lcs : precision factor
#type (p_lcs) : float
     
#score : f measure score between a candidate
#    	    and a reference
     
function fmeasure_lcs(RLCS, PLCS, beta=1)
    
    try
        return ((1+beta^2)*RLCS*PLCS)/(RLCS+(beta^2)*PLCS)
    catch ex
        if ex isa DivideError
            return 0
        else
            rethrow(ex)
        end
    end
end

# Calculates Word CoOccurence matrix. 
# The input to the function can be a single string with a window size
# based on which the co-occurence will be evaluated. A list of strings
# of variable window size can also be taken as input. 
# Returns a DataFrame which can be used to calculate the CoOccurence of a pair 
# of words easily. 
                    
# param inputDoc : string or array of strings
# param integer  : sliding window size. The number of words before and after 
#                  a token to be considered in context. 
# param stripStopwords : Whether to remove stopwords or not.
                    
# output : A NamedArray arr. arr[Word1, Word2] returns the co-occurrence value of
#          a pair of words. arr[Word, :] returns cooccurence value of Word with all 
#          other words
                  
function word_cooccurrence_matrix(inputDoc, window = 2, stripStopwords = false)
    if typeof(inputDoc) == String
        sd = StringDocument(lowercase(inputDoc))
        prepare!(sd, strip_punctuation)
        if stripStopwords == true
            prepare!(sd, strip_stopwords)
            sd = StringDocument(join([i for i in split(text(sd), " ") if i!= ""], " "))
        end
        sd = split(text(sd), " ")
        if length(sd) < 2*window + 1
                        throw(ArgumentError(string("Window Size is greater than the length of string provided\nPlease make sure that the value of 2*window+1 is lesser than the length of string provided.")))
        end
        candidate_list = []
        for item in enumerate(sd)
            if item[1] < length(sd) - 2 * window + 1 
                temp = []
                for i in range(1 , 2 * window + 1)
                    push!(temp,sd[item[1] + i - 1])
                end
                push!(candidate_list,temp)
            end
        end
    else
        if typeof(inputDoc) == Array{String,1}
            
            if window != 0
                candidate_list = []
                for doc in enumerate(inputDoc)
                    sd = StringDocument(lowercase(doc[2]))
                    prepare!(sd, strip_punctuation)
                    if stripStopwords == true
                        prepare!(sd, strip_stopwords)
                        sd = StringDocument(join([i for i in split(text(sd), " ") if i!= ""], " "))
                    end
                    sd = split(text(sd), " ")
                    if length(sd) < 2*window + 1
                        throw(ArgumentError(string("Window Size is greater than the length of document provided at index ", doc[1], "\nPlease make sure that the value of 2*window+1 is lesser than the minimum length of documents provided.")))
                    end
                    for item in enumerate(sd)
                        if item[1] < length(sd) - 2 * window + 1 
                            temp = []
                            for i in range(1 , 2 * window + 1)
                                push!(temp,sd[item[1] + i - 1])
                            end
                            push!(candidate_list,temp)
                        end
                    end
                end
            else
                candidate_list = []
                for doc in inputDoc
                    sd = StringDocument(lowercase(doc))
                    prepare!(sd, strip_punctuation)
                    if stripStopwords == true
                        prepare!(sd, strip_stopwords)
                        sd = StringDocument(join([i for i in split(text(sd), " ") if i!= ""], " "))
                    end
                    sd = split(text(sd), " ")
                    push!(candidate_list, sd)
                end
            end
            
        else 
            throw(ArgumentError("Argument must be a String or a List of Strings i.e Array{String,1}"))
        end
    end
    wordlist = sort(unique(split(join([join(i, " ") for i in candidate_list], " "), " ")))
    word_matrix = []
    for i in wordlist
        temp = [0 for i in range(1, length(wordlist))]
        matches = Dict()
        if window == 0
            temp = [0 for i in range(1, length(wordlist))]
            matches = Dict()
            for keywords in candidate_list
                if i in keywords
                    for token in keywords
                        if token in keys(matches)
                            matches[token] += 1
                        else
                            matches[token] = 1 
                        end
                    end
                end
            end
        else
            mid = window+1                                                                               
            for keywords in candidate_list
                if i == keywords[mid]
                    for token in keywords
                        if token in keys(matches)
                            matches[token] += 1
                        else
                            matches[token] = 1 
                        end
                    end
                else
                    if candidate_list[length(candidate_list)] == keywords                                                                   
                        for keyword in enumerate(keywords)                                                                               
                            if keyword[2] == i && keyword[1] > mid                                                                              
                                for token in keywords[keyword[1]-mid+1:length(keywords)]
                                    if token in keys(matches)
                                        matches[token] += 1
                                    else
                                        matches[token] = 1 
                                    end
                                end
                            end
                        end
                    end
                    if candidate_list[1] == keywords                                                                          
                        for keyword in enumerate(keywords)
                            if keyword[2] == i && keyword[1] < mid                                                                                
                                for token in keywords[1:keyword[1]+mid-1]
                                    if token in keys(matches)
                                        matches[token] += 1
                                    else
                                        matches[token] = 1 
                                    end
                                end
                            end
                        end
                    end                                                                                   
                end
            end
        end                                                                                               
        for key in keys(matches)
            indexes = [i[1] for i in enumerate(wordlist) if i[2] == key]
            for index in indexes
                temp[index]  = matches[wordlist[index]]
            end
        end
        if length(word_matrix) == 0
            word_matrix = temp
        else
            word_matrix = hcat(word_matrix, temp)
        end
    end   
    
    wordlist = convert(Array{String,1}, wordlist)                                                                                                        
    coom = NamedArray(word_matrix, (wordlist, wordlist), ("Rows", "Cols"))
    
    return(coom)                                                                                               
end
