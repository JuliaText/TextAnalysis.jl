@testset "ROUGE" begin

    candidate_sentence = "Brazil, Russia, China and India are growing nations"
    candidate_summary =  "Brazil, Russia, China and India are growing nations. They are all an important part of BRIC as well as regular part of G20 summits."

    reference_sentences = ["Brazil, Russia, India and China are growing nations", "Brazil and India are two of the developing nations that are part of the BRIC"]
    reference_summaries = ["Brazil, Russia, India and China are the next big poltical powers in the global economy. Together referred to as BRIC(S) along with South Korea.", "Brazil, Russia, India and China are together known as the  BRIC(S) and have been invited to the G20 summit."]
    
    @test rouge_l_summary(reference_summaries, candidate_summary, 8, true) == 0.42565327352779836

    @test rouge_n(reference_summaries, candidate_summary, 1, true) == 0.5051282051282051
    @test rouge_n(reference_summaries, candidate_summary, 2, true) == 0.1317241379310345

    @test rouge_n(reference_sentences, candidate_sentence, 2, true) == 0.3492063492063492
    @test rouge_n(reference_sentences, candidate_sentence, 2, true) == 0.6666666666666666

    @test rouge_l_sentence(reference_sentences, candidate_sentence, 8, false) == 0.36164547980729794

end