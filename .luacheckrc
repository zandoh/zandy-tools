-- Luacheck configuration for ZandyTools (World of Warcraft retail addon)
-- WoW runs Lua 5.1 with Blizzard extensions to the standard library.

std = "lua51"
max_line_length = 120

exclude_files = {
	"ZandyTools/Libs/", -- vendored Ace3/LibStub, not ours to lint
	".release/",
}

ignore = {
	"212", -- unused argument (Ace3 handlers receive self/info/input we often don't need)
}

-- Globals this addon writes to
globals = {
	"StaticPopupDialogs",
}

read_globals = {
	-- Blizzard string library extensions
	string = { fields = { "join", "split", "trim" } },

	-- Libraries
	"LibStub",

	-- WoW C_ namespaces
	"C_AddOns",
	"C_ChallengeMode",
	"C_Container",
	"C_Item",
	"C_Timer",
	"EventUtil",

	-- WoW API functions
	"CompleteLFGRoleCheck",
	"CreateFrame",
	"GetInventoryItemLink",
	"GetLFGRoles",
	"GetMaxLevelForPlayerExpansion",
	"GetNumSpecializations",
	"GetSpecializationInfo",
	"SetLFGRoles",
	"StaticPopup_Show",
	"StaticPopupSpecial_Hide",
	"UnitAffectingCombat",
	"UnitLevel",
	"UnitSetRole",
	"hooksecurefunc",

	-- Frames and UI objects
	"CharacterFrame",
	"DEFAULT_CHAT_FRAME",
	"GameTooltip",
	"RolePollPopup",

	-- Constants
	"INVSLOT_BACK",
	"INVSLOT_CHEST",
	"INVSLOT_FEET",
	"INVSLOT_FINGER1",
	"INVSLOT_FINGER2",
	"INVSLOT_HEAD",
	"INVSLOT_LEGS",
	"INVSLOT_MAINHAND",
	"INVSLOT_NECK",
	"INVSLOT_OFFHAND",
	"INVSLOT_WAIST",
	"INVSLOT_WRIST",
	"NUM_BAG_SLOTS",
}
