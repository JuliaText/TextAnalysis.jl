"""
ULMFiT - LANGUAGE MODEL [Word-by-Word]
"""

using WordTokenizers   # For accesories
using InternedStrings   # For using Interned strings
using DelimitedFiles   # For reading and writing files
using Flux  # For building models
using Flux: Tracker, crossentropy, chunk
using LinearAlgebra: norm
using BSON: @save, @load  # For saving model weights
# using CuArrays  # For GPU support

cd(@__DIR__)
include("custom_layers.jl")      # importing AWD_LSTM (ASGD Weight-Dropped LSTM)
include("utils.jl")     # including some functions
include("WikiText103_DataDeps.jl")      # including WikiText-103 Corpus

# Language Model
mutable struct LanguageModel
    vocab :: Vector
    layers :: Flux.Chain

    function LanguageModel(embedding_size::Integer=400, hidLSTMSize::Integer=1150, outLSTMSize::Integer=embedding_size;
        embedDropProb::Float64 = 0.05, wordDropProb::Float64 = 0.4, hidDropProb::Float64 = 0.5, LayerDropProb::Float64 = 0.3, FinalDropProb::Float64 = 0.4)
        vocab = intern.(string.(readdlm("vocab.csv",',', header=false)[:, 1]))
        lm = new(vocab)
        de = DroppedEmbeddings(length(vocab), embedding_size, 0.1; init = (dims...) -> init_weights(0.1, dims...))
        lm.layers = Chain(
            de,
            VarDrop(wordDropProb),
            AWD_LSTM(embedding_size, hidLSTMSize, hidDropProb; init = (dims...) -> init_weights(1/hidLSTMSize, dims...)),
            VarDrop(LayerDropProb),
            AWD_LSTM(hidLSTMSize, hidLSTMSize, hidDropProb; init = (dims...) -> init_weights(1/hidLSTMSize, dims...)),
            VarDrop(LayerDropProb),
            AWD_LSTM(hidLSTMSize, outLSTMSize, hidDropProb; init = (dims...) -> init_weights(1/hidLSTMSize, dims...)),
            VarDrop(FinalDropProb),
            x -> de(x, true),
            softmax
        )
        return lm
    end
end

Flux.@treelike LanguageModel

# Forward
function forward(lm, batch)
    batch = broadcast(x -> lm.layers[1](indices(x, lm.vocab, "_unk_")), batch)
    batch = lm.layers[2:end].(batch)
    return batch
end

# loss funciton - Loss calculation with AR and TAR regulatization
function loss(lm, gen)
    H = forward(lm, take!(gen))
    Y = broadcast(x -> gpu(Flux.onehotbatch(x, lm.vocab, "_unk_")), take!(gen))
    l = sum(crossentropy.(H, Y))
    Flux.truncate!(lm.layers)
    return l
end

# Gradient Clipping
grad_clipping(g, upper_bound) = min(g, upper_bound)

# Backward
function back!(layers, l, opt, gradient_clip::Float64)
    # Applying gradient clipping
    l = Tracker.hook(x -> grad_clipping(x, gradient_clip), l)

    # Calulating gradients and weights updation
    p = get_trainable_params(layers)
    grads = Tracker.gradient(() -> l, p)
    Tracker.update!(opt, p, grads)
    return
end

# Funciton for training Language Model
function pretrain_lm!(lm::LanguageModel; batchsize::Integer=64, bptt::Integer=70, data_loader::Channel=load_wikitext_103, gradient_clip::Float64=0.25,
    base_lr=0.004, epochs::Integer=1, checkpoint_iter::Integer=5000)

    # Initializations
    opt = ADAM(base_lr, (0.7, 0.99))    # ADAM Optimizer
    gpu!.(lm.layers)

    # Pre-Training loops
    for epoch=1:epochs
        gen = Channel(x -> generator(x, loadCorpus(); batchsize = batchsize, bptt = bptt))
        num_of_batches = take!(gen) # Number of mini-batches
        T = num_of_iters-Int(floor((num_of_iters*2)/100))   # Averaging Trigger
        set_trigger!.(T, lm.layers)  # Setting triggers for AWD_LSTM layers
        for i=1:num_of_batches

            # FORWARD PROPAGATION
            l = loss(lm, gen)

            # BACK PROPAGATION
            back!(lm.layers, l, opt, gradient_clip)
            for layer in lm.layers[1:8]
                cpu!(layer)
            end

            # ASGD Step, after Triggering
            asgd_step!.(i, lm.layers)

            reset_masks!.(lm.layers)

            println("loss: $l", " iteration number: $i")

            # Saving checkpoints
            if i == checkpoint_iter save_model!(lm) end
        end
        println("\nEpoch: $epoch")
    end
end

# To save model
function save_model!(lm::LanguageModel, filepath::String="ULMFiT-LM.bson")
    weights = cpu.(Tracker.data.(params(lm)))
    @save filepath weights
end

# To load model
function load_model!(lm::LanguageModel, filepath::String=joinpath(datadep"pretrained-ULMFiT", "weights.bson"))
    @load filepath weights
    Flux.loadparams!(lm, weights)
end

function load_model!()
    lm = LanguageModel()
    load_model!(lm)
    return lm
end

function load_model!(filepath::String)
    lm = LanguageModel()
    load_model!(lm, filepath)
end
