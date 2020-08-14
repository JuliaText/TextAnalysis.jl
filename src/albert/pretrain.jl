# loading pretraining weigths from bson file
using Transformers.Basic
using Flux
using Flux: loadparams!
using DataDeps
using TextAnalysis.ALBERT
using BSON: @save, @load

"""
    from_pretrained(model::AbstractString = albert_base_v1) where T<:PretrainedTransformer
Intialised and load pretrained weights on top of deps from all the avaliable model in ALBERT

Example:
julia> transformer = from_pretrained(albert_base_v1)
  
TransformerModel{TextAnalysis.ALBERT.albert_transformer}(
  embed = CompositeEmbedding(tok = Embed(128), segment = Embed(128), pe = PositionEmbedding(128, max_len=512), postprocessor = Positionwise(LayerNorm(128), Dropout(0.1))),
  transformers = albert(layers=12, head=12, head_size=64, pwffn_size=3072, size=768),
  classifier = 
      (
       pooler => Dense(768, 768, tanh)
       masklm => (
           transform => Chain(Dense(768, 128, gelu), LayerNorm(128))
           output_bias => Array{Float32,1}
      )
       nextsentence => Chain(Dense(768, 2), logsoftmax)
  )
)
"""
function from_pretrained(model::AbstractString = albert_base_v1) where T<:PretrainedTransformer
    if model == "albert_base_v1"
        filepath = @datadep_str model_version(ALBERT_V1)[1]
        name = model_version(ALBERT_V1)[1]
    elseif model == "albert_large_v1"
        filepath = @datadep_str model_version(ALBERT_V1)[2]
        name = model_version(ALBERT_V1)[2]
    elseif model == "albert_xlarge_v1"
        filepath = @datadep_str model_version(ALBERT_V1)[3]
        name = model_version(ALBERT_V1)[3]
    elseif model == "albert_xxlarge_v1"
        filepath = @datadep_str model_version(ALBERT_V1)[4]
        name = model_version(ALBERT_V1)[4]
    elseif model == "albert_base_v2"
        filepath = @datadep_str model_version(ALBERT_V2)[1]
        name = model_version(ALBERT_V2)[1]
    elseif model == "albert_large_v2"
        filepath = @datadep_str model_version(ALBERT_V2)[2]
        name = model_version(ALBERT_V2)[2]
    elseif model == "albert_xlarge_v2"
        filepath = @datadep_str model_version(ALBERT_V2)[3]
        name = model_version(ALBERT_V2)[3]
    elseif model == "albert_xxlarge_v2"
        filepath = @datadep_str model_version(ALBERT_V2)[4]
        name = model_version(ALBERT_V2)[4]
    end
    filepath = "$filepath/$name"*".bson"
    @load filepath config weights vocab
    transformer = load_pretrainedalbert(config, weights)
    return transformer
end

#To load activation function from Flux
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

function load_pretrainedalbert(config, weights)
    albert = albert_transformer(
        config["embedding_size"],
        config["hidden_size"],
        config["num_attention_heads"],
        config["intermediate_size"],
        config["num_hidden_layers"],
        config["inner_group_num"],
        config["num_hidden_groups"];
        act = get_activation(config["hidden_act"]),
        pdrop = config["hidden_dropout_prob"],
        attn_pdrop = config["attention_probs_dropout_prob"]
    )
    # Structure to hold embedding in ALBERT
    # tok_embed is used to hold token type embedding
    tok_emb = Embed(
        config["embedding_size"],
        config["vocab_size"]
    )

    # segment is used to hold sentence-segment type embedding
    seg_emb = Embed(
        config["embedding_size"],
        config["type_vocab_size"]
    )

    # Posi_emb is used to hold position embedding
    posi_emb = PositionEmbedding(
        config["embedding_size"],
        config["max_position_embeddings"];
        trainable = true
    )
    # post embedding operations
    # layerNormalization and Dropout
    emb_post = Positionwise(
        LayerNorm(
        config["embedding_size"]
        ),
        Dropout(
            config["hidden_dropout_prob"]
        ) 
    )
    
    #Dict to hold embedding operations and classifiers
    embedding = Dict{Symbol, Any}()
    classifier = Dict{Symbol, Any}()
    
    #pooler layer for classification in pretraining
    pooler = Dense(
        config["hidden_size"],
        config["hidden_size"],
        tanh
    )
 
    #masklm or masked language model t
    masklm = (
        transform = Chain(
            Dense(
                config["hidden_size"],
                config["embedding_size"],
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

    #nextsentecne or Sentence order prediciton layer
    nextsentence = Chain(
        Dense(
            config["hidden_size"],
            2
        ),
        logsoftmax
    )

    vnames = keys(weights)

    embeddings_weights = filter(name->occursin("embeddings", name), vnames) 

# loading embedding weights
    for k ∈ embeddings_weights
        if occursin("LayerNorm/gamma", k)
            loadparams!(emb_post[1].diag.α', [weights[k]]) 
            embedding[:postprocessor] = emb_post
        elseif occursin("LayerNorm/beta", k)
            loadparams!(emb_post[1].diag.β', [weights[k]])
        elseif occursin("word_embeddings", k)
            loadparams!(tok_emb.embedding, [weights[k]])
            embedding[:tok] = tok_emb
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

    #albert transformer weights
    albert_weights = filter(name->occursin("transformer", name), vnames)

    #loading transformer weights
    for j = 1:config["num_hidden_groups"] 
        group_weights = filter(name->occursin("group_$(j-1)/", name), albert_weights)
        for i = 1:config["inner_group_num"]
            inner_weigths = filter(name->occursin("inner_group_$(i-1)/", name), group_weights)
            for k ∈ inner_weigths
                if occursin("inner_group_$(i-1)/attention_1", k)
                    if occursin("self/key/kernel", k)
                        loadparams!(albert.al[j][i].mh.ikproj.W, [weights[k]])
                    elseif occursin("self/key/bias", k)
                        loadparams!(albert.al[j][i].mh.ikproj.b', [weights[k]])
                    elseif occursin("self/query/kernel", k)
                        loadparams!(albert.al[j][i].mh.iqproj.W, [weights[k]])
                    elseif occursin("self/query/bias", k)
                        loadparams!(albert.al[j][i].mh.iqproj.b', [weights[k]])
                    elseif occursin("self/value/kernel", k)
                        loadparams!(albert.al[j][i].mh.ivproj.W, [weights[k]])
                    elseif occursin("self/value/bias", k)
                        loadparams!(albert.al[j][i].mh.ivproj.b', [weights[k]])
                    elseif occursin("output/dense/kernel", k)
                        loadparams!(albert.al[j][i].mh.oproj.W, [weights[k]])
                    elseif occursin("output/dense/bias", k)
                        loadparams!(albert.al[j][i].mh.oproj.b', [weights[k]])
                    else
                       # @warn "unknown variable: $k"
                    end
                elseif occursin("inner_group_$(1-1)/ffn_1/intermediate/dense", k)
                    if occursin("kernel", k)
                        loadparams!(albert.al[j][i].pw.din.W, [weights[k]])
                    elseif occursin("bias", k)
                        loadparams!(albert.al[j][i].pw.din.b', [weights[k]])
                    else
                     #  @warn "unknown variable: $k"
                    end
                elseif occursin("inner_group_$(1-1)/ffn_1/intermediate/output", k)
                    if occursin("output/dense/kernel", k)
                        loadparams!(albert.al[j][i].pw.dout.W, [weights[k]])
                    elseif occursin("output/dense/bias", k)
                        loadparams!(albert.al[j][i].pw.dout.b', [weights[k]])
                    else
                 #   @warn "unknown variable: $k"
                    end
                else
                #@warn "unknown variable: $k"
                end
            end
        
            layer_weigths = filter(name->occursin("group_$(j-1)/LayerNorm", name), albert_weights)

            for t ∈ layer_weigths
                if occursin("group_$(j-1)/inner_group_0/LayerNorm_1",t)
                    if occursin("LayerNorm_1/gamma", t)
                        loadparams!(albert.al[j][i].pwn.diag.α', [weights[t]])
                    else occursin("LayerNorm_1/beta", t)
                        loadparams!(albert.al[j][i].pwn.diag.β', [weights[t]])
                    end
                elseif occursin("group_$(j-1)/inner_group_0/LayerNorm",t)
                    if occursin("LayerNorm/gamma", t)
                        loadparams!(albert.al[j][i].mhn.diag.α', [weights[t]])
                    else occursin("LayerNorm/beta",t)
                        loadparams!(albert.al[j][i].mhn.diag.β', [weights[t]])
                    end
                end    
            end
        end
    end
    mapping_weight = filter(name->occursin("embedding_hidden_mapping_in",name),vnames)

    for mw ∈ mapping_weight
        if occursin("embedding_hidden_mapping_in/kernel", mw)
            loadparams!(albert.linear.W, [weights[mw]])
        else occursin("embedding_hidden_mapping_in/bias", mw)
            loadparams!(albert.linear.b', [weights[mw]])
        end
    end
    pooler_weights = filter(name->occursin("pooler", name), vnames)
    masklm_weights = filter(name->occursin("cls/predictions", name), vnames)
    nextsent_weights = filter(name->occursin("cls/seq_relationship", name), vnames)

    for k ∈ nextsent_weights
        if occursin("seq_relationship/output_weights", k)
            loadparams!(nextsentence[1].W', [weights[k]])
        elseif occursin("seq_relationship/output_bias", k)
            loadparams!(nextsentence[1].b', [weights[k]])
        else
            @warn "unknown variable: $k"
        end
    end

    if !isempty(nextsent_weights)
        classifier[:nextsentence] = nextsentence
    end
    for k ∈ pooler_weights
        if occursin("dense/kernel", k)
            loadparams!(pooler.W, [weights[k]])
        elseif occursin("dense/bias", k)
            loadparams!(pooler.b', [weights[k]])
        else
            @warn "unknown variable: $k"
        end
    end

    if !isempty(pooler_weights)
        classifier[:pooler] = pooler
    end


    for k ∈ masklm_weights
        if occursin("predictions/output_bias", k)
            loadparams!(masklm.output_bias', [weights[k]])
        elseif occursin("predictions/transform/dense/kernel", k)
            loadparams!(masklm.transform[1].W, [weights[k]])
        elseif occursin("predictions/transform/dense/bias", k)
            loadparams!(masklm.transform[1].b', [weights[k]])
        elseif occursin("predictions/transform/LayerNorm/gamma", k)
            loadparams!(masklm.transform[2].diag.α', [weights[k]])
        elseif occursin("predictions/transform/LayerNorm/beta", k)
            loadparams!(masklm.transform[2].diag.β', [weights[k]])
        else
            @warn "unknown variable: $k"
        end
    end

    if !isempty(masklm_weights)
        classifier[:masklm] = masklm
    end
    embed = CompositeEmbedding(;embedding...) #implemented in Transformer.jl
    cls = _create_classifier(; classifier...) #implemented in Transformer.jl
    TransformerModel(embed, albert, cls) #structure to hold transformer model already implemented in Transformers.jl

end
