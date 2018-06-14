using Keras 
using JSON
using Flux

const deps = joinpath(@__DIR__, "..", "deps")
const deps_sentiment = joinpath(deps, "Sentiment Analysis")
const deps_sentiment_structure = joinpath(deps_sentiment, "sentiment-analysis-structure.json")
const deps_sentiment_weight = joinpath(deps_sentiment, "sentiment-analysis-weights.h5")
const deps_sentiment_ids = joinpath(deps_sentiment, "sentiment-analysis-word-to-id.json")

function pad_sequences(l, maxlen=500)
    if length(l) <= maxlen
        res = zeros(maxlen - length(l))
        for ele in l
            push!(res, ele)
        end
        return res
    end
end
    
function read_word_ids(filename=deps_sentiment_ids)
    return JSON.parse(String(read(open(filename, "r"))))
end

get_op(x) = x>=0.5?1:0

function get_sentiment(text)
    model = Keras.load(deps_sentiment_structure, deps_sentiment_weight)
    rwi = read_word_ids(deps_sentiment_ids)
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
    cd(deps)
    if "Sentiment Analysis" in readdir()
        return get_sentiment(text)
    else
        download("https://github.com/ayush1999/TextAnalysis.jl/releases/download/v0.3.0/sentiment-analysis-structure.json",
        "sentiment-analysis-structure.json")
        download("https://github.com/ayush1999/TextAnalysis.jl/releases/download/v0.3.0/sentiment-analysis-weights.h5",
        "sentiment-analysis-weights.h5")
        download("https://github.com/ayush1999/TextAnalysis.jl/releases/download/v0.3.0/sentiment-analysis-word-to-id.json",
        "sentiment-analysis-word-to-id.json")
        return get_sentiment(text)
    end
end

