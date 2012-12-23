##############################################################################
#
# Remove corrupt UTF8 characters
#
##############################################################################

function remove_corrupt_utf8!(d::Union(StringDocument, FileDocument))
	t = text(d)
	r = Array(Char, strlen(t))
	i = 0
	for chr in t
		i += 1
		if chr == 0xfffd
			r[i] = ' '
		else
			r[i] = chr
		end
	end
	text!(d, utf8(CharString(r[1:i])))
end

remove_corrupt_utf8!(d::AbstractDocument) = error("Not yet implemented")

##############################################################################
#
# Remove punctuation
#
##############################################################################

const PUNCTUATION_REGEX = r"[,;:.!?()]+"

function remove_punctuation!(d::Union(StringDocument, FileDocument))
	text!(d, replace(d.text, PUNCTUATION_REGEX, ""))
end

remove_punctuation!(d::AbstractDocument) = error("Not yet implemented")

##############################################################################
#
# Conversion to lowercase
#
##############################################################################

function remove_case!(d::Union(StringDocument, FileDocument))
	text!(d, lowercase(text(d)))
end

remove_case!(d::AbstractDocument) = error("Not yet implemented")

##############################################################################
#
# Remove numbers
#
# TODO: Currently removes all numeric characters.
#       Should we just remove purely numeric tokens?
#
##############################################################################

function remove_numbers!(d::Union(StringDocument, FileDocument))
  	text!(d, replace(text(d), r"\d", ""))
end

remove_numbers!(d::AbstractDocument) = error("Not yet implemented")

##############################################################################
#
# Remove specified words
#
##############################################################################

function remove_words!{T <: String}(sd::StringDocument, words::Vector{T})
	for word in words
		text!(sd, replace(text(sd), word, " "))
	end
end

function remove_words!{T <: String}(sd::AbstractDocument, words::Vector{T})
	error("Not yet implemented")
end

##############################################################################
#
# Stemming
#
##############################################################################

stem!(fd::AbstractDocument) = error("Not yet implemented")

##############################################################################
#
# Part-of-Speech tagging
#
##############################################################################

tag_pos!(fd::AbstractDocument) = error("Not yet implemented")

##############################################################################
#
# Call preprocessing step on each document in a Corpus
#
##############################################################################

for f in (:remove_corrupt_utf8!, :remove_punctuation!, :remove_case!,
	      :remove_numbers!, :remove_words!, :stem!, :tag_pos!)
	@eval begin
		function ($f)(crps::Corpus)
			for doc in crps
				($f)(doc)
			end
		end
	end
end

##############################################################################
#
# Remove articles, indefinite articles, definite articles,
# prepositions, pronouns and stop words
#
##############################################################################

function remove_articles!(o::Union(GenericDocument, Corpus))
	remove_words!(o, articles(language(o)))
end

function remove_indefinite_articles!(o::Union(GenericDocument, Corpus))
	remove_words!(o, indefinite_articles(language(o)))
end

function remove_definite_articles!(o::Union(GenericDocument, Corpus))
	remove_words!(o, definite_articles(language(o)))
end

function remove_prepositions!(o::Union(GenericDocument, Corpus))
	remove_words!(o, prepositions(language(o)))
end

function remove_pronouns!(o::Union(GenericDocument, Corpus))
	remove_words!(o, pronouns(language(o)))
end

function remove_stop_words!(o::Union(GenericDocument, Corpus))
	remove_words!(o, stop_words(language(o)))
end
