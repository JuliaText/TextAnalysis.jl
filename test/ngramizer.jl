module TestNGramizer
    using Base.Test
    using Languages
    using TextAnalysis
    using Compat

    sample_text = "this is some sample text"
    tkns = TextAnalysis.tokenize(Languages.EnglishLanguage, sample_text)
    ngs = TextAnalysis.ngramize(TextAnalysis.EnglishLanguage, tkns, 1)
    @assert isequal(ngs, @compat(Dict{UTF8String,Int}("some" => 1,
    	                                     "this" => 1,
    	                                     "is" => 1,
    	                                     "sample" => 1,
    	                                     "text" => 1)))
    ngs = TextAnalysis.ngramize(TextAnalysis.EnglishLanguage, tkns, 2)
    @assert isequal(ngs, @compat(Dict{UTF8String,Int}("some" => 1,
                                             "this is" => 1,
                                             "some sample" => 1,
                                             "is some" => 1,
                                             "sample text" => 1,
                                             "this" => 1,
                                             "is" => 1,
                                             "sample" => 1,
                                             "text" => 1)))
end
