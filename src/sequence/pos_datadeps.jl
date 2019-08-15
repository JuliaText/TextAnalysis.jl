function pos_datadep_register()
    register(DataDep("POS Model Weights",
        """
        The weights for POS Sequence Labelling Model.
        """,
        "https://github.com/Ayushk4/POS.jl/releases/download/v0.0/weights.tar.xz",
        "b02e891ea913be6834ff67d6ecf2ddae6754d55509bb3d9c078dbfc7eed27988";
        post_fetch_method = function(fn)
            unpack(fn)
            dir = "weights"
            innerfiles = readdir(dir)
            mv.(joinpath.(dir, innerfiles), innerfiles)
            rm(dir)
        end
    ))

    register(DataDep("POS Model Dicts",
        """
        The character and words dict for POS Sequence Labelling Model.
        """,
        "https://github.com/Ayushk4/POS.jl/releases/download/v0.0/model_dicts.tar.xz",
        "4d7fe8238ff0cfb92d195dfa745b4ed08f916d4707e3dbe27a1b3144c9282f41";
        post_fetch_method = function(fn)
            unpack(fn)
            dir = "model_dicts"
            innerfiles = readdir(dir)
            mv.(joinpath.(dir, innerfiles), innerfiles)
            rm(dir)
        end
    ))
end
