using Documenter, TextAnalysis

load_dir(x) = map(file -> joinpath("lib", x, file), readdir(joinpath(Base.source_dir(), "src", "lib", x)))

makedocs(
   modules = [TextAnalysis],
   clean = false,
   format = [:html],#, :latex],
   sitename = "TextAnalysis",
   pages = Any[
       "Home" => "index.md",
       "Documents" => "documents.md",
       "Corpus" => "corpus.md",
       "Features" => "features.md",
       "Semantic Analysis" => "semantic.md",
       "Extended Example" => "example.md"
   ],
   assets = ["assets/custom.css", "assets/custom.js"]
)

deploydocs(
    repo = "github.com/JuliaText/TextAnalysis.jl.git",
    target = "build",
    julia = "0.6",
    osname = "linux",
    deps = nothing,
    make = nothing,
)
