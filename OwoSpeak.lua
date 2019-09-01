local owos = {
	"OwO",
	"owo",
	"UwU",
	"uwu",
	"^w^",
	"(´•ω•`)",
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
	local owo = owos[random(#owos)]
	local whatsthis = random(10)
	-- tempowawiwy wepwace winks with owos
	local s = msg:gsub("|c.-|r", ReplaceLink)
	s = s:gsub("[LR]", "W")
	s = s:gsub("[lr]", "w")
	s = s:gsub("ith", "if")
	s = whatsthis <= 7 and s:gsub(" ([fps])([aeiou])", " %1w%2") or s
	s = whatsthis <= 5 and s:gsub(" n([aeiou])", " ny%1") or s
	s = whatsthis <= 3 and s:gsub(" th", " d") or s
	s = whatsthis == 1 and s.." "..owo or s:gsub("!$", " "..owo)
	-- pwease owo wesponsibwy; nyot foowpwoof
	s = #s <= 255 and s:gsub("owo%d", RestoreLink) or msg
	makeowo(s, ...)
end
