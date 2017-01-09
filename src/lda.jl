##############################################################################
#
# LDA
#
##############################################################################

module Lda

type TopicBasedDocument
    topic::Vector{Int}
    text::Vector{Int}
    topicidcount::Dict{Int, Int}
end
TopicBasedDocument() = TopicBasedDocument(Vector{Int}(), Vector{Int}(), Dict{Int, Int}())

type Topic
    count::Int
    wordcount::Dict{Int, Int}
end
Topic() = Topic(0, Dict{Int, Int}())

end

function lda(dtm::DocumentTermMatrix, ntopics::Int, iteration::Int, alpha::Float64, beta::Float64)

    number_of_documents, number_of_words = size(dtm.dtm)
    docs = Vector{Lda.TopicBasedDocument}()
    topics = Dict{Int, Lda.Topic}()
    for i in 1:ntopics
        topics[i] = Lda.Topic()
    end

    for i in 1:number_of_documents
        topic_base_document = Lda.TopicBasedDocument()
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
        push!(docs, topic_base_document)
    end

    # Gibbs sampling
    for _ in 1:iteration
        for doc in docs
            for (i, word) in enumerate(doc.text)
                topicid_current = doc.topic[i]
                doc.topicidcount[topicid_current] -= 1 
                topics[topicid_current].count -= 1
                topics[topicid_current].wordcount[word] -= 1
                document_lenth = length(doc.text) - 1
                probs = Vector{Float64}()
                for target_topicid in 1:ntopics
                    topicprob = (get(doc.topicidcount, target_topicid, 0) + beta) / (document_lenth + beta * ntopics)
                    wordprob = (get(topics[target_topicid].wordcount, word, 0)+ alpha) / (topics[target_topicid].count + alpha * number_of_words)
                    push!(probs, topicprob * wordprob)
                end
                normalize_probs = sum(probs)
                
                # select new topic
                select = rand()
                sum_of_prob = 0
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

    # result
    # topic x word sparse matrix.
    result = spzeros(ntopics, number_of_words)
    for topic in 1:ntopics
        t = topics[topic]
        for (word, count) in t.wordcount
            if 0 < t.count
                result[topic, word] = count / t.count
            end
        end
    end
    return result
end

