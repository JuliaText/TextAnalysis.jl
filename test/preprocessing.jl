sample_text1 = "This is 1 MESSED UP string!"
sample_text1_wo_punctuation = "This is 1 MESSED UP string"
sample_text1_wo_punctuation_numbers = "This is  MESSED UP string"
sample_text1_wo_punctuation_numbers_case = "this is  messed up string"

sd = StringDocument(sample_text1)

remove_punctuation!(sd)

remove_numbers!(sd)

remove_case!(sd)

# remove_whitespace!(sd)
# remove_words!(sd)
# remove_stop_words!(sd)
# remove_articles!(sd)
# remove_definite_articles!(sd)
# remove_indefinite_articles!(sd)
# remove_prepositions!(sd)
# remove_pronouns!(sd)
# stem!(sd)
# tag_pos!(sd)
