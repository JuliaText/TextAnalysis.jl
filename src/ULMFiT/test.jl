"""
ULMFiT - testing file
"""

# Test the language model on the validation set
function test_lm(lm, data_gen)
    testmode!(lm.layers)
    model_layers = mapleaves(Tracker.data, lm.layers)
    sum_l, l_vect = 0, []
    for iter=1:num_of_iters
        x, y = take!(data_gen)
        h = broadcast(w -> model_layers[1](indices([w], lm.vocab, "_unk_")), x)
        h = model_layers[2:end].(h)
        y = broadcast(x -> Flux.onehotbatch([x], lm.vocab, "_unk_"), y)
        Flux.reset!(model_layers)
        l = sum(crossentropy.(h, y))
        sum_l += l
        push!(l_vect, l)
    end
    return sum_l/num_of_iters, l_vect
end

# Sampling
function sampling(starting_text::String, lm::LanguageModel=LanguageModel())
    testmode!(lm.layers)
    model_layers = mapleaves(Tracker.data, lm.layers)
    tokens = tokenize(starting_text)
    word_indices = map(x -> indices([x], lm.vocab, "_unk_"), tokens)
    embeddings = model_layers[1].(word_indices)
    h = (model_layers[2:end].(embeddings))[end]
    probabilities = model_layers[end-1:end](h)
    prediction = lm.vocab[findall(isequal(maximum(probabilities)), probabilities)[1]]
    println("SAMPLING...")
    print(prediction, ' ')
    while true
        h = model_layers[1](indices([prediction], lm.vocab, "_unk_"))
        h = model_layers[2:end](h)
        probabilities = model_layers[end-1:end](h)
        prediction = lm.vocab[findall(isequal(maximum(probabilities)), probabilities)[1]]
        print(prediction, ' ')
        prediction == "_pad_" && break
    end
end

# Test Classifier
function test_classifier(tc::TextClassifier, data_gen)
    testmode!(tc)
    classifier = mapleaves(Tracker.data, tc)
    sum_l, l_vect = 0, []
    num_of_iters = take!(data_gen)
    for iter=1:num_of_iters
        x = take!(data_gen)
        y = take!(data_gen)
        h = broadcast(x -> classifier.rnn_layers[1](indices([x], lm.vocab, "_unk_")), x)
        h = classifier.rnn_layers[2:end].(h)
        h = classifier.linear_layers(h)
        Flux.reset!(classifier)
        l = crossentropy(h, y)
        sum_l += l
        push!(l_vect, l)
    end
    return sum_l/num_of_iters, l_vect
end
