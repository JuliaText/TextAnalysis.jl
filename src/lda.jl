##############################################################################
#
# LDA
#
##############################################################################

module Lda

mutable struct TopicBasedDocument
    topic::Vector{Int}
    text::Vector{Int}
    topicidcount::Vector{Int}
end
TopicBasedDocument(ntopics) = TopicBasedDocument(Vector{Int}(), Vector{Int}(), zeros(Int, ntopics))

mutable struct Topic
    count::Int
    wordcount::Dict{Int, Int}
end
Topic() = Topic(0, Dict{Int, Int}())

end

"""
    ϕ, θ = lda(dtm::DocumentTermMatrix, ntopics::Int, iterations::Int, α::Float64, β::Float64)

Perform [Latent Dirichlet allocation](https://en.wikipedia.org/wiki/Latent_Dirichlet_allocation).

# Arguments
- `α` Dirichlet dist. hyperparameter for topic distribution per document. `α<1` yields a sparse topic mixture for each document. `α>1` yields a more uniform topic mixture for each document.
- `β` Dirichlet dist. hyperparameter for word distribution per topic. `β<1` yields a sparse word mixture for each topic. `β>1` yields a more uniform word mixture for each topic.

# Return values
- `ϕ`: `ntopics × nwords` Sparse matrix of probabilities s.t. `sum(ϕ, 1) == 1`
- `θ`: `ntopics × ndocs` Dense matrix of probabilities s.t. `sum(θ, 1) == 1`
"""
function lda(dtm::DocumentTermMatrix, ntopics::Int, iteration::Int, alpha::Float64, beta::Float64)

    number_of_documents, number_of_words = size(dtm.dtm)
    docs = Vector{Lda.TopicBasedDocument}(undef, number_of_documents)
    topics = Vector{Lda.Topic}(undef, ntopics)
    for i in 1:ntopics
        topics[i] = Lda.Topic()
    end

    for i in 1:number_of_documents
        topic_base_document = Lda.TopicBasedDocument(ntopics)
        for wordid in 1:number_of_words
            for _ in 1:dtm.dtm[i,wordid]
                topicid = rand(1:ntopics)
                update_target_topic = topics[topicid]
                update_target_topic.count += 1
                update_target_topic.wordcount[wordid] = get(update_target_topic.wordcount, wordid, 0) + 1
                topics[topicid] = update_target_topic
                push!(topic_base_document.topic, topicid)
                push!(topic_base_document.text, wordid)
                topic_base_document.topicidcount[topicid] =  get(topic_base_document.topicidcount, topicid, 0) + 1
            end
        end
        docs[i] = topic_base_document
    end
    probs = Vector{Float64}(undef, ntopics)
    # Gibbs sampling
    for _ in 1:iteration
        for doc in docs
            for (i, word) in enumerate(doc.text)
                topicid_current = doc.topic[i]
                doc.topicidcount[topicid_current] -= 1
                topics[topicid_current].count -= 1
                topics[topicid_current].wordcount[word] -= 1
                document_lenth = length(doc.text) - 1

                for target_topicid in 1:ntopics
                    topicprob = (doc.topicidcount[target_topicid] + beta) / (document_lenth + beta * ntopics)
                    wordprob = (get(topics[target_topicid].wordcount, word, 0)+ alpha) / (topics[target_topicid].count + alpha * number_of_words)
                    probs[target_topicid] = topicprob * wordprob
                end
                normalize_probs = sum(probs)

                # select new topic
                select = rand()
                sum_of_prob = 0.0
                new_topicid = 0
                for (selected_topicid, prob) in enumerate(probs)
                    sum_of_prob += prob / normalize_probs
                    if select < sum_of_prob
                        new_topicid = selected_topicid
                        break
                    end
                end
                doc.topic[i] = new_topicid
                doc.topicidcount[new_topicid] = get(doc.topicidcount, new_topicid, 0) + 1
                topics[new_topicid].count += 1
                topics[new_topicid].wordcount[word] = get(topics[new_topicid].wordcount, word, 0) + 1
            end
        end
    end

    # ϕ
    # topic x word sparse matrix.
    ϕ = spzeros(ntopics, number_of_words)
    θ = getfield.(docs, :topicidcount)
    θ = Float64.(hcat(θ...))
    θ ./= sum(θ, dims=1)
    for topic in 1:ntopics
        t = topics[topic]
        for (word, count) in t.wordcount
            if 0 < t.count
                ϕ[topic, word] = count / t.count
            end
        end
    end
    return ϕ, θ
end
