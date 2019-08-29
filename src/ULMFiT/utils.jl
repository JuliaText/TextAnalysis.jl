"""
Helping functions
"""

# Converts vector of words to vector of indices
function indices(wordVect::Vector, vocab::Vector, unk::String="_unk_")
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
function generator(c::Channel, corpus::AbstractDocument; batchsize::Integer=64, bptt::Integer=70)
    X_total = post_pad_sequences(chunk(tokens(corpus), batchsize))
    n_batches = Int(floor(length(X_total[1])/bptt))
    put!(c, n_batches)
    for i=1:n_batches
        start = bptt*(i-1) + 1
        batch = [Flux.batch(X_total[k][j] for k=1:batchsize) for j=start:start+bptt]
        put!(c, batch[1:end-1])
        put!(c, batch[2:end])
    end
end

"""
    get_buckets(c::Corpus, bucketsize::Integer)

Simple Sequence-Bucketing

This function will return the groups of `Document`s with close sequence lengths from the given `Corpus`

# Example:

julia> corpus = get_buckets(corpus, 32)

"""
function get_buckets(c::Corpus, labels::Vector, bucketsize::Integer, return_channel::Bool)
    lengths = length.(tokens.(documents(c)))
    sorted_lens = sortperm(lengths)
    c, labels = c[sorted_lens], labels[sorted_lens]
    buckets = []
    return_channel &&
    for i=1:bucketsize:length(c)
        (length(c) - i) < (bucketsize-1) && (push!(buckets, c[i:end]);continue)
        push!(buckets, c[i:bucketsize-1])
    end
    return buckets
end

# Data loader
function data_loader(dataset::Corpus, labels::Vector, classes::Vector, batchsize::Integer, sorted::Bool)
    iters = Int(floor(length(dataset)/batchsize))
    Channel(csize=1) do loader
        for i=1:iters
            X = tokens.(dataset[(i-1)*batchsize+1:i*batchsize])
            Y = Flux.onehotbatch(labels[(i-1)*batchsize+1:i*batchsize], classes)
            X = pre_pad_sequences(X, "_pad_")
            put!(docs, [Flux.batch(X[k][j] for k=1:batchsize) for j=1:length(X[1])])
            put!(docs, Y)
        end
    end
end
