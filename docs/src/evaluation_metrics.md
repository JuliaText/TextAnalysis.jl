## Evaluation Metrics

Natural Language Processing tasks require certain Evaluation Metrics.
As of now TextAnalysis provides the following evaluation metrics.

* [ROUGE-N](https://en.wikipedia.org/wiki/ROUGE_(metric))
* [ROUGE-L](https://en.wikipedia.org/wiki/ROUGE_(metric))

## ROUGE-N
This metric evaluatrion based on the overlap of N-grams
between the system and reference summaries.

    rouge_n(references, candidate, n; avg, lang)

The function takes the following arguments -

* `references::Array{T} where T<: AbstractString` = The list of reference summaries.
* `candidate::AbstractString` = Input candidate summary, to be scored against reference summaries.
* `n::Integer` = Order of NGrams
* `avg::Bool` = Setting this parameter to `true`, applies jackkniving the calculated scores. Defaults to `true`
* `lang::Language` = Language of the text, usefule while generating N-grams. Defaults to English i.e. Languages.English()

```julia
julia> candidate_summary =  "Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits."
"Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits."

julia> reference_summaries = ["Brazil, Russia, India and China are the next big poltical powers in the global economy. Together referred to as BRIC(S) along with South Korea.", "Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit."]
2-element Array{String,1}:
 "Brazil, Russia, India and China are the next big poltical powers in the global economy. Together referred to as BRIC(S) along with South Korea."
 "Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit."                                    

julia> rouge_n(reference_summaries, candidate_summary, 2, avg=true)
0.1317241379310345

julia> rouge_n(reference_summaries, candidate_summary, 1, avg=true)
0.5051282051282051
```
