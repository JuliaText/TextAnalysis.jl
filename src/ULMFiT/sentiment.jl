"""
ULMFiT - Sentiment Analyzer
"""

struct SentimentAnalyzer <: TextClassifier
    vocab::Vector
    rnn_layers::Flux.Chain
    linear_layers::Flux.Chain
end

function SentimentAnalyzer(weights=load_weights(), clsfr_hidden_sz::Integer=50)
    inRNN = size(weights[2], 2)
    hidRNN = size(weights[7], 2)
    outRNN = size(weights[12], 1)/4
    clsfr_hidden_sz = size(weights[end-1], 2)/3
    clsfr_out_sz = size(weights[end-1], 1)
    vocab = intern.(string.(readdlm("vocab.csv",',', header=false)[:, 1]))
    sa = SentimentAnalyzer(
        vocab,
        Chain(
            DroppedEmbeddings(size(weights[1])...),
            AWD_LSTM(inRNN, hidRNN),
            AWD_LSTM(hidRNN, hidRNN),
            AWD_LSTM(hidRNN, outRNN)
        ),
        Chain(
            PooledDense(outRNN, clsfr_hidden_sz, relu)),
            BatchNorm(clsfr_hidden_sz, relu),
            Dense(clsfr_hidden_sz, clsfr_out_sz, sigmoid),
        )
    )
    test_mode!(sa)
    return sa
end

function get_sentiment(sa::SentimentAnalyzer, text::String)
    tokens = tokenize(text)
    idxs = map(x -> indices([x], sa.vocab, "_unk_"), tokens)
    H = sa.rnn_layers(idxs)
    sentiment_score = sa.linear_layers(H)
    return sentiment_score
end
