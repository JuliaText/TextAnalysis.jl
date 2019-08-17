using DataDeps

register(DataDep(
    "WikiText-103",
    """
    WikiText Long Term Dependency Language Modeling Dataset
    This is a language modelling dataset under Creative Commons Attribution-ShareAlike License. I contains over 100
    million tokens.
    """,
    "https://s3.amazonaws.com/research.metamind.io/wikitext/wikitext-103-v1.zip",
    post_fetch_method = function (file)
        unpack(file)
        dir = "wikitext-103"
        files = readdir(dir)
        mv.(joinpath.(dir, files), files)
        rm(dir)

        corpus = read(open("wiki.train.tokens", "r"), String)
        corpus = split(lowercase(corpus), '\n')
        deleteat!(corpus, findall(x -> isequal(x, "")||isequal(x, " ")||(isequal(x[1:2], " =")&&isequal(x[prevind(x, lastindex(x), 1):end], "= ")), corpus))
        corpus = strip.(corpus)
        corpus .*= " <eos>"
        corpus = join(corpus, ' ')
        ftrain = open("wiki.train.tokens", "w")
        write(ftrain, corpus)
        close(ftrain)
    end
))
