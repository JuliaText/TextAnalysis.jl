using GoogleDrive
using DataDeps

#BSON files is kept in googledrive 
vectors_albertversion1 = [
    ("albert_base_v1",
    "albert base version1 of size ~46 MB download.",
    "786b61a6c1597cf67e43a732cd9edb7e9075e81b5dbb73159acc75238ebc2ea7",
    "https://drive.google.com/uc?export=download&id=1RKggDgmlJrSRsx7Ro2eR2hTNuMmzyUJ7"),
    ("albert_large_v1",
    " albert large version1 of size ~69 MB download.",
    "9dac07e26bc6035974afecc89ff18df51ac6d552714799d4d4d4b083342eb2c9",
    "https://drive.google.com/uc?export=download&id=1rpfjhpNL0luadP2b2wuuNkU4dNrEcGU0"),
    ("albert_xlarge_v1",
    "albert xlarge version1 of size ~226 MB download",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://docs.google.com/uc?export=download&id=1fkYq49OvAHW_BsApTO-mXEWf2Hg8D8Xw"),
    ("albert_xxlarge_v1",
    "albert xxlarge version1 of size ~825 MB download",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://docs.google.com/uc?export=download&id=1WBbW57UwBU0zZHnIO_pkrbtpmX85ydDD")
]

for (depname, description, sha, link) in vectors_albertversion1
    register(DataDep(depname,
        """
        albert-weights BSON file converted from official Pretrained weigths by google research .
        Website: https://github.com/google-research/albert
        Author: Google Research
        Licence: Apache License 2.0
        $description
        """,
        link,
        sha,
        fetch_method = google_download
            ))
       
    append!(model_version(ALBERT_V1), ["$depname"])                    
end

vectors_albertversion2 = [
    ("albert_base_v2",
    "albert base version2 of size ~46 MB download.",
    "6590ed0aa133b05126c55a5b27362a41baba778f27fff2520df320f3965dd795",
    "https://drive.google.com/uc?export=download&id=19llahJFvgjQNQ9pzES2XF0R9JdYwuuTk"),
    ("albert_large_v2",
    " albert large version2 of size ~69 MB download.",
    "18928434ba1c7b9dfc6876b413aa94f0f23bbb79aabb765d0d439a2961238473",
    "https://drive.google.com/uc?export=download&id=1bLiJVnJd-V_S51bLsmXx6COYsMJXcusn"),
    ("albert_xlarge_v2",
    "albert xlarge version2 of size ~226 MB download.",
    "0c41c706549fb2f8d8b75372cc0f5aafb055cfa626392432355e20e55d40a71b",
    "https://docs.google.com/uc?export=download&id=1Akmp2LdjFUvsZYaBdrAa2PTAK35pzoSm"),
    ("albert_xxlarge_v2",
    "albert xxlarge version2 of size ~825 MB download.",
    "3d7d22cd929b675a26c49342ed77962b54dd55bcfb94c2fef6501cacf9f383d3",
    "https://docs.google.com/uc?export=download&id=1f_RjeyvqBJzfurcgZ7i_ItFjWK4eRJLr")
]

for (depname, description, sha, link) in vectors_albertversion2
    register(DataDep(depname,
        """
        albert-weights BSON file converted from official weigths-file by google research .
        Website: https://github.com/google-research/albert
        Author: Google Research
        Licence: Apache License 2.0
        $description
        """,
        link,
        sha,
        fetch_method = google_download
             ))
       
    append!(model_version(ALBERT_V2), ["$depname"])                    
end
