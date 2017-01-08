module TestLDA
    using Base.Test
    using Languages
    using TextAnalysis

    doc1 = "a a a sample text text"
    doc2 = "another example example text text"

    crps = Corpus(Any[StringDocument(doc1), StringDocument(doc2)])    

    update_lexicon!(crps)

    dtm = DocumentTermMatrix(crps)
    topics = lda(dtm, 2, 25, 0.1, 0.1)
    @test typeof(topics) <: SparseMatrixCSC
end
