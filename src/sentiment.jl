using JSON
using BSON

Flux = nothing # Will be filled once we actually use sentiment analysis

function pad_sequences(l, maxlen=500)
    if length(l) <= maxlen
        res = zeros(maxlen - length(l))
        for ele in l
            push!(res, ele)
        end
        return res
    end
end

function read_weights(filename=sentiment_weights)
    return BSON.load(filename)
end

function read_word_ids(filename=sentiment_words)
    return JSON.parse(String(read(open(filename, "r"))))
end

function embedding(embedding_matrix, x)
    temp = embedding_matrix[:, Int64(x[1])+1]
    for i=2:length(x)
        temp = hcat(temp, embedding_matrix[:, Int64(x[i])+1])
    end
    return reshape(temp, reverse(size(temp)))
end

function flatten(x)
    l = prod(size(x))
    x = permutedims(x, reverse(range(1, length=ndims(x))))
    return reshape(x, (l, 1))
end

function get_sentiment(ip::Array{T, 1}, weight, rwi, handle_unknown) where T <: AbstractString
    model = (x,) -> begin
    a_1 = embedding(weight[:embedding_1]["embedding_1"]["embeddings:0"], x)
    a_2 = flatten(a_1)
    a_3 = Flux.Dense(weight[:dense_1]["dense_1"]["kernel:0"], weight[:dense_1]["dense_1"]["bias:0"], Flux.relu)(a_2)
    a_4 = Flux.Dense(weight[:dense_2]["dense_2"]["kernel:0"], weight[:dense_2]["dense_2"]["bias:0"], Flux.sigmoid)(a_3)
    return a_4
    end
    res = Array{Int, 1}()
    for ele in ip
	if ele in keys(rwi)
            push!(res, rwi[ele])
	else
	    vcat(res, handle_unknown(ele))
	end
    end
    return model(pad_sequences(res))[1]
end

struct SentimentModel
    weight
    words

    function SentimentModel()
        # Only load Flux once it is actually needed
        global Flux
        Flux = Base.require(TextAnalysis, :Flux)
        
        new(read_weights(), read_word_ids())
    end
end

struct SentimentAnalyzer
    model::SentimentModel

    SentimentAnalyzer() = new(SentimentModel())
end

function Base.show(io::IO, s::SentimentAnalyzer)
    print(io, "Sentiment Analysis Model Trained on IMDB with a $(length(s.model.words)) word corpus")
end


function(m::SentimentModel)(text::Array{T, 1}, handle_unknown) where T <: AbstractString
    return get_sentiment(text, m.weight, m.words, handle_unknown)
end


"""
 ```
 model = SentimentAnalyzer(doc)
 model = SentimentAnalyzer(doc, handle_unknown)
 ```
 Return sentiment of the input doc in range 0 to 1, 0 being least sentiment score and 1 being
 the highest:
  -  doc              = Input Document for calculating document (AbstractDocument type)
  -  handle_unknown   = A function for handling unknown words. Should return an array (default (x)->[])
 """

function(m::SentimentAnalyzer)(d::AbstractDocument, handle_unknown::Function = (x)->[])
    m.model(tokens(d), handle_unknown)
end
