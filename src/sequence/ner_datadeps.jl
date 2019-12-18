function ner_datadep_register()
    register(DataDep("NER Model Weights",
        """
        The weights for NER Sequence Labelling Model.
        """,
        "https://github.com/JuliaText/TextAnalysis.jl/releases/download/v0.6.0/ner_weights.tar.xz",
        "6290353b66c9bdbb794ddcb6063ab52c30145d3918f2f115f19e21fa994282e6",
        post_fetch_method = function(fn)
            unpack(fn)
            dir = "weights"
            innerfiles = readdir(dir)
            mv.(joinpath.(dir, innerfiles), innerfiles)
            rm(dir)
        end
    ))

    register(DataDep("NER Model Dicts",
        """
        The character and words dict for NER Sequence Labelling Model.
        """,
        "https://github.com/JuliaText/TextAnalysis.jl/releases/download/v0.6.0/ner_dicts.tar.xz",
        "40cfa37da216b990eb9c257aa7994e34d7a7a59d69b2506c6f39120f2688dc11",
        post_fetch_method = function(fn)
            unpack(fn)
            dir = "model_dicts"
            innerfiles = readdir(dir)
            mv.(joinpath.(dir, innerfiles), innerfiles)
            rm(dir)
        end
    ))
end
