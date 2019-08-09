using BSON, Tracker

mutable struct BiLSTM_CNN_CRF_Model{C, W, L, D, O, A}
    labels::Array{String, 1} # List of Labels
    chars_idx::Dict{Char, Int64} # Dict that maps chars to indices in W_Char_Embed
    words_idx::Dict{String, Int64} # Dict that maps words to indices in W_word_Embed
    conv1::C # Convolution Layer over W_Char_Embed to give character representation
    W_Char_Embed::W # Weights for character embeddings
    W_word_Embed::W # Further trained GloVe Embeddings
    forward_lstm::L # Forward LSTM
    backward::L # Backward LSTM
    d_out::D # Dense_out
    c::O # CRF
    init_α::A # For CRF layer
    UNK_Word_idx::Integer
    UNK_char_idx::Integer
end

function BiLSTM_CNN_CRF_Model(labels, chars_idx, words_idx, UNK_char_idx, UNK_Word_idx; CHAR_EMBED_DIMS=25, WORD_EMBED_DIMS=100,
                              CNN_OUTPUT_SIZE=30, CONV_PAD= (0,2), CONV_WINDOW_LENGTH = 3, LSTM_STATE_SIZE = 200)
    n = length(labels)
    init_α = fill(-10000, (n + 2, 1))
    init_α[n + 1] = 0

    BiLSTM_CNN_CRF_Model(labels, chars_idx, words_idx, Conv((CHAR_EMBED_DIMS, CONV_WINDOW_LENGTH), 1=>CNN_OUTPUT_SIZE, pad=CONV_PAD),
                rand(CHAR_EMBED_DIMS, length(chars_idx)), rand(WORD_EMBED_DIMS, length(words_idx)),
                LSTM(CNN_OUTPUT_SIZE + WORD_EMBED_DIMS, LSTM_STATE_SIZE), LSTM(CNN_OUTPUT_SIZE + WORD_EMBED_DIMS, LSTM_STATE_SIZE),
                Dense(LSTM_STATE_SIZE * 2, length(labels) + 2), CRF(n), init_α, UNK_Word_idx, UNK_char_idx)
end

function BiLSTM_CNN_CRF_Model(labels, chars_idx, words_idx, UNK_char_idx,UNK_Word_idx, weights_path)
    n = length(labels)
    init_α = fill(-10000, (n + 2, 1))
    init_α[n + 1] = 0

    W_word_Embed = BSON.load(joinpath(weights_path, "W_word_cpu.bson"))[:W_word_cpu].data
    W_Char_Embed = BSON.load(joinpath(weights_path, "W_char_cpu.bson"))[:W_char_cpu].data
    forward_lstm = BSON.load(joinpath(weights_path, "forward_lstm.bson"))[:forward_lstm_cpu]
    backward = BSON.load(joinpath(weights_path, "backward_lstm.bson"))[:backward_lstm_cpu]
    d_out = BSON.load(joinpath(weights_path, "d_cpu.bson"))[:d_cpu]
    c = BSON.load(joinpath(weights_path, "crf.bson"))[:crf_cpu]
    conv1 = BSON.load(joinpath(weights_path, "conv_cpu.bson"))[:conv_cpu]

    BiLSTM_CNN_CRF_Model(labels, chars_idx, words_idx, conv1, W_Char_Embed, W_word_Embed,
                forward_lstm, backward, d_out, c, init_α, UNK_Word_idx, UNK_char_idx)
end

function (a::BiLSTM_CNN_CRF_Model)(x)
    char_features = Chain(x -> reshape(x, size(x)..., 1,1),
                          a.conv1,
                          x -> maximum(x, dims=2),
                          x -> reshape(x, length(x),1))
    input_embeddings((w, cs)) = vcat(a.W_word_Embed * w, char_features(a.W_Char_Embed * cs))
    backward_lstm(x) = reverse((a.backward).(reverse(x)))
    bilstm_layer(x) = vcat.((a.forward_lstm).(x), backward_lstm(x))
    m = Chain(x -> input_embeddings.(x),
              bilstm_layer,
              x -> (a.d_out).(x))

    oh_outs = viterbi_decode(a.c, m(x), a.init_α)
    Flux.reset!(a.backward)
    Flux.reset!(a.forward_lstm)
    [a.labels[oh.ix] for oh in oh_outs]
end

onehotinput(m::BiLSTM_CNN_CRF_Model, word) = (onehot(get(m.words_idx, lowercase(word), m.UNK_Word_idx), 1:length(m.words_idx)),
                onehotbatch([get(m.chars_idx, c, m.UNK_char_idx) for c in word], 1:length(m.chars_idx)))
