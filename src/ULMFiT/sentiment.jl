"""
ULMFiT - Sentiment Analyzer

    SentimentClassifier()

This is a binary sentiment classifier developed after
fine-tuning the ULMFiT language model on IMDB movie reviews dataset.

# Usage:

julia> sc = SentimentClassifier()

julia> doc = StringDocument("this classifier is great")

julia> sc(doc)
"positive"

"""

struct SentimentClassifier <: TextClassifier
    vocab::Vector
    rnn_layers::Flux.Chain
    linear_layers::Flux.Chain
end

function SentimentClassifier()
    @load datadep"ULMFiT Sentiment Classifier" weights
    in_lstm = size(weights[2], 2)
    hid_lstm = size(weights[7], 2)
    out_lstm = size(weights[12], 1)/4
    clsfr_hidden_sz = size(weights[end-1], 2)/3
    clsfr_out_sz = size(weights[end-1], 1)
    vocab = intern.(tokens(FileDocument("vocabs/sentiment_vocab.txt")))
    sc = SentimentClassifier(
        vocab,
        Chain(
            DroppedEmbeddings(size(weights[1])...),
            LSTM(in_lstm, hid_lstm),
            LSTM(hid_lstm, hid_lstm),
            LSTM(hid_lstm, out_lstm)
        ),
        Chain(
            PooledDense(out_lstm, clsfr_hidden_sz, relu)),
            BatchNorm(clsfr_hidden_sz, relu),
            Dense(clsfr_hidden_sz, clsfr_out_sz, sigmoid),
            BatchNorm(clsfr_out_sz),
            sigmoid
        )
    )
    Flux.loadparams!(sc, weights)
    sc = mapleaves(Tracker.data, sc)
    test_mode!(sc)
    return sc
end

function (sc::SentimentClassifier)(x::TokenDocument)
    idxs = map(w -> indices([w], sc.vocab, "_unk_"), lowercase.(tokens(x))))
    h = sc.rnn_layers[idxs].(idxs)
    h = sc.linear_layers(h)
    Flux.reset!(sc.rnn_layers)
    return argmax(h)[1] == 1 ? "positive" : "negative"
end
