using TextAnalysis

@testset "Evaluation/BLEU" begin
    max_order = 4
    # test token-based ngrams
    ngrams = TextAnalysis.get_ngrams(split("it is a dog "), max_order)
    actual_orders = Set(length.(keys(ngrams)))

    @test length(intersect(actual_orders, 1:max_order)) == max_order
    @test length(setdiff(actual_orders, 1:max_order)) == 0

    # NLTK sample https://www.nltk.org/api/nltk.translate.bleu_score.html
    reference1 = [
        "It", "is", "a", "guide", "to", "action", "that",
        "ensures", "that", "the", "military", "will", "forever",
        "heed", "Party", "commands"
    ]
    reference2 = [
        "It", "is", "the", "guiding", "principle", "which",
        "guarantees", "the", "military", "forces", "always",
        "being", "under", "the", "command", "of", "the",
        "Party"
    ]
    reference3 = [
        "It", "is", "the", "practical", "guide", "for", "the",
        "army", "always", "to", "heed", "the", "directions",
        "of", "the", "party"
    ]

    hypothesis1 = [
        "It", "is", "a", "guide", "to", "action", "which",
        "ensures", "that", "the", "military", "always",
        "obeys", "the", "commands", "of", "the", "party"
    ]

    score = bleu_score([[reference1, reference2, reference3]], [hypothesis1])
    @test isapprox(score.bleu, 0.5045, atol=1e-4) #(NLTK)
end
