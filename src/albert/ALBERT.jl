module ALBERT
using Flux
using Requires
using Requires: @init
using BSON
using Transformers
using Transformers.Basic
using Transformers.Pretrain: isbson, iszip, istfbson, zipname, zipfile, findfile

export ALBERT
export masklmloss, preprocess_albert, from_pretrained
export model_version, preprocess_albert, create_albert

abstract type PretrainedTransformer end
abstract type ALBERT_V1 <: PretrainedTransformer end
abstract type ALBERT_V2 <: PretrainedTransformer end

const pretrained = Dict{DataType, Vector{String}}()

function model_version(::Type{T}) where T<:PretrainedTransformer
    get!(pretrained,T) do
        String[]
    end
end

include("utils.jl")
include("model.jl")
include("albert.jl")
include("pretrain.jl")
include("datadeps.jl")
end
 # module
