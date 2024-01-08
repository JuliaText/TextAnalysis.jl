# Extended Usage Example

To show you how text analysis might work in practice, we're going to work with
a text corpus composed of political speeches from American presidents given
as part of the State of the Union Address tradition.

```julia
    using TextAnalysis, MultivariateStats, Clustering

    crps = DirectoryCorpus("sotu")

    standardize!(crps, StringDocument)

    crps = Corpus(crps[1:30])

    remove_case!(crps)
    prepare!(crps, strip_punctuation)

    update_lexicon!(crps)
    update_inverse_index!(crps)

    crps["freedom"]

    m = DocumentTermMatrix(crps)

    D = dtm(m, :dense)

    T = tf_idf(D)

    cl = kmeans(T, 5)
```
