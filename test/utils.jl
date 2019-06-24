@testset "Utils" begin

txt = "Sourav Ganguly was born on 8 July 1972 in Calcutta, and is the youngest son of Chandidas and Nirupa Ganguly. Chandidas ran a flourishing print business and was one of the richest men in the city. Ganguly had a luxurious childhood and was nicknamed the 'Maharaja', meaning the 'Great King'. Ganguly's father Chandidas Ganguly died at the age of 73 on 21 February 2013 after a long illness."
sd = StringDocument(lowercase(txt))
prepare!(sd, strip_punctuation)
prepare!(sd, strip_stopwords)
sd = StringDocument(join([i for i in split(text(sd), " ") if i!= ""], " "))
sd = sort(unique(split(text(sd), " ")))
wordlist = sd
convert(Array{String,1}, wordlist)
x= word_cooccurrence_matrix(txt, 5, true)
for i in range(1, length(wordlist))
    @test x[i, i] >= 1
end

for i in range(1, length(wordlist))
    for j in range(1, length(wordlist))
        print(i," ",j, "\n")
        @test x[i, j] == x[j,i]
    end
end
