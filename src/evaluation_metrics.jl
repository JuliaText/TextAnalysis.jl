"""
A score with precision, recall and fmeasure
"""
struct Score
    precision::Float32
    recall::Float32
    fmeasure::Float32

    Score(precision::AbstractFloat, recall::AbstractFloat, fmeasure::AbstractFloat) =
        new(precision, recall, fmeasure)

    Score(; precision=0.0, recall=0.0, fmeasure=0.0) =
        new(precision, recall, fmeasure)
end

Base.show(io::IO, score::Score) = Base.write(io,
    string(
        "Score(precision=", score.precision,
        ", recall=", score.recall,
        ", fmeasure=", score.fmeasure,
        ")"
    )
)

"""
    average(scores::Vector{Score})::Score

Returns average values of scores by precision/recall/fmeasure separately
"""
function average(scores::Vector{Score})::Score
    res = reduce(scores, init=zeros(Float32, 3)) do acc, i
        acc + [
            i.precision
            i.recall
            i.fmeasure
        ]
    end
    Score((res ./ length(scores))...)
end

"""
    argmax(scores::Vector{Score})::Score

Returns maximum by precision value
"""
Base.argmax(scores::Vector{Score})::Score = argmax(s -> s.fmeasure, scores)

"""
    rouge_n(references::Vector{<:AbstractString}, candidate::AbstractString, n::Int; lang::Language)

Compute n-gram recall between `candidate` and the `references` summaries.

See [Rouge: A package for automatic evaluation of summaries](http://www.aclweb.org/anthology/W04-1013)

See also: [`rouge_l_sentence`](@ref), [`rouge_l_summary`](@ref)
"""
function rouge_n(references::Vector{<:AbstractString}, candidate::AbstractString, n::Int;
    lang=Languages.English())::Vector{Score}
    ng_candidate = ngramize(lang, candidate, n)
    rouge_recall = map(references) do ref
        ng_ref = ngramize(lang, ref, n)
        totalGramHit = rouge_match_score(keys(ng_ref), ng_candidate)
        score_r = totalGramHit / sum(values(ng_ref))
        score_p = totalGramHit / sum(values(ng_candidate))
        Score(
            score_p,
            score_r,
            fmeasure_lcs(score_r, score_p)
        )
    end

    return rouge_recall
end

function rouge_match_score(ref, candidate::Dict)
    matches = 0
    for (p, v) in candidate
        p ∉ ref && continue
        matches += v
    end
    return matches
end

"""
    rouge_l_sentence(references::Vector{<:AbstractString}, candidate::AbstractString, β=8; weighted=false)

Calculate the ROUGE-L score between `references` and `candidate` at sentence level.

See [Rouge: A package for automatic evaluation of summaries](http://www.aclweb.org/anthology/W04-1013)

See also: [`rouge_n`](@ref), [`rouge_l_summary`](@ref)
"""
function rouge_l_sentence(references::Vector{<:AbstractString}, candidate::AbstractString, β=8; weighted=true)
    ngram_cand = tokenize(Languages.English(), candidate)
    rouge_l_list = Score[]

    for ref in references
        ngram_ref = tokenize(Languages.English(), ref)
        r_lcs = weighted_lcs(ngram_ref, ngram_cand, weighted, sqrt) / length(ngram_ref)
        p_lcs = weighted_lcs(ngram_ref, ngram_cand, weighted, sqrt) / length(ngram_cand)
        fmeasure = fmeasure_lcs(r_lcs, p_lcs, β)
        push!(rouge_l_list, Score(p_lcs, r_lcs, fmeasure))
    end

    return rouge_l_list
end

"""
    rouge_l_summary(references, candidate, β)

Calculate the ROUGE-L score between `references` and `candidate` at summary level.

See [Rouge: A package for automatic evaluation of summaries](http://www.aclweb.org/anthology/W04-1013)

See also: [`rouge_l_sentence()`](@ref), [`rouge_l_summary`](@ref)
"""
function rouge_l_summary(references::Vector{<:AbstractString}, candidate::AbstractString, β::Int)::Vector{Score}
    rouge_l_list = Score[]
    ref_sent_tokens = map(references) do ref_sents
        map(split_sentences(ref_sents)) do ref_sent
            tokenize(Languages.English(), ref_sent)
        end
    end

    ref_sent_total_tokens = map(ref_sent_tokens) do ref_tokens
        sum(length, ref_tokens)
    end

    cand_sent_list = split_sentences(candidate)
    cand_sent_tokens = map(cand_sent_list) do cand_sent
        tokenize(Languages.English(), cand_sent)
    end

    cand_total_tokens_length = sum(length, cand_sent_tokens)

    for i in eachindex(ref_sent_tokens)
        sum_value = 0

        for ref_sent in ref_sent_tokens[i]
            l_ = []
            for cand_sent in cand_sent_tokens
                append!(l_, weighted_lcs_tokens(ref_sent, cand_sent, false))
            end
            sum_value += count(!isempty, unique(l_))
        end

        r_lcs = sum_value / ref_sent_total_tokens[i]
        p_lcs = sum_value / cand_total_tokens_length
        fmeasure = fmeasure_lcs(r_lcs, p_lcs, β)
        push!(rouge_l_list, Score(p_lcs, r_lcs, fmeasure))
    end

    return rouge_l_list
end
