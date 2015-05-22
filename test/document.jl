module TestDocument
    using Base.Test
    using Languages
    using TextAnalysis

    sample_text1 = "This is a string"
    sample_text2 = "This is also a string"
    sample_file = Pkg.dir("TextAnalysis", "test", "data", "poem.txt")

    sd = StringDocument(sample_text1)
    fd = FileDocument(sample_file)
    td = TokenDocument(sample_text1)
    ngd = NGramDocument(sample_text1)

    @assert isequal(text(sd), sample_text1)
    text!(sd, sample_text2)
    @assert isequal(text(sd), sample_text2)
    text!(sd, sample_text1)
    @assert isequal(text(sd), sample_text1)

    @assert all(tokens(sd) .== ["This", "is", "a", "string"])
    @assert "This" in keys(ngrams(sd, 1))
    @assert "is" in keys(ngrams(sd, 1))
    @assert "a" in keys(ngrams(sd, 1))
    @assert "string" in keys(ngrams(sd, 1))

    @assert length(sd) == 16

    hamlet_text = "To be or not to be..."
    sd = StringDocument(hamlet_text)
    @assert isa(sd, StringDocument)
    @assert isequal(text(sd), hamlet_text)

    @assert isa(fd, FileDocument)
    @assert length(text(fd)) > 0

    my_tokens = ["To", "be", "or", "not", "to", "be..."]
    td = TokenDocument(my_tokens)
    @assert isa(td, TokenDocument)
    @assert all(tokens(td) .== my_tokens)

    my_ngrams = Dict{UTF8String,Int}()
    my_ngrams["To"] = 1
    my_ngrams["be"] = 2
    my_ngrams["or"] = 1
    my_ngrams["not"] = 1
    my_ngrams["to"] = 1
    my_ngrams["be..."] = 1
    ngd = NGramDocument(my_ngrams)
    @assert isa(ngd, NGramDocument)
    @assert "To" in keys(ngrams(ngd))

    sd = StringDocument(hamlet_text)
    td = TokenDocument(hamlet_text)
    ngd = NGramDocument(hamlet_text)

    d = Document("To be or not to be...")
    @assert isa(d, StringDocument)
    d = Document("/usr/share/dict/words")
    @assert isa(d, FileDocument)
    d = Document(["To", "be", "or", "not", "to", "be..."])
    @assert isa(d, TokenDocument)
    ng = Dict{UTF8String,Int}()
    ng["a"] = 1
    ng["b"] = 3
    d = Document(ng)
    @assert isa(d, NGramDocument)

    @assert isequal(length(Document("this is text")), 12)
end
