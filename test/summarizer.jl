@testset "Summarizer" begin
d = StringDocument("""
    Discount retailer Poundworld has appointed administrators, putting 5,100 jobs at risk.
    The move came after talks with a potential buyer, R Capital, collapsed leaving Poundworld with no option other than administration.
    Poundworld, which serves two million customers a week from 355 stores, also trades under the Bargain Buys name.
    Administrators Deloitte stress the stores will continue to trade as normal with no redundancies at this time.
    It said in a statement: Like many high street retailers, Poundworld has suffered from high product cost inflation, decreasing footfall, weaker consumer confidence and an increasingly competitive discount retail market.
    Clare Boardman, joint administrator at Deloitte, said: The retail trading environment in the UK remains extremely challenging and Poundworld has been seeking to address this through a restructure of its business.
    Unfortunately, this has not been possible.
    She said Deloitte believed a buyer could be found for the business, or at least part of it.
    A spokesperson for Poundworlds owner, TPG said filing for administration had been a difficult decision.
    Despite investing resources to strengthen the business, the decline in UK retail and changing consumer behaviour affected Poundworld significantly, they added.
    """)


s = summarize(d)
@test length(s) == 5
@test s[1] == "Discount retailer Poundworld has appointed administrators, putting 5,100 jobs at risk."

s = summarize(d; ns=2)
@test length(s) == 2

short_doc = StringDocument("These is a small document. It has only 2 sentences in it.")

s = summarize(short_doc)
@test length(s) == 2

end
