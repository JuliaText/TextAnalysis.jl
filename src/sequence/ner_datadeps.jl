function ner_datadep_register()
    register(DataDep("NER Model Weights",
        """
        The weights for NER Sequence Labelling Model.
        """,
        "https://github.com/Ayushk4/NER.jl/releases/download/0.0.0.1/ner_weights.tar.xz",
        "6eda5cd778af99f57a0a0b7eb4d5bc46a5a61c214e3e515e620b7db6b76ce3aa",
        post_fetch_method = function(fn)
            unpack(fn)
            dir = "ner_weights"
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
