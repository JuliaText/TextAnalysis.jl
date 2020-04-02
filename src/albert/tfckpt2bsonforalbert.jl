# turn a tf bert format to bson

using JSON
using ZipFile

using Flux: loadparams!


"""
    tfckpt2bsonforalbert(path;
                raw=false,
                saveto="./",
                confname = "albert_config.json",
                ckptname = "model.ckpt-best",
                vocabname = "30k-clean.vocab")

turn google released albert format into BSON file. Set `raw` to `true` to remain the origin data format in bson.
"""
function tfckpt2bsonforalbert(path; raw=false, saveto="./", confname = "albert_config.json", ckptname = "model.ckpt-best", vocabname = "30k-clean.vocab")
  if iszip(path)
    data = ZipFile.Reader(path)
  else
    data = path
  end

  config, weights, vocab = readckptfolder(data; confname=confname, ckptname=ckptname, vocabname=vocabname)

  iszip(path) && close(data)

  if raw
    #saveto tfbson (raw julia data)
    bsonname = normpath(joinpath(saveto, config["filename"] * ".tfbson"))
    BSON.@save bsonname config weights vocab
  else
    #turn raw julia data to transformer model type
    albert_model = load_albert_from_tfbson(config, weights)
    wordpiece = WordPiece(vocab)
    tokenizer = albert_tokenizer(config["filename"])
    bsonname = normpath(joinpath(saveto, config["filename"] * ".bson"))
    BSON.@save bsonname albert_model wordpiece tokenizer
  end

  bsonname
end

"loading tensorflow checkpoint file into julia Dict"
readckpt(path) = error("readckpt require TensorFlow.jl installed. run `Pkg.add(\"TensorFlow\"); using TensorFlow`")

@init @require TensorFlow="1d978283-2c37-5f34-9a8e-e9c0ece82495" begin
  import .TensorFlow
  #should be changed to use c api once the patch is included
  function readckpt(path)
    weights = Dict{String, Array}()
    TensorFlow.init()
    ckpt = TensorFlow.pywrap_tensorflow.x.NewCheckpointReader(path)
    
     shapes = ckpt.get_variable_to_shape_map()

     #shapes = ckpt.get_variable_to_dtype_map()

     weights["bert/encoder/transformer/group_0/inner_group_0/ffn_1/intermediate/output/dense/bias"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/ffn_1/intermediate/output/dense/bias"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/ffn_1/intermediate/dense/bias"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/ffn_1/intermediate/dense/bias"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/LayerNorm_1/gamma"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/LayerNorm_1/gamma"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/LayerNorm_1/beta"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/LayerNorm_1/beta"))')
     weights["cls/predictions/transform/dense/kernel"]=collect((ckpt.get_tensor("cls/predictions/transform/dense/kernel"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/self/value/bias"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/attention_1/self/value/bias"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/self/key/kernel"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/attention_1/self/key/kernel"))')
     weights["bert/embeddings/word_embeddings"]=collect((ckpt.get_tensor("bert/embeddings/word_embeddings"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/self/key/bias"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/attention_1/self/key/bias"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/ffn_1/intermediate/dense/kernel"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/ffn_1/intermediate/dense/kernel"))')
     weights["bert/pooler/dense/kernel"]=collect((ckpt.get_tensor("bert/pooler/dense/kernel"))')
     weights["cls/predictions/output_bias"]=collect((ckpt.get_tensor("cls/predictions/output_bias"))')
     weights["cls/predictions/transform/LayerNorm/beta"]=collect((ckpt.get_tensor("cls/predictions/transform/LayerNorm/beta"))')
     weights["cls/seq_relationship/output_bias"]=collect((ckpt.get_tensor("cls/seq_relationship/output_bias"))')
     weights["bert/embeddings/LayerNorm/gamma"]=collect((ckpt.get_tensor("bert/embeddings/LayerNorm/gamma"))')
     weights["global_step"]=collect((ckpt.get_tensor("global_step"))')
     weights["bert/embeddings/LayerNorm/beta"]=collect((ckpt.get_tensor("bert/embeddings/LayerNorm/beta"))')
     weights["cls/predictions/transform/LayerNorm/gamma"]=collect((ckpt.get_tensor("cls/predictions/transform/LayerNorm/gamma"))')
     weights["bert/encoder/embedding_hidden_mapping_in/bias"]=collect((ckpt.get_tensor("bert/encoder/embedding_hidden_mapping_in/bias"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/ffn_1/intermediate/output/dense/kernel"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/ffn_1/intermediate/output/dense/kernel"))')
     weights["cls/seq_relationship/output_weights"]=collect((ckpt.get_tensor("cls/seq_relationship/output_weights"))')
     weights["cls/predictions/transform/dense/bias"]=collect((ckpt.get_tensor("cls/predictions/transform/dense/bias"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/self/query/bias"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/attention_1/self/query/bias"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/LayerNorm/beta"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/LayerNorm/beta"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/output/dense/kernel"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/attention_1/output/dense/kernel"))')
     weights["bert/encoder/embedding_hidden_mapping_in/kernel"]=collect((ckpt.get_tensor("bert/encoder/embedding_hidden_mapping_in/kernel"))')
     weights["bert/embeddings/token_type_embeddings"]=collect((ckpt.get_tensor("bert/embeddings/token_type_embeddings"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/LayerNorm/gamma"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/LayerNorm/gamma"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/self/query/kernel"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/attention_1/self/query/kernel"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/self/value/kernel"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/attention_1/self/value/kernel"))')
     weights["bert/embeddings/position_embeddings"]=collect((ckpt.get_tensor("bert/embeddings/position_embeddings"))')
     weights["bert/pooler/dense/bias"]=collect((ckpt.get_tensor("bert/pooler/dense/bias"))')
     weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/output/dense/bias"]=collect((ckpt.get_tensor("bert/encoder/transformer/group_0/inner_group_0/attention_1/output/dense/bias"))')

return(weights)
#print((weights["bert/encoder/transformer/group_0/inner_group_0/attention_1/output/dense/bias"]))
  end
end
function readckptfolder(z::ZipFile.Reader; confname = "albert_config.json", ckptname = "model.ckpt-best", vocabname = "30k-clean.vocab")
  (confile = findfile(z, confname)) === nothing && error("config file $confname not found")
  findfile(z, ckptname*".meta") === nothing && error("ckpt file $ckptname not found")
  (vocabfile = findfile(z, vocabname)) === nothing && error("vocab file $vocabname not found")

  dir = zipname(z)
  filename = basename(isdirpath(dir) ? dir[1:end-1] : dir)

  config = JSON.parse(confile)
  config["filename"] = filename
  vocab = readlines(vocabfile)

  weights = mktempdir(
    dir -> begin
      #dump ckpt to tmp
      for fidx ∈ findall(zf->startswith(zf.name, joinpath(zipname(z), ckptname)), z.files)
        zf = z.files[fidx]
        zfn = basename(zf.name)
        f = open(joinpath(dir, zfn), "w+")
        buffer = Vector{UInt8}(undef, zf.uncompressedsize)
        write(f, read!(zf, buffer))
        close(f)
      end

      readckpt(joinpath(dir, ckptname))
    end
  )


  config, weights, vocab
end

function readckptfolder(dir; confname = "albert_config.json", ckptname = "model.ckpt-best", vocabname = "30k-clean.vocab")
  files = readdir(dir)

  confname ∉ files && error("config file $confname not found")
  ckptname*".meta" ∉ files && error("ckpt file $ckptname not found")
  vocabname ∉ files && error("vocab file $vocabname not found")
  filename = basename(isdirpath(dir) ? dir[1:end-1] : dir)

  config = JSON.parsefile(joinpath(dir, confname))
  config["filename"] = filename
  vocab = readlines(open(joinpath(dir, vocabname)))
  weights = readckpt(joinpath(dir, ckptname))
  config, weights, vocab
end

function get_activation(act_string)
    if act_string == "gelu"
        gelu
    elseif act_string == "relu"
        relu
    elseif act_string == "tanh"
        tanh
    elseif act_string == "linear"
        identity
    else
        throw(DomainError(act_string, "activation support: linear, gelu, relu, tanh"))
    end
end

_create_classifier(;args...) = args.data

load_albert_from_tfbson(path::AbstractString) = (@assert istfbson(path); load_bert_from_tfbson(BSON.load(path)))
load_albert_from_tfbson(bson) = load_bert_from_tfbson(bson[:config], bson[:weights])
function load_bert_from_tfbson(config, weights)
    #init albert model possible component
    albert = albert(
        config["hidden_size"],
        config["num_attention_heads"],
        config["intermediate_size"],
        config["num_hidden_layers"];
        act = get_activation(config["hidden_act"]),
        embedding =config["embeddings"],
        pdrop = config["hidden_dropout_prob"],
        attn_pdrop = config["attention_probs_dropout_prob"]
    )

    embedding = Dict{Symbol, Any}()

    tok_emb = Embed(
    config["embedding_size"],
    config["vocab_size"]
  )

    seg_emb = Embed(
        config["embedding_size"],
        config["type_vocab_size"]
    )

    posi_emb = PositionEmbedding(
        config["embedding_size"],
        config["max_position_embeddings"];
        trainable = true
    )

    emb_post = Positionwise(
        LayerNorm(
             config["embedding_size"]
        ),
        Dropout(
            config["hidden_dropout_prob"]
        )
    )

    classifier = Dict{Symbol, Any}()

    pooler = Dense(
        config["hidden_size"],
        config["hidden_size"],
        tanh
    )

    masklm = (
        transform = Chain(
            Dense(
                config["embedding_size"],
                config["hidden_size"],
                get_activation(config["hidden_act"])
            ),
            LayerNorm(
                config["embedding_size"]
            )
        ),
        output_bias = randn(
            Float32,
            config["vocab_size"]
        )
    )

    nextsentence = Chain(
        Dense(
            config["hidden_size"],
            2
        ),
        logsoftmax
    )

    #tf namespace handling
    vnames = keys(weights)
    albert_weights = filter(name->occursin("layer", name), vnames)
    embeddings_weights = filter(name->occursin("embeddings", name), vnames)
    pooler_weights = filter(name->occursin("pooler", name), vnames)
    masklm_weights = filter(name->occursin("cls/predictions", name), vnames)
    nextsent_weights = filter(name->occursin("cls/seq_relationship", name), vnames)

    for i = 1:config["num_hidden_layers"]
        li_weights = filter(name->occursin("layer_$(i-1)/", name), albert_weights)
       #for loading weights in albert Transformer
       #Transformer is under development
    end

    for k ∈ embeddings_weights
        if occursin("LayerNorm/gamma", k)
            loadparams!(emb_post[1].diag.α, [weights[k]])
            embedding[:postprocessor] = emb_post
        elseif occursin("LayerNorm/beta", k)
            loadparams!(emb_post[1].diag.β, [weights[k]])
        elseif occursin("word_embeddings", k)
            loadparams!(tok_emb.embedding, [weights[k]])
            embedding[:tok] = tok_emb1
        elseif occursin("position_embeddings", k)
            loadparams!(posi_emb.embedding, [weights[k]])
            embedding[:pe] = posi_emb
        elseif occursin("token_type_embeddings", k)
            loadparams!(seg_emb.embedding, [weights[k]])
            embedding[:segment] = seg_emb
        else
            @warn "unknown variable: $k"
        end
    end

    for k ∈ pooler_weights
        if occursin("dense/kernel", k)
            loadparams!(pooler.W, [weights[k]])
        elseif occursin("dense/bias", k)
            loadparams!(pooler.b, [weights[k]])
        else
            @warn "unknown variable: $k"
        end
    end

    if !isempty(pooler_weights)
        classifier[:pooler] = pooler
    end


    for k ∈ masklm_weights
        #for loading masklm weights
    end

    if !isempty(masklm_weights)
        classifier[:masklm] = masklm
    end

    for k ∈ nextsent_weights
        if occursin("seq_relationship/output_weights", k)
            loadparams!(nextsentence[1].W, [weights[k]])
        elseif occursin("seq_relationship/output_bias", k)
            loadparams!(nextsentence[1].b, [weights[k]])
        else
            @warn "unknown variable: $k"
        end
    end

    if !isempty(nextsent_weights)
        classifier[:nextsentence] = nextsentence
    end

    if Set(vnames) != union(albert_weights, embeddings_weights, pooler_weights, masklm_weights, nextsent_weights)
        @warn "some unkown variable not load"
    end

    embed = CompositeEmbedding(;embedding...)
    cls = _create_classifier(; classifier...)

    TransformerModel(embed, albert, cls)
end

