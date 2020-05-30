#TO DO 
# Doc string
function maskedscore(m::Langmodel,temp_lm::DefaultDict,word,context)
   score(m,temp_lm,lookup(m.vocab ,[word])[1] ,lookup(m.vocab ,[context])[1])
end

function logscore(m::Langmodel,temp_lm::DefaultDict,word,context)
    log2(maskedscore(m,temp_lm,word,context))
end

function entropy(m::Langmodel,lm::DefaultDict,text_ngram)
    local log_set=Float64[]
    for ngram in text_ngram
        ngram = split(ngram)
        push!(log_set,logscore(m,lm,ngram[end],join(ngram[1:end-1]," ")))
        #println(logscore(m,lm,ngram[end],ngram[1:end-1]))
    end
    return(sum(log_set)/length(log_set))
end

function perplexity(m::Langmodel,lm::DefaultDict,text_ngram)
    return(2^(entropy(m,lm,text_ngram)))
end
