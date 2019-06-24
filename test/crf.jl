using Flux
using Flux: onehot, train!, Params, gradient
using TextAnalysis: CRF, crf_loss

@testset "crf" begin

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

    normalize(X, minn, maxx) = (X .- minn) ./ (maxx - minn)

    X = [normalize(x, minimum(minimum.(X)),  maximum(maximum.(X))) for x in X]

    labels = unique(Iterators.flatten(Y))
    num_labels = length(labels)
    num_features = size(X[1], 1)
    Y = map.(ch -> onehot(ch, labels), Y)

    m = CRF(num_labels, num_features)

    loss(x, y) = crf_loss(m, x, y) # TODO: change this to loss = crf_loss(m)

    opt = Descent(0.01)

    l1 = sum[loss(x,y) for (x,y) in zip(X,Y)]
    Flux.train!(loss, params(m), zip(X, Y), opt)
    l2 = sum[loss(x,y) for (x,y) in zip(X,Y)]

    @test l1 > l2
end

# TODO: sequence of varying lengths.
