WordsFilter = {}

local wordsList = {
	"сука",
	"хуй",
	"ебал",
	"пидор",
	"падла",
	"гандон",
	"гондон",
	"бля",
	"блядь",
	"блять",
	"хуета",
	"ебать",
	"мудак",
	"уёбок",
	"уебок",
	"пизда",
	"пиздец",
	"пизд",
	"пидр",
	"говно",
	"ебан",
	"нахуя",
	"нахера",
	"похер",

	"fuck",
	"ass",
	"bitch",
	"faggot"
}

local function getFilteredWord(word)
	local len = utf8.len(word)
	if len <= 3 then
		local filtered = ""
		for i = 1, len do
			filtered = filtered .. "*"
		end
		return filtered
	end

	local m = ""
	for i = 1, len - 2 do
		m = m .. "*"
	end
	return utf8.sub(word, 1, 1) .. m .. utf8.sub(word, -1)
end

function WordsFilter.filter(message)
	local lowerMessage = utf8.lower(message)
	for i, word in ipairs(wordsList) do
		local st, en = utf8.find(lowerMessage, utf8.lower(word))
		if st then
			local wordToFiler = utf8.sub(message, st, en)
			message = utf8.gsub(message, wordToFiler, getFilteredWord)
		end
	end
	return message
end