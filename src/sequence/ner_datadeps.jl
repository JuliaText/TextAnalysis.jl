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
        "https://github.com/Ayushk4/NER.jl/releases/download/0.0.0.1/ner_dicts.tar.xz",
        "190d8ed245f2e233d97c23c015ae1b3c11878974188d30c2fabceb281b7cbbda",
        post_fetch_method = function(fn)
            unpack(fn)
            dir = "model_dicts"
            innerfiles = readdir(dir)
            mv.(joinpath.(dir, innerfiles), innerfiles)
            rm(dir)
        end
    ))
end
