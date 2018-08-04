m = SentimentAnalyzer()

d=StringDocument("a very nice thing that everyone likes")

m(d) > 0.5

d=StringDocument("a horrible thing that everyone hates")

m(d) < 0.5
