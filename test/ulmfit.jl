using DataDeps
using BSON

@testset "Custom layers" begin
    @testset "WeightDroppedLSTM" begin
        wd = ULMFiT.WeightDroppedLSTM(4, 5, 0.3)
        @test all(wd.init .== wd.state)
        @test size(wd.cell.Wi) == size(wd.cell.maskWi)
        @test size(wd.cell.Wh) == size(wd.cell.maskWh)
        @test wd.cell.active
        @test_throws DimensionMismatch wd(rand(5, 3))
        x = rand(Float32, 4, 3)
        h = wd(x)
        @test size(h) == size(wd.state[1]) == (5, 3)
        maski = deepcopy(wd.cell.maskWi)
        maskh = deepcopy(wd.cell.maskWh)
        ULMFiT.reset_masks!(wd)
        @test maski != wd.cell.maskWi
        @test maskh != wd.cell.maskWh
        Flux.testmode!(wd)
        @test !(wd.cell.active)
        @test length(params(wd)) == 5
    end

    @testset "AWD_LSTM" begin
        awd = ULMFiT.AWD_LSTM(4, 3, 0.3)
        @test awd.layer.cell isa ULMFiT.WeightDroppedLSTMCell
        @test length(awd.accum) == 0
        ULMFiT.set_trigger!(4, awd)
        @test awd.T == 4
        ULMFiT.asgd_step!(4, awd)
        @test length(awd.accum) == 3
        temp = deepcopy(awd.accum[1][1])
        @test temp == Tracker.data(awd.layer.cell.Wi[1])
        ULMFiT.asgd_step!(5, awd)
        temp += temp
        @test temp == Tracker.data(awd.accum[1][1])
        @test length(params(awd)) == 5
    end

    @testset "VarDrop" begin
        vd = ULMFiT.VarDrop(0.3)
        @test vd.active
        @test vd.reset
        x = rand(10, 10)
        @test size(vd(x)) == size(x) == size(vd.mask)
        x = rand(5, 5)
        @test_throws DimensionMismatch vd(x)
        ULMFiT.reset_masks!(vd)
        @test vd.reset
        Flux.testmode!(vd)
        @test ~vd.active
        x = rand(10, 10)
        @test vd(x) == x
        @test size(vd(x)) == size(x) == size(vd.mask)
    end

    @testset "DroppedEmbeddings" begin
        de = ULMFiT.DroppedEmbeddings(6, 4, 0.2)
        @test size(de.emb) == (6, 4)
        @test size(de.mask) == (6,)
        x = [2,4,6,0.1]
        @test_throws BoundsError de(x)
        x = [2,4,6]
        @test size(de(x)) == (4, 3)
        x = rand(5, 3)
        @test_throws DimensionMismatch de(x, true)
        x = rand(4, 3)
        @test size(de(x, true)) == (6, 3)
        mask = de.mask
        ULMFiT.reset_masks!(de)
        mask != de.mask
        Flux.testmode!(de)
        @test ~de.active
        @test length(params(de)) == 1
    end

    @testset "PooledDense" begin
        pd = ULMFiT.PooledDense(10, 5)
        @test size(pd.W) == (5, 30)
        @test length(pd.b) == 5
        x = rand(Float32, 10, 3)
        @test_throws DimensionMismatch pd(x)
        @test size(pd([x])) == (5, 3)
        @test length(params(pd)) == 2
    end
end

@testset "Language model" begin
    lm = ULMFiT.LanguageModel()
    @test typeof(lm.vocab) == Vector{String}
    @test length(lm.vocab) == size(lm.layers[1].emb, 1)
    @test length(lm.layers) == 10
    @test length(params(lm)) == 16
    @test length(ULMFiT.get_trainable_params(lm.layers)) == 10

    pretrained_weights = BSON.load(datadep"Pretrained ULMFiT Language Model/ulmfit_lm_en.bson")
    @test length(pretrained_weights[:weights]) == 16
    @test all(size.(params(lm)) .== size.(pretrained_weights[:weights]))
end

@testset "Text Classifier" begin
    lm = ULMFiT.LanguageModel()
    tc = ULMFiT.TextClassifier(lm)
    @test tc.rnn_layers == lm.layers[1:8]
    @test length(tc.linear_layers) == 6
end
