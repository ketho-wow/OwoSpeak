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

local blockedChannelsDefaults = {
	"NewcomerChat",
}

local db
local blockedChannels
local hyperlinks = {}

local function OnEvent(self, event, addon)
	if addon == "OwoSpeak" then
		OwoSpeakDB = OwoSpeakDB or CopyTable(defaults)
		OwoSpeakDBBlockedChannels = OwoSpeakDBBlockedChannels or CopyTable(blockedChannelsDefaults)
		blockedChannels = OwoSpeakDBBlockedChannels
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
	GUILD = function() return db.guild end,
	OFFICER = function() return db.officer end,
	WHISPER = function() return db.whisper end,
}

local function ShouldOwo(chatType)
	if db.enabled then
		if channelOptions[chatType] then
			return channelOptions[chatType]()
		else
			return true
		end
	end
end

local function ShouldOwoTwo(chatType, channel)
	if chatType == "CHANNEL" then
		local id, channelName = GetChannelName(channel)

		for key, value in pairs(blockedChannels) do
			if channelName == value then
				-- print("Found " .. channelName .. " in blockedChannels table.  Do not owo")
				return false
			end
		end
	end
	-- print("Did not find " .. channelName .. " in blockedChannels table.  owo away!")
	return true
end

local makeowo

local function owo(msg, chatType, language, channel)
	-- im so sowwy meo
	if msg == "GHI2ChannelReadyCheck" then
		return
	end
	if ShouldOwo(chatType) and ShouldOwoTwo(chatType, channel) then
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
		s = format(" %s ", s)
		for k in gmatch(s, "%a+") do
			if random(12) == 1 then
				local firstChar = k:sub(1, 1)
				s = s:gsub(format(" %s ", k), format(" %s-%s ", firstChar, k))
			end
		end
		s = s:trim()
		s = whatsthis == 1 and s.." "..owo or s:gsub("!$", " "..owo)
		-- pwease owo wesponsibwy
		s = #s <= 255 and s:gsub("owo%d", RestoreLink) or msg
		makeowo(s, chatType, language, channel)
	else
		makeowo(msg, chatType, language, channel)
	end
end

if C_ChatInfo.SendChatMessage then
	makeowo = C_ChatInfo.SendChatMessage
	C_ChatInfo.SendChatMessage = owo
else
	makeowo = SendChatMessage
	SendChatMessage = owo
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

local function tablefind(tab,el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

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
	elseif string.find(msg, "add") then
		local exploded = {}
		for substring in string.gmatch(msg, "[^%s]+") do
		   table.insert(exploded, substring)
		end
		if exploded[2] then
			table.insert(blockedChannels, exploded[2])
			PrintMessage("Added " .. exploded[2] .. " to the blocked channel list.")
		else
			PrintMessage("You must provide a channel name to block.")
		end
	elseif string.find(msg, "remove") then
		local exploded = {}
		local foundAndRemoved = false
		for substring in string.gmatch(msg, "[^%s]+") do
		   table.insert(exploded, substring)
		end
		if exploded[2] then
			for key, value in pairs(blockedChannels) do
				if value == exploded[2] then
					PrintMessage("Removed " .. exploded[2] .. " from the blocked channels list.")
					table.remove(blockedChannels, tablefind(blockedChannels, exploded[2]))
					foundAndRemoved = true
				end
			end
			if foundAndRemoved == false then
				PrintMessage("Could not find the specified channel in the blocked channels list.")
			end
		else
			PrintMessage("You must provide a channel name to unblock.")
		end
	elseif msg == "blocked" then
		PrintMessage("Currently blocked channels:")
		for key, value in pairs(blockedChannels) do
			print(value)
		end
	elseif msg == "help" then
		PrintMessage("Available commands:")
		print("/owo guild - enable/disable guild chat owospeak")
		print("/owo officer - enable/disable officer chat owospeak")
		print("/owo whisper - enable/disable whisper owospeak")
		print("/owo add <channel name> - prevent owospeak in a specific channel")
		print("/owo remove <channel name> - re-enable owospeak in a blocked channel (see /owo add)")
		print("/owo blocked - print list of currently blocked channels")
	else
		db.enabled = not db.enabled
		PrintMessage(EnabledMsg[db.enabled])
	end
end
