using Transformers.Basic
using Flux
using Flux: loadparams!
using DataDeps
using TextAnalysis.ALBERT
using BSON: @save, @load

function from_pretrained(ty::Type{T}, filenum::Int=1) where T<:PretrainedTransformer
    filepath = @datadep_str model_version(ty)[filenum]
    print(filepath)
    name = model_version(ty)[filenum]
    filepath = "$filepath/$name"*".bson"
    @load filepath config weights vocab
    transformer = load_pretrainedalbert(config, weights)
    return transformer
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

embedding = Dict{Symbol, Any}()
classifier = Dict{Symbol, Any}()

    pooler = Dense(
        config["hidden_size"],
        config["hidden_size"],
        tanh
    )

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

    nextsentence = Chain(
        Dense(
            config["hidden_size"],
            2
        ),
        logsoftmax
    )

vnames = keys(weights)
embeddings_weights = filter(name->occursin("embeddings", name), vnames)
for k ∈ embeddings_weights
    if occursin("LayerNorm/gamma", k)
        loadparams!(emb_post[1].diag.α', [weights[k]]) #there is some problem with loading
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

albert_weights = filter(name->occursin("transformer", name), vnames)


for j = 1:config["num_hidden_groups"] 
    group_weights = filter(name->occursin("group_$(j-1)/", name), albert_weights)
    for i = 1:config["inner_group_num"]
        inner_weigths = filter(name->occursin("inner_group_$(i-1)/", name), group_weights)
        for k ∈ inner_weigths
            if occursin("inner_group_$(i-1)/attention_1", k)
                if occursin("self/key/kernel", k)
                    loadparams!(albert.al[i].mh.ikproj.W, [weights[k]])
                elseif occursin("self/key/bias", k)
                    loadparams!(albert.al[i].mh.ikproj.b', [weights[k]])
                elseif occursin("self/query/kernel", k)
                    loadparams!(albert.al[i].mh.iqproj.W, [weights[k]])
                elseif occursin("self/query/bias", k)
                    loadparams!(albert.al[i].mh.iqproj.b', [weights[k]])
                elseif occursin("self/value/kernel", k)
                    loadparams!(albert.al[i].mh.ivproj.W, [weights[k]])
                elseif occursin("self/value/bias", k)
                   loadparams!(albert.al[i].mh.ivproj.b', [weights[k]])
                elseif occursin("output/LayerNorm/gamma", k)
                    loadparams!(bert[i].mhn.diag.α', [weights[k]])
                elseif occursin("output/LayerNorm/beta", k)
                    loadparams!(bert[i].mhn.diag.β', [weights[k]])
                elseif occursin("output/dense/kernel", k)
                    loadparams!(albert.al[i].mh.oproj.W, [weights[k]])
                elseif occursin("output/dense/bias", k)
                    loadparams!(albert.al[i].mh.oproj.b', [weights[k]])
                else
                   # @warn "unknown variable: $k"
                end
            elseif occursin("inner_group_$(1-1)/ffn_1/intermediate/dense", k)
                if occursin("kernel", k)
                    loadparams!(albert.al[i].pw.din.W, [weights[k]])
                elseif occursin("bias", k)
                    loadparams!(albert.al[i].pw.din.b', [weights[k]])
                else
                  #  @warn "unknown variable: $k"
                end
            elseif occursin("inner_group_$(1-1)/ffn_1/intermediate/output", k)
                if occursin("output/dense/kernel", k)
                    loadparams!(albert.al[i].pw.dout.W, [weights[k]])
                elseif occursin("output/dense/bias", k)
                    loadparams!(albert.al[i].pw.dout.b', [weights[k]])
                else
                 #   @warn "unknown variable: $k"
                end
            else
                #@warn "unknown variable: $k"
            end
        end
       end
        layer_weigths = filter(name->occursin("group_$(j-1)/LayerNorm", name), albert_weights)

    for t ∈ layer_weigths
        if occursin("group_$(j-1)/inner_group_0/LayerNorm_1",t)
            if occursin("LayerNorm_1/gamma", t)
                    loadparams!(albert.al[j].pwn.diag.α', [weights[t]])
            else occursin("LayerNorm_1/beta", t)
                    loadparams!(albert.al[j].pwn.diag.β', [weights[t]])
            end
        elseif occursin("group_$(j-1)/inner_group_0/LayerNorm",t)
            if occursin("LayerNorm/gamma", t)
                    loadparams!(albert.al[j].mhn.diag.α', [weights[t]])
            else occursin("LayerNorm/beta",t)
                    loadparams!(albert.al[j].mhn.diag.β', [weights[t]])
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
    embed = CompositeEmbedding(;embedding...)
    cls = _create_classifier(; classifier...)
    #TODO
    ## update to new transformer structure
    return TransformerModel(embed, albert, cls)

end
