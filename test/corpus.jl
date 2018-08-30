
@testset "Corpus" begin

    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"
    sample_file = joinpath(dirname(@__FILE__), "data", "poem.txt")

    sd = StringDocument(sample_text1)
    fd = FileDocument(sample_file)
    td = TokenDocument(sample_text1)
    ngd = NGramDocument(sample_text1)

    crps = Corpus(Any[sd, fd, td, ngd])
    crps2 = Corpus([ngd, ngd])

    documents(crps)

    for doc in crps
    	@test isa(doc, AbstractDocument)
    end

    lexicon(crps)
    update_lexicon!(crps)
    lexicon(crps)

    inverse_index(crps)
    update_inverse_index!(crps)
    inverse_index(crps)

    hash_function(crps)
    hash_function!(crps, TextHashFunction())

    crps[1]
    crps["string"]
end
