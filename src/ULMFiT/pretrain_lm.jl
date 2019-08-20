"""
ULMFiT - LANGUAGE MODEL

The Language model structure for ULMFit is defined by 'LanguageModel' struct.
It contains has two fields:
    vocab   : vocabulary, which will be used for language modelling
    layers  : embedding, RNN and dropout layers of the whole model
In this language model, the embedding matrix used in the embedding layer
is same for the softmax layer, following Weight-tying technique.
The field 'layers' also includes the Variational Dropout layers.
It takes several dropout probabilities for different dropout for different layers.

[Usage and arguments are discussed in the docs]

"""
mutable struct LanguageModel
    vocab :: Vector
    layers :: Flux.Chain
end

function LanguageModel(;embedding_size::Integer=400, hid_lstm_sz::Integer=1150, out_lstm_sz::Integer=embedding_size,
    embed_drop_prob::Float64 = 0.05, in_drop_prob::Float64 = 0.4, hid_drop_prob::Float64 = 0.5, layer_drop_prob::Float64 = 0.3, final_drop_prob::Float64 = 0.3)
    vocab = intern.(string.(readdlm("vocab.csv",',', header=false)[:, 1]))
    de = gpu(DroppedEmbeddings(length(vocab), embedding_size, embed_drop_prob; init = (dims...) -> init_weights(0.1, dims...)))
    lm = LanguageModel(
        vocab,
        Chain(
            de,
            VarDrop(in_drop_prob),
            gpu(AWD_LSTM(embedding_size, hid_lstm_sz, hid_drop_prob; init = (dims...) -> init_weights(1/hid_lstm_sz, dims...))),
            VarDrop(layer_drop_prob),
            gpu(AWD_LSTM(hid_lstm_sz, hid_lstm_sz, hid_drop_prob; init = (dims...) -> init_weights(1/hid_lstm_sz, dims...))),
            VarDrop(layer_drop_prob),
            gpu(AWD_LSTM(hid_lstm_sz, out_lstm_sz, hid_drop_prob; init = (dims...) -> init_weights(1/hid_lstm_sz, dims...))),
            VarDrop(final_drop_prob),
            x -> de(x, true),
            softmax
        )
    )
    return lm
end

Flux.@treelike LanguageModel

# computes the forward pass while training
function forward(lm, batch)
    batch = map(x -> indices(x, lm.vocab, "_unk_"), batch)
    batch = lm.layers.(batch)
    return batch
end

# loss funciton - Calculates crossentropy loss
function loss(lm, gen)
    H = forward(lm, take!(gen))
    Y = broadcast(x -> gpu(Flux.onehotbatch(x, lm.vocab, "_unk_")), take!(gen))
    l = sum(crossentropy.(H, Y))
    Flux.truncate!(lm.layers)
    return l
end

# Backpropagation step while training
function backward!(layers, l, opt)
    # Calulating gradients and weights updation
    p = get_trainable_params(layers)
    grads = Tracker.gradient(() -> l, p)
    Tracker.update!(opt, p, grads)
    return
end

"""
pretrain_lm!

This funciton contains main training loops for pretrainin the Language model
including averaging step for the 'AWD_LSTM' layers.

Usage and arguments are explained in the docs of ULMFiT
"""
function pretrain_lm!(lm::LanguageModel=LanguageModel(), data_loader::Channel=load_wikitext_103;
    base_lr=0.004, epochs::Integer=1, checkpoint_iter::Integer=5000)

    # Initializations
    opt = ADAM(base_lr, (0.7, 0.99))    # ADAM Optimizer
    gpu!.(lm.layers)

    # Pre-Training loops
    for epoch=1:epochs
        println("\nEpoch: $epoch")
        gen = load_wikitext_103()
        num_of_batches = take!(gen) # Number of mini-batches
        T = num_of_iters-Int(floor((num_of_iters*2)/100))   # Averaging Trigger
        set_trigger!.(T, lm.layers)  # Setting triggers for AWD_LSTM layers
        for i=1:num_of_batches

            # FORWARD PASS
            l = loss(lm, gen)

            # REVERSE PASS
            backward!(lm.layers, l, opt)

            # ASGD Step, works after Triggering
            asgd_step!.(i, lm.layers)

            # Resets dropout masks for all the layers with Varitional DropOut or DropConnect masks
            reset_masks!.(lm.layers)

            # Saving checkpoints
            if i == checkpoint_iter save_model!(lm) end
        end
    end
end


# using WordTokenizers   # For accesories
# using InternedStrings   # For using Interned strings
# using Flux  # For building models
# using Flux: Tracker, crossentropy, chunk
# using BSON: @save, @load  # For saving model weights
# using CuArrays  # For GPU support
