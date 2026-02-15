local emoticons = {
	"owo",
	"uwu",
	">w<",
	":3",
}

local links = {}

local function ReplaceLink(s)
	tinsert(links, s)
	return "#@#"..#links -- pwacehowdews fow winks
end

local function RestoreLinks(s)
	local n = tonumber(s:match("%d+"))
	return links[n]
end

local function SubstituteLinks(s)
    wipe(links)
    s = s:gsub("|c.-|r", ReplaceLink)
    s = s:gsub("{.-}", ReplaceLink)
    return s
end

-- wuv u chatgptee
function OwoSpeak.owoify(text, stutterChance, emoticonChance)
    stutterChance = stutterChance or 0.15
    emoticonChance = emoticonChance or 0.4

    -- do not owo the winks
    text = SubstituteLinks(text)

    -- the -> da
    text = text:gsub("%f[%a]the%f[%A]", "da")
    text = text:gsub("%f[%a]The%f[%A]", "Da")

    -- love -> wuv
    text = text:gsub("%f[%a]love%f[%A]", "wuv")
    text = text:gsub("%f[%a]Love%f[%A]", "Wuv")

    -- consonant clusters
    local clusters = {
        {"na", "nya"}, {"Na", "Nya"},
        {"ne", "nye"}, {"Ne", "Nye"},
        {"ni", "nyi"}, {"Ni", "Nyi"},
        {"no", "nyo"}, {"No", "Nyo"},
        {"nu", "nyu"}, {"Nu", "Nyu"},
    }

    for _, rule in ipairs(clusters) do
        text = text:gsub(rule[1], rule[2])
    end

    -- consonant softening
    text = text:gsub("th", "d")
    text = text:gsub("Th", "D")

    -- consonant substitutions
    text = text:gsub("r", "w")
    text = text:gsub("l", "w")
    text = text:gsub("R", "W")
    text = text:gsub("L", "W")

    -- stutter
    text = text:gsub("(%f[%a])([A-Za-z])", function(boundary, letter)
        if random() < stutterChance then
            return boundary..letter.."-"..letter
        else
            return boundary..letter
        end
    end)

    -- exclamation
    text = text:gsub("!", "!!!")

    -- emoticons
    if math.random() < emoticonChance then
        text = text.." "..emoticons[random(#emoticons)]
    end

    text = text:gsub("#@#%d+", RestoreLinks)
    return text
end

local makeowo = C_ChatInfo.SendChatMessage

---@diagnostic disable-next-line: duplicate-set-field
C_ChatInfo.SendChatMessage = function(message, chatType, languageID, target)
    if OwoSpeak:shouldowo(chatType, target) then
        local owofied = OwoSpeak.owoify(message)
        if #owofied < 255 then
            message = owofied
        end
    end
    makeowo(message, chatType, languageID, target)
end
