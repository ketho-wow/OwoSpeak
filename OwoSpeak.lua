local NAME = ...
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

OwoSpeak = {}

local defaults = {
	enabled = true,
	SAY = true,
	YELL = true,
	EMOTE = false,
	PARTY = true,
	RAID = false,
	INSTANCE_CHAT = true,
	GUILD = true,
	OFFICER = false,
	WHISPER = false,
}

local chat = {
	"SAY",
	"YELL",
	"INSTANCE_CHAT",
	"EMOTE",
	"PARTY",
	"RAID",
	"GUILD",
	"OFFICER",
	"WHISPER",
}

local channels = {}

local options = {
	type = "group",
	name = "|TInterface/AddOns/OwoSpeak/icon.png:20:20:-8:2|t"..NAME,
	get = function(i) return OwoSpeak.db[i[#i]] end,
	set = function(i, v) OwoSpeak.db[i[#i]] = v end,
	args = {
		enabled = {
			type = "toggle", order = 1,
			width = "full",
			name = ENABLE,
		},
		chat = {
			type = "group", order = 2,
			name = CHAT,
			inline = true,
			disabled = function() return not OwoSpeak.db.enabled end,
			args = {},
		},
		channels = {
			type = "group", order = 3,
			name = CHANNELS,
			inline = true,
			disabled = function() return not OwoSpeak.db.enabled end,
			args = {},
		},
	},
}

-- ChatTypeInfo is not immediately available
C_Timer.After(1, function()
	for k, v in pairs(chat) do
		local info = ChatTypeInfo[v]
		local color = CreateColor(info.r, info.g, info.b)
		options.args.chat.args[v] = {
			type = "toggle", order = k,
			name = function()
				-- make it possible to gray out the channel names
				return OwoSpeak.db.enabled and color:WrapTextInColorCode(_G[v]) or _G[v]
			end,
		}
	end
end)

local f = CreateFrame("Frame")

function f:OnEvent(event, ...)
	self[event](self, ...)
end

function f:ADDON_LOADED(addon)
	if addon == NAME then
		OwoSpeakDB3 = OwoSpeakDB3 or {}
		for k, v in pairs(defaults) do
			-- allow adding new options this way
			if OwoSpeakDB3[k] == nil then
				OwoSpeakDB3[k] = v
			end
		end
		OwoSpeak.db = OwoSpeakDB3
		ACR:RegisterOptionsTable(NAME, options)
		ACD:AddToBlizOptions(NAME, NAME)
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function f:PLAYER_ENTERING_WORLD(isLogin, isReload)
	if isReload then -- refresh after a /reload
		self:CHANNEL_UI_UPDATE()
	end
end

function f:CHANNEL_UI_UPDATE()
	wipe(channels)
	local list = {GetChannelList()}

	for i = 1, #list, 3 do
		local name = list[i+1]
		channels[list[i]] = strfind(name, "Community:") and ChatFrame_ResolveChannelName(name) or name
	end

	for i = 1, MAX_WOW_CHAT_CHANNELS do
		if channels[i] then
			local info = ChatTypeInfo["CHANNEL"..i]
			local color = CreateColor(info.r, info.g, info.b)
			local text = format("%d. %s", i, channels[i])
			options.args.channels.args["CHANNEL"..i] = {
				type = "toggle", order = i,
				name = function() return OwoSpeak.db.enabled and color:WrapTextInColorCode(text) or text end,
			}
		else
			options.args.channels.args["CHANNEL"..i] = nil
		end
	end
	ACR:NotifyChange(NAME)
end

function OwoSpeak:shouldowo(chatType, target)
	if not OwoSpeak.db.enabled then
		return false
	end
	if chatType == "CHANNEL" then
		return OwoSpeak.db[chatType..target]
	else
		return OwoSpeak.db[chatType]
	end
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHANNEL_UI_UPDATE")
f:SetScript("OnEvent", f.OnEvent)

SLASH_OWOSPEAK1 = "/owospeak"
SLASH_OWOSPEAK2 = "/owo"

SlashCmdList.OWOSPEAK = function()
	ACD:SetDefaultSize(NAME, 420, 420)
	ACD:Open(NAME)
end
