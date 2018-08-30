
@testset "Preprocessing" begin

    sample_text1 = "This is 1 MESSED υπ string!"
    sample_text1_wo_punctuation = "This is 1 MESSED υπ string"
    sample_text1_wo_punctuation_numbers = "This is  MESSED υπ string"
    sample_text1_wo_punctuation_numbers_case = "this is  messed υπ string"
    sample_text1_wo_punctuation_numbers_case_az = "this is  messed  string"

    sample_texts = [
        sample_text1,
        sample_text1_wo_punctuation,
        sample_text1_wo_punctuation_numbers,
        sample_text1_wo_punctuation_numbers_case,
        sample_text1_wo_punctuation_numbers_case_az
    ]

    # This idiom is _really_ ugly since "OR" means "AND" here.
    for str in sample_texts
        sd = StringDocument(str)
        prepare!(
            sd,
            strip_punctuation | strip_numbers | strip_case | strip_whitespace | strip_non_letters
        )
        @test isequal(strip(sd.text), "this is messed string")
    end

    # Need to only remove words at word boundaries
    doc = Document("this is sample text")
    remove_words!(doc, ["sample"])
    @test isequal(doc.text, "this is   text")

    doc = Document("this is sample text")
    prepare!(doc, strip_articles)
    @test isequal(doc.text, "this is sample text")

    doc = Document("this is sample text")
    prepare!(doc, strip_definite_articles)
    @test isequal(doc.text, "this is sample text")

    doc = Document("this is sample text")
    prepare!(doc, strip_indefinite_articles)
    @test isequal(doc.text, "this is sample text")

    doc = Document("this is sample text")
    prepare!(doc, strip_prepositions)
    @test isequal(doc.text, "this is sample text")

    doc = Document("this is sample text")
    prepare!(doc, strip_pronouns)
    @test isequal(doc.text, "this is sample text")

    doc = Document("this is sample text")
    prepare!(doc, strip_stopwords)
    @test isequal(strip(doc.text), "sample text")

    doc = Document("this is sample text")
    prepare!(doc, strip_whitespace)
    @test isequal(doc.text, "this is sample text")

    # stem!(sd)
    # tag_pos!(sd)

    # Do preprocessing on TokenDocument, NGramDocument, Corpus
    d = NGramDocument("this is sample text")
    @test haskey(d.ngrams, "sample")
    remove_words!(d, ["sample"])
    @test !haskey(d.ngrams, "sample")

    d = StringDocument(
        """
        <html>
            <head>
                <script language=\"javascript\"> x = 20; </script>
            </head>
            <body>
                <h1>Hello</h1><a href=\"world\">world</a>
            </body>
        </html>
        """
    )
    remove_html_tags!(d)
    @test "Hello world" == strip(d.text)

    #Test #62
    remove_corrupt_utf8("abc") == "abc"
    remove_corrupt_utf8(String([0x43, 0xf0])) == "C "
end
