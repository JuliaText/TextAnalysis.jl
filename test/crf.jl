using Flux: onehot, train!, Params, gradient
using Flux
using TextAnalysis: CRF, crf_loss

# @testset "crf" begin

    path = "data/weather.csv"
    function load(path::String)
        stream = open(path, "r")
        Xs = []
        Ys = []
        xs = []
        ys = Array{String,1}()

        for line in map(strip, eachline(stream))
            if isempty(line)
                push!(Xs, hcat(xs...))
                push!(Ys, ys)
                xs = []
                ys = []
            else
                x1, x2, y = split(line, ',')
                push!(xs, [parse(Float64, x1), parse(Float64, x2) ])
                push!(ys, y)
            end
        end
        if length(xs) != 0
            push!(Xs, hcat(xs...))
            push!(Ys, ys)
        end

        close(stream)
        return Xs, Ys
    end

    X, Y = load(path)

    labels = unique(Iterators.flatten(Y))
    num_labels = length(labels)
    num_features = size(X[1], 1)

    Y = map.(ch -> onehot(ch, labels), Y)

    train_X = X[1:10]
    train_Y = Y[1:10]

    m = CRF(num_labels, num_features)

    loss(x, y) = crf_loss(m, x, y) # TODO: change this to loss = crf_loss(m)

    opt = ADAM(0.01)

    Flux.train!(loss, params(m), zip(train_X, train_Y), opt)

# end

# TODO: sequence of varying lengths.
