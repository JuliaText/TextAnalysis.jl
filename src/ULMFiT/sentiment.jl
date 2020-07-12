"""
ULMFiT - Binary Sentiment Analyzer

    BinSentimentClassifier()

This is a binary sentiment classifier developed after
fine-tuning the ULMFiT language model on IMDB movie reviews dataset.

# Usage:

julia> sc = BinSentimentClassifier()

julia> doc = StringDocument("this classifier is great")

julia> sc(doc)
"positive"

"""

struct BinSentimentClassifier
    vocab::Vector
    rnn_layers::Flux.Chain
    linear_layers::Flux.Chain
end

function BinSentimentClassifier()
    BSON.@load datadep"ULMFiT Sentiment Classifier/umlfit_sentiment_en.bson" weights
    vocab_sz, em_sz = size(weights[1])
    hid_lstm_sz = 1150
    out_lstm_sz = em_sz
    clsfr_hid_sz = 50
    clsfr_out_sz = 2
    vocab = (string.(readdlm("vocabs/sc_vocab.csv", ',')))[:, 1]
    sc = SentimentClassifier(
        vocab,
        Chain(
            DroppedEmbeddings(vocab_sz, em_sz),
            LSTM(em_sz, hid_lstm_sz),
            LSTM(hid_lstm_sz, hid_lstm_sz),
            LSTM(hid_lstm_sz, out_lstm_sz)
        ),
        Chain(
            PooledDense(out_lstm_sz, clsfr_hid_sz),
            BatchNorm(clsfr_hid_sz, relu),
            Dense(clsfr_hid_sz, clsfr_out_sz, sigmoid),
            BatchNorm(clsfr_out_sz),
            softmax
        )
    )
    Flux.loadparams!(sc, weights)
    sc = mapleaves(Tracker.data, sc)
    Flux.testmode!(sc)
    return sc
end

Flux.@treelike BinSentimentClassifier

function (sc::BinSentimentClassifier)(x::TokenDocument)
    remove_case!(x)
    idxs = map(w -> indices([w], sc.vocab, "_unk_"), tokens(x))
    h = sc.rnn_layers.(idxs)
    h = sc.linear_layers(h)
    Flux.reset!(sc.rnn_layers)
    return argmax(h)[1] == 1 ? "positive" : "negative"
end
