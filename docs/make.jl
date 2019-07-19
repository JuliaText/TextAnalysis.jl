using Documenter, TextAnalysis

makedocs(
    modules = [TextAnalysis],
    sitename = "TextAnalysis",
    format = Documenter.HTML(
        canonical = "https://juliatext.github.io/TextAnalysis.jl/stable/",
        #prettyurls = false,
    ),
    assets = ["assets/custom.css", "assets/custom.js"],
    pages = [
        "Home" => "index.md",
        "Documents" => "documents.md",
        "Corpus" => "corpus.md",
        "Features" => "features.md",
        "Semantic Analysis" => "semantic.md",
        "Classifier" => "classify.md",
        "Extended Example" => "example.md"
        "Conditional Random Fields" => "crf.md"
    ],
)

deploydocs(repo = "github.com/JuliaText/TextAnalysis.jl.git")
