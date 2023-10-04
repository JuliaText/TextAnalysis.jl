# Julia Implementation of BLEU and Smooth BLEU score
# ref: https://github.com/tensorflow/nmt/blob/master/nmt/scripts/bleu.py#L56

# Example: bleu_score([["apple is apple"]], ["apple is appl"])

# Julia implementation of BLEU and smooth-BLEU.
# Based on https://github.com/AdarshKumar712/Metrics.jl/blob/master/src/NLP_Metrics/bleu.jl

# This module provides a Julia implementation of BLEU and smooth-BLEU.
# Smooth BLEU is computed following the method outlined in the paper:
# Chin-Yew Lin, Franz Josef Och. ORANGE: a method for evaluating automatic
# evaluation metrics for machine translation. COLING 2004.


"""
    get_ngrams(segment, max_order)

Extracts all n-grams upto a given maximum order from an input segment. Returns the counter containing all n-grams upto max_order in segment
with a count of how many times each n-gram occurred.

# Arguments 
 - `segment`: text segment from which n-grams will be extracted.
 - `max_order`: maximum length in tokens of the n-grams returned by this methods.

"""
function get_ngrams(segment::Vector{<:AbstractString}, max_order::Integer)
    ngrams_count = Dict()
    for order in 1:max_order
        for i in 1:(length(segment)-order+1)
            ngram = Symbol.(segment[i:i+order-1])
            count = get(ngrams_count, ngram, 0)
            ngrams_count[ngram] = count + 1
        end
    end
    return ngrams_count
end

const ListOfTokens = Vector{<:AbstractString}
const DocumentWithTokenizedSentences = Vector{<:ListOfTokens}

"""
    bleu_score(reference_corpus::Vector{Vector{Token}}, translation_corpus::Vector{Token}; max_order=4, smooth=false)

Computes BLEU score of translated segments against one or more references. Returns the `BLEU score`, `n-gram precisions`, `brevity penalty`, 
geometric mean of n-gram precisions, translation_length and  reference_length

# Arguments
 - `reference_corpus`: list of lists of references for each translation. Each reference should be tokenized into a list of tokens.
 - `translation_corpus`: list of translations to score. Each translation should be tokenized into a list of tokens.
 - `max_order`: maximum n-gram order to use when computing BLEU score. 
 - `smooth=false`: whether or not to apply. Lin et al. 2004 smoothing.


Example:
```julia
one_doc_references = [
    ["apple", "is", "apple"],
    ["apple", "is", "a", "fruit"]
]  
one_doc_translation = [
    "apple", "is", "appl"
]
bleu_score([one_doc_references], [one_doc_translation], smooth=true)
```
"""
function bleu_score(
    reference_corpus::Vector{<:T}, translation_corpus::T;
    max_order=4, smooth=false
) where {T<:DocumentWithTokenizedSentences}
    matches_by_order = zeros(max_order)
    possible_matches_by_order = zeros(max_order)

    reference_length = 0
    translation_length = 0
    if !isempty(reference_corpus) && !isempty(translation_corpus)
        for (references, translation) in zip(reference_corpus, translation_corpus)
            isempty(references) && continue

            reference_length += min([length(r) for r in references]...)
            translation_length += length(translation)
            merged_ref_ngram_counts = Dict()
            for reference in references
                ref_ngrams = get_ngrams(reference, max_order)
                for (k, v) in ref_ngrams
                    merged_count = get(merged_ref_ngram_counts, k, 0)
                    if v > merged_count
                        merged_ref_ngram_counts[k] = v
                    end
                end
            end

            translation_ngram_counts = get_ngrams(translation, max_order)
            overlap = Dict()
            for (k, v) in translation_ngram_counts
                new_counter = min(get(merged_ref_ngram_counts, k, 0), v)
                if new_counter > 0
                    overlap[k] = new_counter
                end
            end

            for (ngram, count) in overlap
                matches_by_order[length(ngram)] += count
            end
            for order in 1:max_order
                possible_matches = length(translation) - order + 1
                if possible_matches > 0
                    possible_matches_by_order[order] += possible_matches
                end
            end
        end
    end

    precisions = map(1:max_order) do i
        if smooth
            (matches_by_order[i] + 1.0) / (possible_matches_by_order[i] + 1.0)
        elseif possible_matches_by_order[i] > 0
            matches_by_order[i] / possible_matches_by_order[i]
        else
            0.0
        end
    end

    geo_mean = 0.0
    if all(>(0), precisions)
        p_log_sum = sum(log.(precisions)) / max_order
        geo_mean = exp(p_log_sum)
    end

    ratio = float(translation_length) / reference_length
    bp = 1.0
    if ratio < 1.0
        bp = exp(1 - 1.0 / ratio)
    end

    bleu = geo_mean * bp

    return (
        bleu=bleu,
        precisions=precisions,
        bp=bp,
        geo_mean=geo_mean,
        translation_length=translation_length,
        reference_length=reference_length
    )
end
