using DataStructures

@testset "Vocabulary" begin
    
    words = ["a", "c", "-", "d", "c", "a", "b", "r", "a", "c", "d"]
    vocab = Vocabulary(words, 2, "</s>")
    @test vocab isa Vocabulary
    @test vocab.vocab isa Dict
    @test vocab.unk_cutoff isa Int
    @test vocab.unk_label isa String
    @test vocab.allword isa Array{String,1}
    @test length(vocab.vocab) == 4 #only 4 differnt string over word freq 2
    @test isequal(vocab.unk_cutoff, 2)
    @test vocab.unk_label == "</s>"
    @test isequal(vocab.allword ,["a", "c", "-", "d", "c", "a", "b", "r", "a", "c", "d", "</s>"]) 
    @test isequal(vocab.vocab, Dict{String,Int}("</s>"=>1,"c"=>3,"a"=>3,"d"=>2))
    #to check lookup function
    @test lookup(vocab,["a","b","c","alien"]) == ["a", "</s>", "c", "</s>"]    
end

@testset "preprocessing" begin
    @testset "ngramizenew" begin 
        sample_text = ["this", "is", "some", "sample", "text"]
        ngrams = TextAnalysis.ngramizenew(sample_text,1)
        
        @test isequal(ngrams, ["this", "is", "some", "sample", "text"])
        
        ngrams = TextAnalysis.ngramizenew(sample_text,2)
        @test isequal(ngrams, ["this is", "is some", "some sample", "sample text"])
    
        ngrams = TextAnalysis.ngramizenew(sample_text,1,2)
        @test isequal(ngrams, ["this", "is", "some", "sample", "text", "this is", "is some", "some sample", "sample text"])
    end
    
    @testset "Padding function" begin
        example = ["1","2","3","4","5"]
        padded=padding_ngram(example,2,pad_left=true,pad_right=true)
        @test isequal(padded,["<s> 1", "1 2", "2 3", "3 4", "4 5", "5 </s>"])
        @test isequal(example, ["<s>","1","2","3","4","5","</s>"])
        
        example = ["1","2","3","4","5"] #if used
        padded=padding_ngram(example,2,pad_right=true)
        @test isequal(padded,["1 2", "2 3", "3 4", "4 5", "5 </s>"])
    end
    @testset "everygram function" begin
        example = ["1","2","3","4","5"]
        everyngms = everygram(example,min_len=1,max_len=2)
        @test isequal(everyngms, ["1", "2", "3", "4", "5", "1 2", "2 3", "3 4", "4 5"])
    end
end

@testset "counter" begin
    exam = ["To", "be", "or", "not", "to", "be","To", "be", "or", "not", "to", "be"]
    fit = (TextAnalysis.counter2(exam,2,2))
    @test fit isa DataStructures.DefaultDict
    @test length(fit) == 5 #length of unique words
    @test
end
    
