"""
ULMFiT - Fine-tuning Language Model

This file contains the funcitons needed to fine-tune a pretrained model.
The novel methods describe the ULMFiT paper are used:

    Discriminative fine-tuning
    Slanted triangular learning rates

"""

"""
    discriminative_step!(layers, ηL::Float64, l, opts::Vector)

Discriminative fine-tuning Step
This function performs the backpropagation step with discriminative fine-tune method,
that is, it uses different learning rates for different layers.

Arguments:

layers      : layers whose weights are going to get updated
ηL          : learning rate of the last layer in `layers`
opts        : `Vector` of optimizers used to update weights for corresponding layers

NOTE: length(opts) == length(layers)
"""
function discriminative_step!(layers, ηL::Float64, l, opts::Vector)
    @assert length(opts) == length(layers)
    # Gradient calculation
    grads = Tracker.gradient(() -> l, get_trainable_params(layers))

    # discriminative step
    ηl = ηL/(2.6^(length(layers)-1))
    for (layer, opt) in zip(layers, opts)
        opt.eta = ηl
        for ps in get_trainable_params([layer])
            Tracker.update!(opt, ps, grads[ps])
        end
        ηl *= 2.6
    end
    return
end

"""
    fine_tune_lm!(lm::LanguageModel, data_loader::Channel=imdb_fine_tune_data,
            stlr_cut_frac::Float64=0.1, stlr_ratio::Float32=32, stlr_η_max::Float64=4e-3;
            epochs::Integer=1, checkpoint_itvl::Integer=5000)

This function contains main training loops for fine-tuning the language model.
To use this funciton, an instance of LanguageModel and a data loader is needed.
Read the docs for more info about arguments
"""
function fine_tune_lm!(lm::LanguageModel, data_loader::Channel=imdb_fine_tune_data,
        stlr_cut_frac::Float64=0.1, stlr_ratio::Float32=32, stlr_η_max::Float64=4e-3;
        epochs::Integer=1, checkpoint_itvl::Integer=5000)

    opts = [ADAM(0.001, (0.7, 0.99)) for i=1:4]
    cut = num_of_iters * epochs * stlr_cut_frac

    # Fine-Tuning loops
    for epoch=1:epochs
        println("\nEpoch: $epoch")
        gen = data_loader()
        num_of_iters = take!(gen)
        T = num_of_iters-Int(floor((num_of_iters*2)/100))
        set_trigger!.(T, lm.layers)
        for i=1:num_of_iters

            # FORWARD
            l = loss(lm, gen)

            # Slanted triangular learning rate step
            t = i + (epoch-1)*num_of_iters
            p_frac = (i < cut) ? i/cut : (1 - ((i-cut)/(cut*(1/stlr_cut_frac-1))))
            ηL = stlr_η_max*((1+p_frac*(stlr_ratio-1))/stlr_ratio)

            # Backprop with discriminative fine-tuning step
            discriminative_step!(lm.layers[[1, 3, 5, 7]], ηL, l, opts)

            # Resets dropout masks for all the layers with DropOut or DropConnect
            reset_masks!.(lm.layers)
        end
    end
end

"""
    get_vocab(corpus::TokenDocument, lm::LanguageModel)

Returns vocabulary of the given tokenized corpus based on the given language model vocabulary.
"""
function get_vocab(corpus::TokenDocument, lm::LanguageModel)
    u = unique(tokens(corpus))
    new_vocab = intersect(vocab, lm.vocab)
    return new_vocab
end


"""
    set_vocab!(lm::LanguageModel, vocab::Vector)

Sets new vocabulary to the LanguageModel in `vocab` field.
With keeping the same embeddings of previous vocabulary.

Recommended to use this with `get_vocab` function:

Example:
julia> new_vocab = get_vocab(corpus, lm);

julia> set_vocab!(lm, new_vocab)

In addtion to this also incorporate special tokens for UNKNOWN (e.g. "_unk_"), PADDING (e.g. "_pad_") etc.
To add these use `insert!` function after getting vocabulary from `get_vocab` function.
To use `set_vocab!` it is important that the tokens added are same as in the previous vocabulary of Language model,
so that the embeddings for these tokens can be extracted for the previous embeddings of Language model.

# Example:

julia> insert!(vocab, 1, "_unk_")
julia> insert!(vocab, 2, "_pad_")
"""
function set_vocab!(lm::LanguageModel, vocab::Vector)
    idxs = indices(vocab, lm.vocab)
    lm.vocab = vocab
    lm.layers[1].emb = param(Tracker.data(lm.layers[1].emb)[idxs, :])
    lm.layers[1].mask = gpu(drop_mask((length(vocab),), lm.layers[1].p))
    return
end
