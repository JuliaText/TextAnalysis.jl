## Evaluation Metrics

Natural Language Processing tasks require certain Evaluation Metrics.
As of now TextAnalysis provides the following evaluation metrics.

* [ROUGE-N](https://en.wikipedia.org/wiki/ROUGE_(metric))
* [ROUGE-L](https://en.wikipedia.org/wiki/ROUGE_(metric))

* [BLEU (bilingual evaluation understudy)](https://en.wikipedia.org/wiki/BLEU)

## ROUGE-N
This metric evaluation based on the overlap of N-grams
between the system and reference summaries.

```@docs
rouge_n
```

The function takes the following arguments -

* `references::Array{T} where T<: AbstractString` = The list of reference summaries.
* `candidate::AbstractString` = Input candidate summary, to be scored against reference summaries.
* `n::Integer` = Order of NGrams
* `avg::Bool` = Setting this parameter to `true`, applies jackkniving the calculated scores. Defaults to `true`
* `lang::Language` = Language of the text, useful while generating N-grams. Defaults to English i.e. Languages.English()

```julia
julia> candidate_summary =  "Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits."
"Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits."

julia> reference_summaries = ["Brazil, Russia, India and China are the next big political powers in the global economy. Together referred to as BRIC(S) along with South Korea.", "Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit."]
2-element Array{String,1}:
 "Brazil, Russia, India and China are the next big political powers in the global economy. Together referred to as BRIC(S) along with South Korea."
 "Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit."                                    

julia> rouge_n(reference_summaries, candidate_summary, 2, avg=true)
0.1317241379310345

julia> rouge_n(reference_summaries, candidate_summary, 1, avg=true)
0.5051282051282051
```

## BLEU (bilingual evaluation understudy)

```@docs
bleu_score
```

[NLTK sample](https://www.nltk.org/api/nltk.translate.bleu_score.html)
```@example
    using TextAnalysis

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
```
