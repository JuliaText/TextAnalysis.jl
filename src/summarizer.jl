"""
    summarize(doc [, ns])

Summarizes the document and returns `ns` number of sentences.
It takes 2 arguments:

* `d` : A document of type `StringDocument`, `FileDocument` or `TokenDocument`
* `ns` : (Optional) Mention the number of sentences in the Summary, defaults to `5` sentences.

By default `ns` is set to the value 5.

# Example
```julia-repl
julia> s = StringDocument("Assume this Short Document as an example. Assume this as an example summarizer. This has too foo sentences.")

julia> summarize(s, ns=2)
2-element Array{SubString{String},1}:
 "Assume this Short Document as an example."
 "This has too foo sentences."
```
"""
function summarize(d::AbstractDocument; ns=5)
    sentences = sentence_tokenize(language(d), text(d))
    num_sentences = length(sentences)
    s = StringDocument.(sentences)
    c = Corpus(s)
    prepare!(c, strip_case | strip_stopwords | stem_words )
    update_lexicon!(c)
    t = tf_idf(dtm(c))
    T = t * t'
    p = pagerank(T)
    return sentences[sort(sortperm(vec(p), rev=true)[1:min(ns, num_sentences)])]
end

function pagerank( A; Niter=20, damping=.15)
         Nmax = size(A, 1)
         r = rand(1,Nmax);              # Generate a random starting rank.
         r = r ./ norm(r,1);            # Normalize
         a = (1-damping) ./ Nmax;       # Create damping vector

         for i=1:Niter
             s = r * A
             rmul!(s, damping)
             r = s .+ (a * sum(r, dims=2));   # Compute PageRank.
         end

         r = r./norm(r,1);

         return r
end
