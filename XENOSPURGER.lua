local XPs = {
	". FOR THE EMPEROR!",
	". PURGE THE XENOS!",
	". CLEANSE THE FILTH!",
	". PURGE THE UNCLEAN!",
	". BY THE INQUISITION!",
	". SUFFER NOT THE XENO TO LIVE!",
	". BURN THE HERETIC!",
	". KILL THE MUTANT!",
	". IN THE EMPEROR'S NAME, LET NONE SURVIVE!",
	". FOR THE IMPERIVM OF MAN!"
}

local defaults = {
	db_version = 1,
	enabled = true,
}

local db
local hyperlinks = {}

local function OnEvent(self, event, addon)
	if addon == "XENOSPURGER" then
		if not XENOSPURGERDB or XENOSPURGERDB.db_version < defaults.db_version then
			XENOSPURGERDB = CopyTable(defaults)
		end
		db = XENOSPURGERDB
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
		local whatsthis = random(2)

		local s = msg:gsub("|c.-|r", ReplaceLink)
		s = string.upper(s)
		s = s:gsub("ORCS", "XENOS")
		s = s:gsub("TAURENS", "XENOS")
		s = s:gsub("NELFS", "XENOS")
		s = s:gsub("UNDEAD", "XENO/S")
		s = s:gsub("TROLLS", "XENOS")
		s = s:gsub("GNOMES", "XENOS")
		s = s:gsub("ORC", "XENO")
		s = s:gsub("TAUREN", "XENO/S")
		s = s:gsub("NELF", "XENO")
		s = s:gsub("TROLL", "XENO")
		s = s:gsub("GNOME", "XENO")
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

SLASH_XENOSPURGER1 = "/xp"
SLASH_XENOSPURGER2 = "/xp2"

SlashCmdList.XENOSPURGER = function()
	db.enabled = not db.enabled
	print("XENOSPURGER: "..EnabledMsg[db.enabled])
end