"""
    rouge_n(references::Array{T}, candidate::AbstractString, n; avg::Bool, lang::Language) where T<: AbstractString

Compute n-gram recall between `candidate` and the `references` summaries.

See [Rouge: A package for automatic evaluation of summaries](http://www.aclweb.org/anthology/W04-1013)

See also: [`rouge_l_sentence`](@ref), [`rouge_l_summary`](@ref)
"""
function rouge_n(references, candidate, n; avg = true, lang = Languages.English())
    ng_candidate = ngramize(lang, candidate, n)
    ng_refs = [ngramize(lang, ref, n) for ref in references]

    rouge_recall = Array{Float64,1}()
    for ref in ng_refs
        push!(rouge_recall, rouge_match_score(keys(ref), ng_candidate) / sum(values(ref)) )
    end

    avg == true && return jackknife_avg(rouge_recall)
    return rouge_recall
end

function rouge_match_score(ref, candidate::Dict)
    matches = 0
    for p in keys(candidate)
        p ∉ ref && continue
        matches += candidate[p]
    end
    return matches
end

"""
    rouge_l_sentence(references, candidate, β, average)

Calculate the ROUGE-L score between `references` and `candidate` at sentence level.

See [Rouge: A package for automatic evaluation of summaries](http://www.aclweb.org/anthology/W04-1013)

See also: [`rouge_n`](@ref), [`rouge_l_summary`](@ref)
"""
function rouge_l_sentence(references, candidate, β=8, average = true)
    ngram_cand = tokenize(Languages.English(), candidate)
    rouge_l_list = []

    for ref in references
        ngram_ref = tokenize(Languages.English(), ref)
        r_lcs = weighted_lcs(ngram_ref, ngram_cand, true, false, sqrt) / length(ngram_ref)
        p_lcs = weighted_lcs(ngram_ref, ngram_cand, true, false, sqrt) / length(ngram_cand)
        score = fmeasure_lcs(r_lcs, p_lcs, β)
        push!(rouge_l_list, score)
    end

    if average == true
        rouge_l_list = jackknife_avg(rouge_l_list)
    end
    return rouge_l_list
end

"""
    rouge_l_summary(references, candidate, β, average)

Calculate the ROUGE-L score between `references` and `candidate` at summary level.

See [Rouge: A package for automatic evaluation of summaries](http://www.aclweb.org/anthology/W04-1013)

See also: [`rouge_l_sentence()`](@ref), [`rouge_l_summary`](@ref)
"""
function rouge_l_summary(references, candidate, β, averaging=true)
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
            sum_value += length(unique(l_))
        end

        r_lcs = sum_value / length(tokenize(Languages.English(), ref))
        p_lcs = sum_value / length(tokenize(Languages.English(), candidate))
        score = fmeasure_lcs(r_lcs, p_lcs, β)
        push!(rouge_l_list,score)
    end

    averaging == true && return jackknife_avg(rouge_l_list)
    return rouge_l_list
end
