using Documenter, TextAnalysis

makedocs(
    modules = [TextAnalysis],
    sitename = "TextAnalysis",
    format = Documenter.HTML(
    ),
    pages = [
        "Home" => "index.md",
        "Documents" => "documents.md",
        "Corpus" => "corpus.md",
        "Features" => "features.md",
        "Semantic Analysis" => "semantic.md",
        "Classifier" => "classify.md",
        "Extended Example" => "example.md",
        "Evaluation Metrics" => "evaluation_metrics.md",
        "Statistical Language Model" => "LM.md",
        "API References" => "APIReference.md"
    ],
)

