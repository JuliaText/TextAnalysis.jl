"""
ULMFiT - Text Classifier

This is wrapper around the LanguageMode struct. It has three fields:

vocab           : contains the same vocabulary from the LanguageModel
rnn_layers      : contains same DroppedEmebeddings, LSTM (AWD_LSTM) and VarDrop layers of LanguageModel except for last softmax layer
linear_layers   : contains Chain of two Dense layers [PooledDense and Dense] with softmax layer

To train create and instance and give it as first argument to 'train_classifier!' function
"""
mutable struct TextClassifier
    vocab::Vector
    rnn_layers::Flux.Chain
    linear_layers::Flux.Chain
end

function TextClassifier(lm::LanguageModel=LanguageModel(), clsfr_out_sz::Integer=1, clsfr_hidden_sz::Integer=50, clsfr_hidden_drop::Float64=0.4)
    return TextClassifier(
        lm.vocab,
        lm.layers[1:8],
        Chain(
            gpu(PooledDense(length(lm.layers[7].layer.cell.h), clsfr_hidden_sz)),
            gpu(BatchNorm(clsfr_hidden_sz, relu)),
            Dropout(clsfr_hidden_drop),
            gpu(Dense(clsfr_hidden_sz, clsfr_out_sz)),
            gpu(BatchNorm(clsfr_out_sz)),
            softmax
        )
    )
end

Flux.@treelike TextClassifier

"""
Cross Validate

This function will be used to cross-validate the classifier

Arguments:

tc              : Instance of TextClassfier
gen             : 'Channel' to get a mini-batch from validation set
num_of_batches  : specifies the number of batches the validation will be done

If num_of_batches is not specified then all the batches which can be given by the
gen will be used for validation
"""
function validate(tc::TextClassifier, gen::Channel, num_of_batches::Union{Colon, Integer})
    n_classes = size(tc.linear_layers[end-2].W, 1)
    classifier = mapleaves(Tracker.data, tc)
    Flux.testmode!(classifier)
    loss = 0
    iters = take!(gen)
    ((num_of_batches != :) & (num_of_batches < iters)) && (iters = num_of_batches)
    TP, TN = gpu(zeros(Float32, n_classes, 1)), gpu(zeros(Float32, n_classes, 1))
    FP, FN = gpu(zeros(Float32, n_classes, 1)), gpu(zeros(Float32, n_classes, 1))
    for i=1:num_of_batches
        X = take!(gen)
        Y = gpu(take!(gen))
        X = map(x -> indices(x, classifier.vocab, "_unk_"), X)
        H = classifier.rnn_layers.(X)
        H = classifier.linear_layers(H)
        l = crossentropy(H, Y)
        Flux.reset!(classifier.rnn_layers)
        TP .+= sum(H .* Y, dims=2)
        FN .+= sum(((-1 .* H) .+ 1) .* Y, dims=2)
        FP .+= sum(H .* ((-1 .* Y) .+ 1), dims=2)
        TN .+= sum(((-1 .* H) .+ 1) .* ((-1 .* Y) .+ 1), dims=2)
        loss += l
    end
    precisions = TP ./ (TP .+ FP)
    recalls = TP ./ (TP .+ FN)
    F1 = (2 .* (precisions .* recalls)) ./ (precisions .+ recalls)
    accuracy = (TP[1] + TN[1])/(TP[1] + TN[1] + FP[1] + FN[1])
    return (loss, accuracy, precisions, recalls, F1)
end

"""
Forward pass

This funciton does the main computation of a mini-batch.
It computes the output of the all the layers [RNN and DENSE layers] and returns the predicted output for that pass.
It uses Truncated Backprop through time to compute the output.

Arguments:
tc              : Instance of TextClassifier
gen             : data loader, which will give 'X' of the mini-batch in one call
tracked_steps   : This is the number of tracked time-steps for Truncated Backprop thorugh time,
                  these will be last time-steps for which gradients will be calculated.
"""
function forward(tc::TextClassifier, gen::Channel, tracked_steps::Integer=32)
  	# swiching off tracking
    classifier = mapleaves(Tracker.data, tc)
    X = take!(gen)
    l = length(X)
    # Truncated Backprop through time
    for i=1:ceil(l/now_per_pass)-1   # Tracking is swiched off inside this loop
        (i == 1 && l%now_per_pass != 0) ? (last_idx = l%now_per_pass) : (last_idx = now_per_pass)
        H = broadcast(x -> indices(x, classifier.vocab, "_unk_"), X[1:last_idx])
        H = classifier.rnn_layers.(H)
        X = X[last_idx+1:end]
    end
    # set the lated hidden states to original model
    for (t_layer, unt_layer) in zip(tc.rnn_layers[2:end], classifier.rnn_layers[2:end])
        if t_layer isa AWD_LSTM
            t_layer.layer.state = unt_layer.layer.state
            continue
        end
        if !unt_layer.reset
            t_layer.mask = unt_layer.mask
            t_layer.reset = false
        end
    end
    # last part of the sequecnes in X - Tracking is swiched on
    H = broadcast(x -> tc.rnn_layers[1](indices(x, classifier.vocab, "_unk_")), X)
    H = tc.rnn_layers[2:end].(H)
    H = tc.linear_layers(H)
    return H
end

"""
    loss(classifier::TextClassifier, gen::Channel, tracked_steps::Integer=32)

LOSS function

It takes the output of the forward funciton and returns crossentropy loss.

Arguments:

classifier    : Instance of TextClassifier
gen           : 'Channel' [data loader], to give a mini-batch
tracked_words : specifies the number of time-steps for which tracking is on
"""
function loss(classifier::TextClassifier, gen::Channel, tracked_steps::Integer=32)
    H = forward(classifier, gen, tracked_steps)
    Y = gpu(take!(gen))
    l = crossentropy(H, Y)
    Flux.reset!(classifier.rnn_layers)
    return l
end

"""
    train_classifier!(classifier::TextClassifier=TextClassifier(), classes::Integer=1,
            data_loader::Channel=imdb_classifier_data, hidden_layer_size::Integer=50;kw...)

It contains main training loops for training a defined classifer for specified classes and data.
Usage is discussed in the docs.
"""
function train_classifier!(classifier::TextClassifier=TextClassifier(), classes::Integer=1,
    data_loader::Channel=imdb_classifier_data, hidden_layer_size::Integer=50;
    stlr_cut_frac::Float64=0.1, stlr_ratio::Number=32, stlr_η_max::Float64=0.01,
    val_loader::Channel=nothing, cross_val_batches::Union{Colon, Integer}=:,
    epochs::Integer=1, checkpoint_itvl=5000)

    trainable = []
    append!(trainable, [classifier.rnn_layers[[1, 3, 5, 7]]...])
    push!(trainable, [classifier.linear_layers[1:2]...])
    push!(trainable, [classifier.linear_layers[4:5]...])
    opts = [ADAM(0.001, (0.7, 0.99)) for i=1:length(trainable)]
    gpu!.(classifier.rnn_layers)

    for epoch=1:epochs
        println("Epoch: $epoch")
        gen = data_loader()
        num_of_iters = take!(gen)
        cut = num_of_iters * epochs * stlr_cut_frac
        for iter=1:num_of_iters
            l = loss(classifier, gen, now_per_pass = now_per_pass)

            # Slanted triangular learning rates
            t = iter + (epoch-1)*num_of_iters
            p_frac = (iter < cut) ? iter/cut : (1 - ((iter-cut)/(cut*(1/stlr_cut_frac-1))))
            ηL = stlr_η_max*((1+p_frac*(stlr_ratio-1))/stlr_ratio)

            # Gradual-unfreezing Step with discriminative fine-tuning
            unfreezed_layers, cur_opts = (epoch < length(trainable)) ? (trainable[end-epoch+1:end], opts[end-epoch+1:end]) : (trainable, opts)
            discriminative_step!(unfreezed_layers, ηL, l, cur_opts)

            reset_masks!.(classifier.rnn_layers)    # reset all dropout masks
        end
        println("Train set accuracy: $trn_accu , Training loss: $trn_loss")
        if val_loader != nothing
            val_loss, val_acc, val_precisions, val_reacalls, val_F1_scores = validate(classifer, val_loader)
        else
            continue
        end
        #!(val_loader isa nothing) ? (val_loss, val_acc, val_precisions, val_reacalls, val_F1_scores = validate(classifer, val_loader)) : continue
        println("Cross validation loss: $val_loss")
        println("Cross validation accuracy:\n $val_acc")
        println("Cross validation class wise Precisions:\n $val_precisions")
        println("Cross validation class wise Recalls:\n $val_recalls")
        println("Cross validation class wise F1 scores:\n $val_F1_scores")
    end
end

"""
    predict(tc::TextClassifier, text_sents::Corpus)

This function can be used to test the model after training.
It returns the predictions done by the model for given `Corpus` of `Documents`
All the preprocessing related to the used vocabulary should be done before using this function.
Use `prepare!` function to do preprocessing
"""
function predict(tc::TextClassifier, text_sents::Corpus)
    classifier = mapleaves(Tracker.data, tc)
    Flux.testmode!(classifier)
    predictions = []
    expr(x) = indices(x, classifier.vocab, "_unk_")
    for text in text_sents
        tokens = tokens(text)
        h = classifier.rnn_layers.(expr.(tokens))
        probability_dist = classifier.linear_layers(h)
        class = argmax(probaility_dist)
        push!(predictions, class)
    end
    return predictions
end
