
@testset "DTM" begin
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

    # construct a DocumentTermMatrix from a crps and a custom terms vector
    terms = ["And", "notincrps"]
    m = DocumentTermMatrix(crps,terms)
    @test size(dtm(m),1) == length(terms)
    @test terms == m.terms
    @test size(dtm(m),2) == length(crps)

    # construct a DocumentTermMatrix from a crps and a custom lexicon
    lex = Dict("And"=>1, "notincrps"=>4)
    m = DocumentTermMatrix(crps,lex)
    @test size(dtm(m),1) == length(keys(lex))
    @test size(dtm(m),1) == length(m.terms)
    @test size(dtm(m),2) == length(crps)

    # construct a DocumentTermMatrix from a dtm and terms vector
    terms = m.terms
    m2 = DocumentTermMatrix(dtm1,terms)
    @test m.column_indices == m2.column_indices
    m2 = DocumentTermMatrix(dtm1sp,terms)
    @test m.column_indices == m2.column_indices
end
