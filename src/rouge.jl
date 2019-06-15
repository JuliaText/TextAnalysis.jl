# ROUGE score implementation
#Lin C.Y. , 2004
#Rouge: A package for automatic evaluation of summaries
#Proceedings of the workshop on text summarization branches out (WAS 2004) (2004), pp. 25-26
#Link to paper:
#http://www.aclweb.org/anthology/W04-1013 


#It is a n-gram recall between a candidate summary
#and a set of reference summaries.
        
# param references : list of reference strings
#type references : Array{String,1}
    
# param candidate :  the candidate string
#type (candidate) : Array{String,1} 
    
# param n : length of ngram
#type (n) : int
    
#ngram_cand : list of ngrams in candidate
#ngram_ref : list of ngrams in reference
#r_lcs : recall factor
#p_lcs : precision factor
#rouge_recall : list containing all the rouge-n scores for
#               every reference against the candidate

function rouge_n(references, candidate, n, averaging = true)

    ngram_cand = listify_ngrams(ngrams(StringDocument(candidate), n))
    rouge_recall = []
    
    for ref in references
        matches = 0  #variable counting the no.of matching ngrams
        ngram_ref = listify_ngrams(ngrams(StringDocument(ref), n))
        print(ngram_ref)
        
        for ngr in ngram_cand
            if ngr in ngram_ref
                matches += 1 
            end
            
        end
        
        push!(rouge_recall, matches/length(ngram_ref))
    
    end
    
    if averaging == true
        rouge_recall = jackknife_avg(rouge_recall)
    end

    return(rouge_recall)
end

# It calculates the rouge-l score between the candidate
#and the reference at the sentence level.
    
# param references : list of reference strings
#type references : Array{String,1}
    
# param candidate :  the candidate string
#type (candidate) : Array{String,1} 
    
# param beta : user-defined parameter. Default value = 8 
#type (beta) : float
    
#rouge_l_list : list containing all the rouge scores for
#                every reference against the candidate
#r_lcs : recall factor
#p_lcs : precision factor
#score : rouge-l score between the reference sentence and 
#        the candidate sentence 
            
function rouge_l_sentence(references, candidate, beta=8, averaging = true)
    
    ngram_cand = tokenize(Languages.English(), candidate)
    rouge_l_list = []

    for ref in references
        ngram_ref = tokenize(Languages.English(), ref)
        r_lcs = weighted_lcs(ngram_ref, ngram_cand,true, false, sqrt)/length(ngram_ref)
        p_lcs = weighted_lcs(ngram_ref, ngram_cand,true, false, sqrt)/length(ngram_cand)
        score = fmeasure_lcs(r_lcs, p_lcs, beta)
        push!(rouge_l_list,score)

    end
    if averaging == true
        rouge_l_list = jackknife_avg(rouge_l_list)
    end
    return rouge_l_list
end

#It calculates the rouge-l score between the candidate
#and the reference at the summary level.
# param references : list of reference summaries. Each of the summaries 
#                    must be tokenized list of words 
#type (references) : list
    
# param candidate : candidate summary tokenized into list of words
#type (candidate) : list
# param beta : user-defined parameter
#type (beta) : float
    
#rouge_l_list : list containing all the rouge scores for
#                every reference against the candidate
    
#r_lcs : recall factor
#p_lcs : precision factor
#score : rouge-l score between a reference and the candidate

function rouge_l_summary(references, candidate, beta, averaging=true)

    rouge_l_list = []
    cand_sent_list = split_sentences(candidate)
    
    for ref in references
        ref_sent_list = split_sentences(ref)
        sum_value = 0
    
        for ref_sent in ref_sent_list
            l_ = []
            arg1 = tokenize(Languages.English(), ref)
    
            for cand_sent in cand_sent_list
                arg2 = tokenize(Languages.English(), cand_sent)
                d = tokenize(Languages.English(), weighted_lcs(arg1, arg2, false, true, sqrt))
                append!(l_,d)
            end
    
            print(l_)
            sum_value = sum_value+length(unique(l_))
    
        end
    
        r_lcs = sum_value/length(tokenize(Languages.English(), ref))
        p_lcs = sum_value/length(tokenize(Languages.English(), candidate))
        score = fmeasure_lcs(r_lcs, p_lcs, beta)
        push!(rouge_l_list,score)
    
    end

    if averaging == true
        rouge_l_list = jackknife_avg(rouge_l_list)
    end

    return rouge_l_list
end
