--[[
	Core/ModuleRegistry.lua

	Registry of available lazy-loaded modules.
	Each module is a separate addon with LoadOnDemand: 1
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

-- Module definitions (metadata for modules that haven't been loaded yet)
ZandyTools.moduleRegistry = {
	RoleCheck = {
		addonName = "ZandyTools_RoleCheck",
		displayName = "Auto Role Check",
		description = "Automatically respond to role checks with your preferred role",
	},
	KeystoneReminder = {
		addonName = "ZandyTools_KeystoneReminder",
		displayName = "Keystone Reminder",
		description = "Remind you to check your keystone after completing a Mythic+ dungeon",
	},
	GearCheck = {
		addonName = "ZandyTools_GearCheck",
		displayName = "Gear Check",
		description = "Show missing enchants, gems, and sockets on the character panel",
	},
}

-- Track which modules have been loaded
ZandyTools.loadedModules = {}
