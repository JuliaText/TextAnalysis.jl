module TestDTM
    using Base.Test
    using Languages
    using TextAnalysis

    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    fd = FileDocument(sample_file)
    sd = StringDocument(text(fd))

    crps = Corpus(Any[fd, sd])

    m = DocumentTermMatrix(crps)
    dtm(m)
    dtm(m, :dense)

    update_lexicon!(crps)

    m = DocumentTermMatrix(crps)
    dtm(m)
    dtm(m, :dense)

    tf_idf(dtm(m, :dense))

    dtv(crps[1], lexicon(crps))

    hash_dtv(crps[1], TextHashFunction())
    hash_dtv(crps[1])

    dtm1 = dtm(crps)
    dtm1sp = sparse(dtm(crps))
    hash_dtm(crps)

    tdm(crps)
    hash_tdm(crps)

    # construct a DocumentTermMatrix from a dtm and terms vector
    terms = m.terms
    m2 = DocumentTermMatrix(dtm1,terms)
    @test m.column_indices == m2.column_indices
    m2 = DocumentTermMatrix(dtm1sp,terms)
    @test m.column_indices == m2.column_indices
end
