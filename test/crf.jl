using Flux
using Flux: onehot, train!, Params, gradient, LSTM, Dense, reset!
using TextAnalysis: CRF, score_sequence, forward_score, viterbi_decode, crf_loss

Flux.@treelike TextAnalysis.CRF

@testset "crf" begin
    @testset "Loss function" begin
        input_seq = [rand(4) for i in 1:3]
        c = CRF(2)

        scores = []
        push!(scores, score_sequence(c, input_seq, [onehot(1, 1:2), onehot(1, 1:2), onehot(1, 1:2)]))
        push!(scores, score_sequence(c, input_seq, [onehot(1, 1:2), onehot(1, 1:2), onehot(2, 1:2)]))
        push!(scores, score_sequence(c, input_seq, [onehot(1, 1:2), onehot(2, 1:2), onehot(1, 1:2)]))
        push!(scores, score_sequence(c, input_seq, [onehot(1, 1:2), onehot(2, 1:2), onehot(2, 1:2)]))
        push!(scores, score_sequence(c, input_seq, [onehot(2, 1:2), onehot(1, 1:2), onehot(1, 1:2)]))
        push!(scores, score_sequence(c, input_seq, [onehot(2, 1:2), onehot(1, 1:2), onehot(2, 1:2)]))
        push!(scores, score_sequence(c, input_seq, [onehot(2, 1:2), onehot(2, 1:2), onehot(1, 1:2)]))
        push!(scores, score_sequence(c, input_seq, [onehot(2, 1:2), onehot(2, 1:2), onehot(2, 1:2)]))

        init_α = fill(-10000, (c.n + 2, 1))
        init_α[c.n + 1] = 0

        s1 = sum(exp.(scores))
        s2 = exp(forward_score(c, input_seq, init_α))

        @test (s1 - s2) / max(s1,s2) <= 0.00000001
    end

    @testset "Viterbi Decode" begin
        input_seq = [rand(4) for i in 1:3]
        c = CRF(2)

        k1 = [onehot(1, 1:2), onehot(1, 1:2), onehot(1, 1:2)]
        k2 = [onehot(1, 1:2), onehot(1, 1:2), onehot(2, 1:2)]
        k3 = [onehot(1, 1:2), onehot(2, 1:2), onehot(1, 1:2)]
        k4 = [onehot(1, 1:2), onehot(2, 1:2), onehot(2, 1:2)]
        k5 = [onehot(2, 1:2), onehot(1, 1:2), onehot(1, 1:2)]
        k6 = [onehot(2, 1:2), onehot(1, 1:2), onehot(2, 1:2)]
        k7 = [onehot(2, 1:2), onehot(2, 1:2), onehot(1, 1:2)]
        k8 = [onehot(2, 1:2), onehot(2, 1:2), onehot(2, 1:2)]
        k = [k1, k2, k3, k4, k5, k6, k7, k8]

        scores = []
        push!(scores, score_sequence(c, input_seq, k1))
        push!(scores, score_sequence(c, input_seq, k2))
        push!(scores, score_sequence(c, input_seq, k3))
        push!(scores, score_sequence(c, input_seq, k4))
        push!(scores, score_sequence(c, input_seq, k5))
        push!(scores, score_sequence(c, input_seq, k6))
        push!(scores, score_sequence(c, input_seq, k7))
        push!(scores, score_sequence(c, input_seq, k8))

        maxscore_idx = argmax(scores)

        init_α = fill(-10000, (c.n + 2, 1))
        init_α[c.n + 1] = 0

        @test viterbi_decode(c, input_seq, init_α) == k[maxscore_idx]
    end

    @testset "CRF with Flux Layers" begin
        path = "data/weather.csv"
        function load(path::String)
            lines = readlines(path)
            lines = strip.(lines)
            Xs = []
            Ys = []
            xs = Array{Array{Float32, 2},1}()
            ys = Array{String,1}()

            for line in lines
                if isempty(line)
                    push!(Xs, xs)
                    push!(Ys, ys)
                    xs = Array{Array{Float32, 2},1}()
                    ys = Array{String,1}()
                else
                    x = zeros(Float32, 2, 1)
                    x1, x2, y = split(line, ',')
                    x[1] = parse(Float32, x1)
                    x[2] = parse(Float32, x2)
                    push!(xs, x)
                    push!(ys, y)
                end
            end

            if length(xs) != 0
                push!(Xs, xs)
                push!(Ys, ys)
            end
            return Xs, Ys
        end

        X, Y = load(path)

        # normalize(X, minn, maxx) = (X .- minn) ./ (maxx - minn)
        # X = [normalize(x, minimum(minimum.(X)),  maximum(maximum.(X))) for x in X]

        labels = unique(Iterators.flatten(Y))
        num_labels = length(labels)
        num_features = length(X[1][1])

        Y = map.(ch -> onehot(ch, labels), Y)

        LSTM_STATE_SIZE = 5
        d_out = Dense(LSTM_STATE_SIZE, num_labels + 2)
        lstm = LSTM(num_features, LSTM_STATE_SIZE)
        m(x) = d_out.(lstm.(x))

        Flux.@treelike TextAnalysis.CRF
        c = TextAnalysis.CRF(num_labels)
        init_α = fill(-10000, (c.n + 2, 1))
        init_α[c.n + 1] = 0

        using TextAnalysis: crf_loss
        Flux.@treelike CRF

        loss(xs, ys) = crf_loss(c, m(xs), ys, init_α)

        opt = Descent(0.01)
        data = zip(X, Y)

        ps = params(params(lstm)..., params(d_out)..., params(c)...)

        function train()
            for d in data
                reset!(lstm)
                grads = Tracker.gradient(() -> loss(d[1], d[2]), ps)
                Flux.Optimise.update!(opt, ps, grads)
            end
        end

        function find_loss(d)
            reset!(lstm)
            loss(d[1], d[2])
        end

        l1 = sum([find_loss(d) for d in data])
        dense_param_1 = deepcopy(Tracker.data(d_out.W))
        lstm_param_1 = deepcopy(Tracker.data(lstm.cell.Wh))
        crf_param_1 = deepcopy(Tracker.data(c.W))

        for i in 1:10
            train()
        end

        dense_param_2 = deepcopy(Tracker.data(d_out.W))
        lstm_param_2 = deepcopy(Tracker.data(lstm.cell.Wh))
        crf_param_2 = deepcopy(Tracker.data(c.W))
        l2 = sum([find_loss(d) for d in data])

        @test l1 > l2
        @test dense_param_1 != dense_param_2
        @test lstm_param_1 != lstm_param_2
        @test crf_param_1 != crf_param_2
    end
end

# TODO: sequence of varying lengths.
