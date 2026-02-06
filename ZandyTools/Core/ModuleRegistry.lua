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
}

-- Track which modules have been loaded
ZandyTools.loadedModules = {}
