using Flux
using Flux: onehot, train!, Params, gradient

Flux.@treelike TextAnalysis.CRF

@testset "crf" begin
    @testset "Loss function" begin
        input_seq = [rand(3) for i in 1:3]
        c = TextAnalysis.CRF(2, 3)

        scores = []
        push!(scores, TextAnalysis.score_sequence(c, input_seq, [onehot(1, 1:2), onehot(1, 1:2), onehot(1, 1:2)]))
        push!(scores, TextAnalysis.score_sequence(c, input_seq, [onehot(1, 1:2), onehot(1, 1:2), onehot(2, 1:2)]))
        push!(scores, TextAnalysis.score_sequence(c, input_seq, [onehot(1, 1:2), onehot(2, 1:2), onehot(1, 1:2)]))
        push!(scores, TextAnalysis.score_sequence(c, input_seq, [onehot(1, 1:2), onehot(2, 1:2), onehot(2, 1:2)]))
        push!(scores, TextAnalysis.score_sequence(c, input_seq, [onehot(2, 1:2), onehot(1, 1:2), onehot(1, 1:2)]))
        push!(scores, TextAnalysis.score_sequence(c, input_seq, [onehot(2, 1:2), onehot(1, 1:2), onehot(2, 1:2)]))
        push!(scores, TextAnalysis.score_sequence(c, input_seq, [onehot(2, 1:2), onehot(2, 1:2), onehot(1, 1:2)]))
        push!(scores, TextAnalysis.score_sequence(c, input_seq, [onehot(2, 1:2), onehot(2, 1:2), onehot(2, 1:2)]))

        s1 = sum(exp.(scores))
        s2 = sum(TextAnalysis.forward_algorithm(c, input_seq))
        s3 = sum(exp.(TextAnalysis.forward_algorithm_stable(c, input_seq)))

        @test isapprox(s1, s2, atol=1e-8)
        @test (s1 - s3) / max(s1, s3) <= 0.25
    end

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

    @testset "Only CRFs" begin
        m = TextAnalysis.CRF(num_labels, num_features)

        loss(x, y) = crf_loss(m, x, y) # TODO: change this to loss = crf_loss(m)

        opt = Descent(0.01)

        l1 = sum([loss(x,y) for (x,y) in zip(X,Y)])

        Flux.train!(loss, params(m), zip(X, Y), opt)
        Flux.train!(loss, params(m), zip(X, Y), opt)

        l2 = sum([loss(x,y) for (x,y) in zip(X,Y)])

        @test l1 > l2
    end

    @testset "CRF with Dense" begin
        num_features = 3
        d = Dense(2, num_features)
        c = TextAnalysis.CRF(num_labels, num_features)

        loss(x, y) = crf_loss(c, d(x), y)

        opt = Descent(0.01)

        l1 = sum([loss(x,y) for (x,y) in zip(X,Y)])
        dense_param_1 = d.W[1]

        Flux.train!(loss, params(c, d), zip(X, Y), opt)
        Flux.train!(loss, params(c, d), zip(X, Y), opt)

        dense_param_2 = d.W[1]
        l2 = sum([loss(x,y) for (x,y) in zip(X,Y)])

        @test l1 > l2
        @test dense_param_1 != dense_param_2
    end
end

# TODO: sequence of varying lengths.
