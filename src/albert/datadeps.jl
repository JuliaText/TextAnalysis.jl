using GoogleDrive
abstract type ALBERT_V1 <: PretrainedTransformer end
abstract type ALBERT_V2 <: PretrainedTransformer end

vectors_albertversion1 = [
    ("albert_base_v1",
    "albert base version1 of size ~500mb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz"),
    ("albert_large_v1",
    " albert large version1 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz"),
    ("albert_xlarge_v1",
    "albert xlarge version1 of size ~800kb download",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz"),
    ("albert_xxlarge_v1",
    "albert xxlarge version1 of size ~800kb download",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://drive.google.com/drive/u/1/folders/1HHTlS_jBYRE4cG0elITEH7fAkiNmrEgz")
]

for (depname, description, sha, link) in vectors_albertversion1
    register(DataDep(depname,
        """
        sentencepiece albert vocabulary file by google research .
        Website: https://github.com/google-research/albert
        Author: Google Research
        Licence: Apache License 2.0
        $description
        """,
        link,
        sha,
        fetch_method = google_download,
	post_fetch_method = unpack
            ))
       
    append!(model_version(ALBERT_V1), ["$depname"])                    
end

vectors_albertversion2 = [
    ("albert_base_v2",
    "albert base version2 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://drive.google.com/drive/u/1/folders/1DlX_WZacsjt6O8EDaawKJ-x4RWP46Xj-"),
    ("albert_large_v2",
    " albert large version2 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_large_v2_30k-clean.vocab"),
    ("albert_xlarge_v2",
    "albert xlarge version2 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xlarge_v2_30k-clean.vocab"),
    ("albert_xxlarge_v2",
    "albert xxlarge version2 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xxlarge_v2_30k-clean.vocab")
]

for (depname, description, sha, link) in vectors_albertversion2
    register(DataDep(depname,
        """
        sentencepiece albert vocabulary file by google research .
        Website: https://github.com/google-research/albert
        Author: Google Research
        Licence: Apache License 2.0
        $description
        """,
        link,
        sha,
        fetch_method = google_download,
	post_fetch_method = unpack
             ))
       
    append!(model_version(ALBERT_V2), ["$depname"])                    
end
