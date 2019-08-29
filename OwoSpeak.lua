local owos = {
	"OwO",
	"owo",
	"UwU",
	"uwu",
	"^w^",
}
local hyperlinks = {}

local function ReplaceLink(s)
	tinsert(hyperlinks, s)
	return "owo"..#hyperlinks
end

local function RestoreLink(s)
	local n = tonumber(s:match("%d"))
	return hyperlinks[n]
end

local makeowo = SendChatMessage

function SendChatMessage(msg, ...)
	wipe(hyperlinks)
	-- tempowawiwy wepwace winks with owos
	msg = msg:gsub("|c.-|r", ReplaceLink)
	msg = msg:gsub("[LR]", "W")
	msg = msg:gsub("[lr]", "w")
	msg = msg:gsub("n([aeiou])", "ny%1")
	msg = msg:gsub("!$", " "..owos[random(#owos)])
	msg = msg:gsub("owo%d", RestoreLink)
	makeowo(msg, ...)
end
