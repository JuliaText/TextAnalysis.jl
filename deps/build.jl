using BinDeps

@BinDeps.setup

libstemmer = library_dependency("libstemmer", aliases=["libstemmer"])

prefix=joinpath(BinDeps.depsdir(libstemmer),"usr")
dnlddir = joinpath(BinDeps.depsdir(libstemmer), "downloads")
srchome = joinpath(BinDeps.depsdir(libstemmer),"src")
srcdir = joinpath(srchome,"snowball_code")
bindir = joinpath(prefix,"lib")

dnldfile = joinpath(dnlddir, "snowball_code.tgz")
patchpath = joinpath(BinDeps.depsdir(libstemmer),"patches","libstemmer-so.patch")
binpath = joinpath(bindir, "libstemmer."*BinDeps.shlib_ext)

for path in [prefix, dnlddir, srchome, bindir]
    #println("making path $path")
    !isdir(path) && mkdir(path)
end

@unix_only begin
    run(download_cmd("http://snowball.tartarus.org/dist/snowball_code.tgz",dnldfile))
    cd(srchome)
    run(`tar xvzf $dnldfile`)
    cd(srcdir)
    run(`cat $patchpath` |> `patch`)
    for mkcmd in (:gnumake, :gmake, :make)
        try
            if success(`$mkcmd`)
                cp(joinpath(srcdir, "libstemmer.so.0d.0.0"), binpath)
                break
            end
        catch
            continue
        end
    end
end

@windows_only begin
    Base.warn("No integrated stemmer available on Windows yet. Place a compiled Snowball stemmer dll at $binpath for stemming to work.")
end
