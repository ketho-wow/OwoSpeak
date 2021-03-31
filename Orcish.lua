local XPs = {
	". Waaagh!"
}

local defaults = {
	db_version = 1,
	enabled = true,
}

local db
local hyperlinks = {}

local function OnEvent(self, event, addon)
	if addon == "Orkish" then
		if not OrkishDB or OrkishDB.db_version < defaults.db_version then
			OrkishDB = CopyTable(defaults)
		end
		db = OrkishDB
		self:UnregisterEvent("ADDON_LOADED")
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnEvent)

local function ReplaceLink(s)
	tinsert(hyperlinks, s)
	return "XP"..#hyperlinks
end

local function RestoreLink(s)
	local n = tonumber(s:match("%d"))
	return hyperlinks[n]
end

local makexp = SendChatMessage

function SendChatMessage(msg, ...)
	if db.enabled then
		wipe(hyperlinks)
		local XP = XPs[random(#XPs)]
		local whatsthis = random(10)

		local s = msg:gsub("|c.-|r", ReplaceLink)
		s = string.gsub(s, "(.*)", " %1 ")
		s = s:gsub("Hey", "Oi")
		s = s:gsub("hey", "oi")
		s = s:gsub("mate", "git")
		s = s:gsub("hello", "oi")
		s = s:gsub("Hello", "Oi")
		s = string.gsub(s, "(%W)([hH])(%a)", "%1'%3")
		s = string.gsub(s, "(%w+)(ing)", "%1in'")
		s = string.gsub(s, "(%w+)(s)(%W)", "%1z%3")
		s = string.gsub(s, "tt", "dd")
		s = string.gsub(s, "(%w+)(er)(%W)", "%1a%3")
		s = string.gsub(s, "The", "Da")
		s = string.gsub(s, "tha", "da"))
		s = string.gsub(s, "Those", "Dose")
		s = string.gsub(s, "those", "dose")
		s = string.gsub(s, "Th", "F")
		s = string.gsub(s, "th", "f")
		s = string.gsub(s, "oul", "u")

		
		s = format(" %s ", s)
		s = s:trim()
		s = whatsthis == 1 and s..XP or s:gsub("!$", XP)
		s = #s <= 255 and s:gsub("XP%d", RestoreLink) or msg
		makexp(s, ...)
	else
		makexp(msg, ...)
	end
end

local EnabledMsg = {
	[true] = "|cffADFF2FEnabled|r",
	[false] = "|cffFF2424Disabled|r",
}

SLASH_Orkish1 = "/ork"
SLASH_Orkish2 = "/whork"

SlashCmdList.Orkish = function()
	db.enabled = not db.enabled
	print("Orkish: "..EnabledMsg[db.enabled])
end