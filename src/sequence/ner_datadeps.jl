function ner_datadep_register()
    register(DataDep("NER Model Weights",
        """
        The weights for NER Sequence Labelling Model.
        """,
        "https://raw.githubusercontent.com/Ayushk4/Random_set_of_codes/weights/weights.tar.xz",
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
        "https://raw.githubusercontent.com/Ayushk4/Random_set_of_codes/weights/model_dicts.tar.xz",
        post_fetch_method = function(fn)
            unpack(fn)
            dir = "model_dicts"
            innerfiles = readdir(dir)
            mv.(joinpath.(dir, innerfiles), innerfiles)
            rm(dir)
        end
    ))
end
