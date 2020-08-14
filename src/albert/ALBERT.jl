module ALBERT
using Flux
using Requires
using Requires: @init
using BSON
using Transformers
using Transformers.Basic
using Transformers.Pretrain: isbson, iszip, istfbson, zipname, zipfile, findfile

export ALBERT
export load_albert_pretrain, albert_pretrain_task, masklmloss,WordPiece,tokenise
export tfckpt2bsonforalbert, ALBERT_V1, ALBERT_V2, model_version

abstract type PretrainedTransformer end
abstract type ALBERT_V1 <: PretrainedTransformer end
abstract type ALBERT_V2 <: PretrainedTransformer end

const pretrained = Dict{DataType, Vector{String}}()

function model_version(::Type{T}) where T<:PretrainedTransformer
    get!(pretrained,T) do
        String[]
    end
end


include("model.jl")
include("albert.jl")
include("pretrain.jl")
include("datadeps.jl")
end
 # module
