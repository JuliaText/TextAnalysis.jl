module TestDTM
    using Base.Test
    using Languages
    using TextAnalysis

    sample_file = Pkg.dir("TextAnalysis", "test", "data", "poem.txt")

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

    dtm(crps)
    sparse(dtm(crps))
    hash_dtm(crps)

    tdm(crps)
    hash_tdm(crps)
end
