using JSON
using Flux
using BSON

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
    w =  BSON.load(filename)
    #work around BSON bugs
    Base.rehash!(w[:embedding_1]["embedding_1"])
    Base.rehash!(w[:dense_1]["dense_1"])
    Base.rehash!(w[:dense_2]["dense_2"])
    return w
end

function read_word_ids(filename=sentiment_words)
    return JSON.parse(String(read(open(filename, "r"))))
end

get_op(x) = x>=0.5?1:0

function embedding(embedding_matrix, x)
    temp = embedding_matrix[:, Int64(x[1])+1]
    for i=2:length(x)
        temp = hcat(temp, embedding_matrix[:, Int64(x[i])+1])
    end
    return reshape(temp, reverse(size(temp)))
end

function flatten(x)
    return vec(x)
end

function get_sentiment(text)
    weight = read_weights(sentiment_weights)
    model = (x,) -> begin
    a_1 = embedding(weight[:embedding_1]["embedding_1"]["embeddings:0"], x)
    a_2 = flatten(a_1)
    a_3 = Dense(weight[:dense_1]["dense_1"]["kernel:0"], weight[:dense_1]["dense_1"]["bias:0"], relu)(a_2)
    a_4 = Dense(weight[:dense_2]["dense_2"]["kernel:0"], weight[:dense_2]["dense_2"]["bias:0"], sigmoid)(a_3)
    return a_4
    end
    rwi = read_word_ids(sentiment_words)
    ip = split(text, " ")
    res = Array{Any, 1}()
    for ele in ip
        push!(res, rwi[ele])
    end
    return model(pad_sequences(res))[1] |> get_op
end

struct SentimentAnalyser
end

function(m::SentimentAnalyser)(text)
    return get_sentiment(text)
end
