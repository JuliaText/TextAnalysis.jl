"""
ULMFiT - Text Classifier
"""

cd(@__DIR__)
include("custom_layers.jl")     # including custome layers created for ULMFiT model
include("utils.jl")     # including utilities
include("fine_tune_lm.jl")        # including useful functions from fine-tuning file
# include("data_loaders.jl")      # including helper functions for IMDB data loading

mutable struct TextClassifier
    vocab::Vector
    rnn_layers::Flux.Chain
    linear_layers::Flux.Chain
end

function TextClassifier(lm::LanguageModel=LanguageModel(), clsfr_out_sz::Integer=1, clsfr_hidden_sz::Integer=50, clsfr_hidden_drop::Float64=0.0)
    return TextClassifier(
        lm.vocab,
        lm.layers[1:8],
        Chain(
            gpu(PooledDense(length(lm.layers[7].layer.cell.h), clsfr_hidden_sz, relu)),
            gpu(BatchNorm(clsfr_hidden_sz, relu)),
            Dropout(clsfr_hidden_drop),
            gpu(Dense(clsfr_hidden_sz, clsfr_out_sz)),
            gpu(BatchNorm(clsfr_out_sz)),
            softmax
        )
    )
end

Flux.@treelike TextClassifier

# Forward step for classifier
function forward(tc::TextClassifier, gen; now_per_pass::Integer=32)
    classifier = mapleaves(Tracker.data, tc)
    X = take!(gen)
    l = length(X)
    maxpools, meanpools = [], []
    # Truncated Backprop through time
    for i=1:floor(l/now_per_pass)   # Tracking is swiched off inside this loop
        (i == 1 && l%now_per_pass != 0) ? (last_idx = l%now_per_pass) : (last_idx = now_per_pass)
        H = broadcast(x -> classifier.rnn_layers[1](indices(x, classifier.vocab, "_unk_")), X[1:last_idx])
        H = classifier.rnn_layers[2:end].(H)
        H = cat(H..., dims=3)
        push!(maxpools, maximum(H, dims=3)[:, :, 1])
        push!(meanpools, (sum(H, dims=3)/size(H, 3))[:, :, 1])
        X = X[last_idx+1:end]
        Flux.truncate!(classifier.rnn_layers)
    end
    # last part of the sequecnes in X - Tracking is swiched on
    H = broadcast(x -> tc.rnn_layers[1](indices(x, classifier.vocab, "_unk_")), X)
    H = tc.rnn_layers[2:end].(H)
    H = H[end:-1:1]
    append!(H, maxpools)
    append!(H, meanpools)
    H = tc.linear_layers(H[end:-1:1])
    return H
end

# Loss function for classifier
function loss(classifier::TextClassifier, gen::Channel; now_per_pass::Integer=32)
    H = forward(classifier, gen, now_per_pass=now_per_pass)
    Y = gpu(take!(gen))
    l = crossentropy(H, Y)
    Flux.reset!(classifier.rnn_layers)
    return l
end

# Training of classifier
function train_classifier!(classifier::TextClassifier=TextClassifier(), classes::Integer=1, hidden_layer_size::Integer=50, data_loader::Channel=imdb_classifier_data;
    batchsize::Integer=64, bptt::Integer=70, gradient_clip::Float64=0.25, stlr_cut_frac::Float64=0.1, stlr_ratio::Number=32, stlr_η_max::Float64=0.01, epochs::Integer=1, checkpoint_itvl=5000)
    trainable = []
    append!(trainable, [classifier.rnn_layers[[1, 3, 5, 7]]...])
    push!(trainable, [classifier.linear_layers[1:2]...])
    push!(trainable, [classifier.linear_layers[4:5]...])
    opts = [ADAM(0.001, (0.7, 0.99)) for i=1:length(trainable)]
    gpu!.(classifier.rnn_layers)

    for epoch=1:epochs
        gen = data_loader()
        num_of_iters = take!(gen)
        T = num_of_iters-Int(floor((num_of_iters*2)/100))
        cut = num_of_iters * epochs * stlr_cut_frac
        set_trigger!.(T, classifier.rnn_layers)
        for iter=1:num_of_iters
            l = loss(classifier, gen, now_per_pass = now_per_pass)

            # Slanted triangular learning rates
            t = iter + (epoch-1)*num_of_iters
            p_frac = (iter < cut) ? iter/cut : (1 - ((iter-cut)/(cut*(1/stlr_cut_frac-1))))
            ηL = stlr_η_max*((1+p_frac*(stlr_ratio-1))/stlr_ratio)

            # Gradual-unfreezing Step with discriminative fine-tuning
            unfreezed_layers, cur_opts = (epoch < length(trainable)) ? (trainable[end-epoch+1:end], opts[end-epoch+1:end]) : (trainable, opts)
            discriminative_step!(unfreezed_layers, ηL, l, gradient_clip, cur_opts)

            # ASGD Step
            asgd_step!.(iter, classifier.rnn_layers)

            reset_masks!.(classifier.rnn_layers)

            println("loss:", l, "epoch: ", epoch, "iteration: ", iter)
        end
    end
end

function predict(tc::TextClassifier, text_sents::Vector{String})
    testmode!(tc)
    classifier = mapleaves(Tracker.data, tc)
    predictions = []
    expr(x) = indices(x, classifier.vocab, "_unk_")
    for text in text_sents
        tokens = tokenize(tokens)
        h = classifier.rnn_layers.(expr.(tokens))
        probability_dist = classifier.linear_layers(h)
        class = argmax(probaility_dist)
        push!(predictions, class)
    end
    return predictions
end
