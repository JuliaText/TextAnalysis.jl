using TextAnalysis
using Test

@testset "Service functions check" begin
    # check correct positions of the constructor parameters
    p = 0.1
    r = 0.2
    f = 0.3
    s = Score(p, r, f)
    @test s == Score(precision=p, recall=r, fmeasure=f)
    @test s.precision ≈ p && s.fmeasure ≈ f

    @test argmax([
        Score(0., 1., 2.),
        Score(3., 0., 0.),
        Score(0., 6., 1.)
    ]) == Score(0., 1., 2.)

    @test average([
        Score(1., 10., 100.),
        Score(2., 20., 200.),
        Score(3., 30., 300.)
    ]) == Score(2., 20., 200.)
end

@testset "Evaluation Metrics" begin
    @testset "Rouge" begin
        candidate_sentence = "Brazil, Russia, China and India are growing nations"
        candidate_summary = "Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits."

        reference_sentences = ["Brazil, Russia, India and China are growing nations", "Brazil and India are two of the developing nations that are part of the BRIC"]
        reference_summaries = ["Brazil, Russia, India and China are the next big poltical powers in the global economy. Together referred to as BRIC(S) along with South Korea.", "Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit."]

        @test argmax(rouge_n(reference_summaries, candidate_summary, 1)).fmeasure >= 0.505
        @test argmax(rouge_n(reference_summaries, candidate_summary, 2)).fmeasure >= 0.131

        @test argmax(rouge_n(reference_sentences, candidate_sentence, 2)).fmeasure >= 0.349
        @test argmax(rouge_n(reference_sentences, candidate_sentence, 1)).fmeasure >= 0.666

        @test argmax(rouge_l_sentence(reference_summaries, candidate_summary, 8, weighted=true)).recall >= 0.285

        @test argmax(rouge_l_summary(reference_summaries, candidate_summary, 8)).recall >= 0.23
    end
end

# https://github.com/google-research/google-research/blob/master/rouge/rouge_scorer.py
# 
# from rouge_score import rouge_scorer
# 
# scorer = rouge_scorer.RougeScorer(['rouge1', 'rouge2', 'rougeL', 'rougeLsum'], use_stemmer=True)
# scores = scorer.score('The quick brown fox jumps over the lazy dog',
#                       'The quick brown dog jumps on the log.')
# print(scores)
# {
#   'rouge1': Score(precision=0.75, recall=0.6666666666666666, fmeasure=0.7058823529411765), 
#   'rouge2': Score(precision=0.2857142857142857, recall=0.25, fmeasure=0.26666666666666666), 
#   'rougeL': Score(precision=0.625, recall=0.5555555555555556, fmeasure=0.5882352941176471), 
#   'rougeLsum': Score(precision=0.625, recall=0.5555555555555556, fmeasure=0.5882352941176471)
# }

@testset "Compare with google-research/rouge" begin
    reference_summaries = ["The quick brown fox jumps over the lazy dog"]
    candidate_summary = "The quick brown dog jumps on the log"
    @test argmax(rouge_n(reference_summaries, candidate_summary, 1)).fmeasure ≈ 0.70588
    @test argmax(rouge_n(reference_summaries, candidate_summary, 2)).fmeasure ≈ 0.26667
    @test argmax(rouge_l_sentence(reference_summaries, candidate_summary, 1)).fmeasure ≈ 0.5882
    @test argmax(rouge_l_summary(reference_summaries, candidate_summary, 1)).fmeasure ≈ 0.5882
end
