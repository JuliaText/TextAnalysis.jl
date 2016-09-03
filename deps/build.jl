using BinDeps
using Compat

@BinDeps.setup

libstemmer = library_dependency("libstemmer", aliases=["libstemmer.so", "libstemmer.dll"])

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

if !isfile(binpath)
    if is_unix()
        run(download_cmd("http://snowball.tartarus.org/dist/snowball_code.tgz",dnldfile))
        cd(srchome)
        run(`tar xvzf $dnldfile`)
        cd(srcdir)
        run(pipeline(`cat $patchpath`, `patch`))
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

    if is_windows()
        Base.warn("No integrated stemmer available on Windows yet.\n" *
                  "Place a compiled Snowball stemmer dll at $binpath for stemming to work.")
    end
end

provides(Binaries, bindir, libstemmer)
