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
	db_version = 2,
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

local function ReplaceLink(s)
	tinsert(hyperlinks, s)
	return "owo"..#hyperlinks
end

local function RestoreLink(s)
	local n = tonumber(s:match("%d"))
	return hyperlinks[n]
end

local function ShouldOwo(chatType)
	if db.enabled then
		if chatType == "GUILD" then
			return db.guild
		else
			if chatType == "OFFICER" then
				return db.officer
			else
				if chatType == "WHISPER" then
					return db.whisper
				else
					return true
				end
			end
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
		-- wepwace waid mawkews
		s = s:gsub("{rt", ReplaceLink)
		s = s:gsub("[LR]", "W")
		s = s:gsub("[lr]", "w")
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

SLASH_OWOSPEAK1 = "/owo"
SLASH_OWOSPEAK2 = "/owospeak"

SlashCmdList.OWOSPEAK = function(msg)
	if msg == "guild" then
		db.guild = not db.guild
		print("OwoSpeak: Guild - "..EnabledMsg[db.guild])
	else
		if msg == "officer" then
			db.officer = not db.officer
			print("OwoSpeak: Officer - "..EnabledMsg[db.officer])
		else
			if msg == "whisper" then
				db.whisper = not db.whisper
				print("OwoSpeak: Whisper - "..EnabledMsg[db.whisper])
			else		
				db.enabled = not db.enabled
				print("OwoSpeak: "..EnabledMsg[db.enabled])
			end
		end
	end
end
