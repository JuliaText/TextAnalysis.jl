"""
ASGD Weight-Dropped LSTM
"""

using Flux
import Flux: gate, tanh, σ, Tracker, params, gpu, cpu, _testmode!, rand!, _dropout_kernel

cd(@__DIR__)
include("utils.jl")

gpu!(entity) = nothing
cpu!(entity) = nothing
reset_masks!(entity) = nothing
reset_probability!(entity) = nothing

# Generates Mask
function drop_mask(x, p)
    y = similar(x, size(x))
    rand!(y)
    y .= _dropout_kernel.(y, p, 1 - p)
    return y
end

drop_mask(shape::Tuple, p; type = Float32) = (mask = rand(type, shape...);mask .= _dropout_kernel.(mask, p, 1 - p))

#################### Weight-Dropped LSTM Cell ######################
mutable struct WeightDroppedLSTMCell{A, V, M}
    Wi::A
    Wh::A
    b::V
    h::V
    c::V
    p::Float64
    maskWi::M
    maskWh::M
    active::Bool
end

function WeightDroppedLSTMCell(in::Integer, out::Integer, probability::Float64=0.0;
    init = Flux.glorot_uniform)
    cell = WeightDroppedLSTMCell(
        param(init(out*4, in)),
        param(init(out*4, out)),
        param(init(out*4)),
        param(zeros(Float32, out)),
        param(zeros(Float32, out)),
        probability,
        drop_mask((out*4, in), probability),
        drop_mask((out*4, out), probability),
        true
    )
    cell.b.data[gate(out, 2)] .= 1
    return cell
end

function (m::WeightDroppedLSTMCell)((h, c), x)
    b, o = m.b, size(h, 1)
    Wi = m.active ? m.Wi .* m.maskWi : m.Wi
    Wh = m.active ? m.Wh .* m.maskWh : m.Wh
    g = Wi*x .+ Wh*h .+ b
    input = σ.(gate(g, o, 1))
    forget = σ.(gate(g, o, 2))
    cell = tanh.(gate(g, o, 3))
    output = σ.(gate(g, o, 4))
    c = forget .* c .+ input .* cell
    h′ = output .* tanh.(c)
    return (h′, c), h′
end

Flux.@treelike WeightDroppedLSTMCell

_testmode!(m::WeightDroppedLSTMCell, test) = (m.active = !test)

# Weight-Dropped LSTM [stateful]
function WeightDroppedLSTM(a...; kw...)
    cell = WeightDroppedLSTMCell(a...;kw...)
    hidden = (cell.h, cell.c)
    return Flux.Recur(cell, hidden, hidden)
end

function reset_masks!(wd::T) where T <: Flux.Recur{<:WeightDroppedLSTMCell}
    wd.cell.maskWi = drop_mask(wd.cell.Wi, wd.cell.p)
    wd.cell.maskWh = drop_mask(wd.cell.Wh, wd.cell.p)
    return
end
####################################################################

################## ASGD Weight-Dropped LSTM Layer ##################
mutable struct AWD_LSTM
    layer::Flux.Recur
    T::Integer
    accum
end

AWD_LSTM(in::Integer, out::Integer, probability::Float64=0.0; kw...) = AWD_LSTM(WeightDroppedLSTM(in, out, probability; kw...), -1, [])

Flux.@treelike AWD_LSTM

(m::AWD_LSTM)(in) = m.layer(in)

set_trigger!(t, m) = nothing
set_trigger!(trigger_point::Integer, m::AWD_LSTM) = m.T = trigger_point;

function gpu!(m::AWD_LSTM)
    m.layer = gpu(m.layer)
    isempty(m.accum) || (m.accum = gpu(m.accum))
    return
end

function cpu!(m::AWD_LSTM)
    m.layer = cpu(m.layer)
    isempty(m.accum) || (m.accum = cpu(m.accum))
    return
end

reset_masks!(awd::AWD_LSTM) = reset_masks!(awd.layer)

# Averaged Stochastic Gradient Descent Step
asgd_step!(i, l) = nothing

function asgd_step!(iter::Integer, layer::AWD_LSTM)
    if iter >= layer.T
        p = get_trainable_params([layer])
        avg_fact = 1/max(iter - layer.T + 1, 1)
        if avg_fact != 1
            layer.accum = layer.accum .+ Tracker.data.(p)
            for (ps, accum) in zip(p, layer.accum)
                Tracker.data(ps) .= avg_fact*accum
            end
        else
            layer.accum = deepcopy(Tracker.data.(p))   # Accumulator for ASGD
        end
    end
    return
end
####################################################################

"""
Variational Dropout
"""

########################## Varitional DropOut ######################
mutable struct VarDrop{F}
    p::F
    mask
    reset::Bool
    active::Bool
end

VarDrop(probability::Float64=0.0) = VarDrop(probability, Array{Float32, 2}(UndefInitializer(), 0, 0), true, true)

function (vd::VarDrop)(inp)
    vd.active || return inp
    if vd.reset
        vd.mask = drop_mask(inp, vd.p)
        vd.reset = false
    end
    return inp .* vd.mask
end

_testmode!(vd::VarDrop, test) = (vd.active = !test)

reset_masks!(vd::VarDrop) = (vd.reset = true;)

function gpu!(vd::VarDrop)
    vd.mask = gpu(vd.mask);
    return
end

function cpu!(vd::VarDrop)
    vd.mask = cpu(vd.mask);
    return
end
####################################################################

"""
Embeddings with varitional dropout
"""

################# Varitional Dropped Embeddings ####################
mutable struct DroppedEmbeddings{A, F}
    emb::A
    p::F
    mask
    active::Bool
end

function DroppedEmbeddings(in::Integer, embed_size::Integer, probability::Float64=0.0;
    init = Flux.glorot_uniform)
        de = DroppedEmbeddings{AbstractArray, typeof(probability)}(
            param(init(in, embed_size)),
            probability,
            drop_mask((in, embed_size), probability),
            true
        )
    return de
end

function (de::DroppedEmbeddings)(in::AbstractArray, tying::Bool=false)
    dropped = de.active ? de.emb .* de.mask : de.emb
    return tying ? dropped * in : transpose(dropped[in, :])
end

Flux.@treelike DroppedEmbeddings

_testmode!(de::DroppedEmbeddings, test) = (de.active = !test)

function gpu!(de::DroppedEmbeddings)
    de.emb = gpu(de.emb)
    de.mask = gpu(de.mask)
    return
end

function cpu!(de::DroppedEmbeddings)
    de.emb = cpu(de.emb)
    de.mask = cpu(de.mask)
    return
end

function reset_masks!(de::DroppedEmbeddings)
    de.mask = drop_mask(de.emb, de.p)
    return
end
####################################################################

"""
Concat-Pooled linear layer
"""

################# Concat Pooling Dense layer #######################
mutable struct PooledDense{F, S, T}
    W::S
    b::T
    σ::F
end

PooledDense(W, b) = PooledDense(W, b, identity)

function PooledDense(hidden_sz::Integer, out::Integer, σ = identity;
             initW = Flux.glorot_uniform, initb = (dims...) -> zeros(Float32, dims...))
return PooledDense(param(initW(out, hidden_sz*3)), param(initb(out)), σ)
end

Flux.@treelike PooledDense

function (a::PooledDense)(in)
    W, b, σ = a.W, a.b, a.σ
    in = cat(in..., dims=3)
    maxpool = maximum(in, dims=3)[:, :, 1]
    meanpool = (sum(in, dims=3)/size(in, 3))[:, :, 1]
    hc = cat(in[:, :, 1], maxpool, meanpool, dims=1)
    σ.(W*hc .+ b)
end

####################################################################

# Get the trainable params in the given layers
function get_trainable_params(layers)
    p = []
    function get_awd_params(awd::AWD_LSTM)
        return [awd.layer.cell.Wi,
        awd.layer.cell.Wh,
        awd.layer.cell.b]
    end
    for layer in layers
        layer isa Array || (layer = [layer])
        for l in layer
            l isa AWD_LSTM && (append!(p, get_awd_params(l)); continue)
            push!(p, l)
        end
    end
    return params(p...)
end
