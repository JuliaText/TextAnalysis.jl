function summarize(d::AbstractDocument; ns=5)
    sentences = sentence_tokenize(language(d), text(d))
    s = StringDocument.(sentences)
    c = Corpus(s)
    prepare!(c, strip_case | strip_stopwords | stem_words )
    update_lexicon!(c)
    t = tf_idf(dtm(c))
    T = t * t'
    p=pagerank(T)
    return sentences[sort(sortperm(vec(p), rev=true)[1:ns])]
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
