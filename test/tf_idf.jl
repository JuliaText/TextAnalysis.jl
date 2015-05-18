module TestDTM
    using Base.Test
    using Languages
    using TextAnalysis

    doc1 = "a a a sample text text"
    doc2 = "another example example text text"
    doc3 = "another another text text text text"

    # TODO: this should work!
    # crps = Corpus(map(StringDocument, [doc1 doc2 doc3]))
    
    crps = Corpus(Any[StringDocument(doc1), StringDocument(doc2), StringDocument(doc3)])

    update_lexicon!(crps)
    m = DocumentTermMatrix(crps)

    # Terms are in alphabetical ordering
    correctweights = [0.5493061443340548 0.0 0.0 0.18310204811135158 0.0
                      0.0 0.08109302162163289 0.43944491546724385 0.0 0.0
                      0.0 0.13515503603605478 0.0 0.0 0.0]

    myweights = tf_idf(m)
    @test_approx_eq myweights correctweights
                       
    myweights = tf_idf(dtm(m))
    @test_approx_eq myweights correctweights
    @test typeof(myweights) <: SparseMatrixCSC

    myweights = tf_idf(dtm(m, :dense))
    @test_approx_eq myweights correctweights
    @test typeof(myweights) <: Matrix

    myweights = float(dtm(m));
    tf_idf!(myweights)
    @test_approx_eq myweights correctweights
    @test typeof(myweights) <: SparseMatrixCSC

    myweights = float(dtm(m, :dense));
    tf_idf!(myweights)
    @test_approx_eq myweights correctweights
    @test typeof(myweights) <: Matrix
end
