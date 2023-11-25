local owos = {
	"OwO",
	"owo",
	"UwU",
	"uwu",
	"^w^",
	">w<",
	"(´•ω•`)",
}

local defaults = {
	enabled = true,
	guild = true,
	officer = true,
	whisper = true,
}

local db
local hyperlinks = {}

local function OnEvent(self, event, addon)
	if addon == "OwoSpeak" then
		OwoSpeakDB = OwoSpeakDB or CopyTable(defaults)
		db = OwoSpeakDB
		for k, v in pairs(defaults) do
			if db[k] == nil then
				db[k] = v
			end
		end
		self:UnregisterEvent("ADDON_LOADED")
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnEvent)

-- owo1, owo2, etc pwacehowdews
local function ReplaceLink(s)
	tinsert(hyperlinks, s)
	return "owo"..#hyperlinks
end

local function RestoreLink(s)
	local n = tonumber(s:match("%d"))
	return hyperlinks[n]
end

local channelOptions = {
	GUILD = "guild",
	OFFICER = "officer",
	WHISPER = "whisper",
}

local function ShouldOwo(chatType)
	if db.enabled then
		local option = channelOptions[chatType]
		if option then
			return db[option]
		else
			return true
		end
	end
end

local makeowo = SendChatMessage

function SendChatMessage(msg, chatType, ...)
	if ShouldOwo(chatType) then
		wipe(hyperlinks)
		local owo = owos[random(#owos)]
		local whatsthis = random(10)
		-- tempowawiwy wepwace winks wif owos
		local s = msg:gsub("|c.-|r", ReplaceLink)
		-- wepwace waid mawkers
		-- pwacehowders
		s = s:gsub("{.-}", ReplaceLink)
		s = s:gsub("([lr])([%S]*s?)", function(l, following)
		    if l == 'r' and following == 's' then
		        return 'r' .. following
		    elseif l == 'R' and following == 's' then
		        return 'R' .. following
		    else
		        return 'w' .. following
		    end
		end)
		
		s = s:gsub("([LR])([%S]*S?)", function(L, following)
		    if L == 'R' and following == 'S' then
		        return 'R' .. following
		    elseif L == 'L' then
		        return 'W' .. following
		    else
		        return 'W' .. following
		    end
		end)
		if whatsthis <= 5 then
			s = s:gsub("U([^VW])", "UW%1")
			s = s:gsub("u([^vw])", "uw%1")
		end
		s = s:gsub("ith " , "if ")
		s = s:gsub("([fps])([aeio]%w+)", "%1w%2") or s
		s = s:gsub("n([aeiou]%w)", "ny%1") or s
		s = s:gsub(" th", " d") or s
		-- y-you awe such a b-baka
		s = format(" %s ", s)
		for k in gmatch(s, "%a+") do
			if random(10) == 1 then
				local firstChar = k:sub(1, 1)
				s = s:gsub(format(" %s ", k), format(" %s-%s ", firstChar, k))
			end
		end
		s = s:trim()
		s = whatsthis == 1 and s.." "..owo or s:gsub("!$", " "..owo)
		-- pwease owo wesponsibwy
		s = #s <= 255 and s:gsub("owo%d", RestoreLink) or msg
		makeowo(s, chatType, ...)
	else
		makeowo(msg, chatType, ...)
	end
end

local EnabledMsg = {
	[true] = "|cffADFF2FEnabwed|r",
	[false] = "|cffFF2424Disabwed|r",
}

local function PrintMessage(msg)
	print("OwoSpeak: "..msg)
end

SLASH_OWOSPEAK1 = "/owo"
SLASH_OWOSPEAK2 = "/owospeak"

SlashCmdList.OWOSPEAK = function(msg)
	if msg == "guild" then
		db.guild = not db.guild
		PrintMessage("Guild - "..EnabledMsg[db.guild])
	elseif msg == "officer" then
		db.officer = not db.officer
		PrintMessage("Officer - "..EnabledMsg[db.officer])
	elseif msg == "whisper" then
		db.whisper = not db.whisper
		PrintMessage("Whisper - "..EnabledMsg[db.whisper])
	else
		db.enabled = not db.enabled
		PrintMessage(EnabledMsg[db.enabled])
	end
end
