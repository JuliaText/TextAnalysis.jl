@testset "Evaluation Metrics" begin
    @testset "Rouge" begin
        candidate_sentence = "Brazil, Russia, China and India are growing nations"
        candidate_summary =  "Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits."

        reference_sentences = ["Brazil, Russia, India and China are growing nations", "Brazil and India are two of the developing nations that are part of the BRIC"]
        reference_summaries = ["Brazil, Russia, India and China are the next big poltical powers in the global economy. Together referred to as BRIC(S) along with South Korea.", "Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit."]

        @test rouge_n(reference_summaries, candidate_summary, 1, avg=true) >= 0.505
        @test rouge_n(reference_summaries, candidate_summary, 2, avg=true) >= 0.131

        @test rouge_n(reference_sentences, candidate_sentence, 2, avg=true) >= 0.349
        @test rouge_n(reference_sentences, candidate_sentence, 1, avg=true) >= 0.666

        @test rouge_l_summary(reference_summaries, candidate_summary, 8, true) >= 0.4256
    end
end
