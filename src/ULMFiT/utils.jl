"""
Helping functions
"""

# Converts vector of words to vector of indices
function indices(wordVect::Vector, vocab::Vector, unk)
    function index(x, unk)
        idx = something(findfirst(isequal(x), vocab), 0)
        idx > 0 || return findfirst(isequal(unk), vocab)
        return idx
    end
    return broadcast(x -> index(x, unk), wordVect)
end

# Padding multiple sequences w r t the max size sequence
function pre_pad_sequences(sequences::Vector, pad::String="_pad_")
    max_len = maximum([length(x) for x in sequences])
    return [[fill(pad, max_len-length(sequence)); sequence] for sequence in sequences]
end

function post_pad_sequences(sequences::Vector, pad::String="_pad_")
    max_len = maximum([length(x) for x in sequences])
    return [[sequence; fill(pad, max_len-length(sequence))] for sequence in sequences]
end

# To initialize funciton for model LSTM weights
init_weights(extreme::AbstractFloat, dims...) = randn(Float32, dims...) .* sqrt(Float32(extreme))

# Generator, whenever it should be called two times since it gives X in first and y in second call
function generator(c::Channel, corpus; batchsize::Integer=64, bptt::Integer=70)
    X_total = post_pad_sequences(chunk(corpus, batchsize))
    n_batches = Int(floor(length(X_total[1])/bptt))
    put!(c, n_batches)
    for i=1:n_batches
        start = bptt*(i-1) + 1
        batch = [Flux.batch(X_total[k][j] for k=1:batchsize) for j=start:start+bptt]
        put!(c, batch[1:end-1])
        put!(c, batch[2:end])
    end
end

# To save model
function save_model!(m::LanguageModel, filepath::String="ULMFiT-LM.bson")
    weights = cpu.(Tracker.data.(params(m)))
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
