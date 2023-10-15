#TO DO 
# Doc string
"""
$(TYPEDSIGNATURES)
"""
function maskedscore(m::Langmodel, temp_lm::DefaultDict, word, context)::Float64
   score(m, temp_lm, lookup(m.vocab, [word])[begin], lookup(m.vocab, [context])[begin])
end

"""
$(TYPEDSIGNATURES)
"""
function logscore(m::Langmodel, temp_lm::DefaultDict, word, context)::Float64
    log2(maskedscore(m, temp_lm, word, context))
end

"""
$(TYPEDSIGNATURES)
"""
function entropy(m::Langmodel, lm::DefaultDict, text_ngram::AbstractVector)::Float64
    n_sum = sum(text_ngram) do ngram
        ngram = split(ngram)
        logscore(m, lm, ngram[end], join(ngram[begin:end-1], " "))
    end
    return n_sum / length(text_ngram)
end

"""
$(TYPEDSIGNATURES)
"""
function perplexity(m::Langmodel, lm::DefaultDict, text_ngram::AbstractVector)::Float64
    return 2^(entropy(m, lm, text_ngram))
end
