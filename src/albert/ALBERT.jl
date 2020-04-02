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

#implement batchmul, batchtril for flux

include("tfckpt2bsonforalbert.jl")
include("alberttokenizer.jl")
include("sentencepiece.jl")
include("albert.jl")

end # module
