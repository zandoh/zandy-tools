--[[
	Core/Database.lua

	Database management with AceDB
	Handles SavedVariables, profiles, and per-module settings storage
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

-- Default database structure
local defaults = {
	-- Global settings (shared across all characters/account-wide)
	global = {
		version = ZandyTools.Version,

		-- Module enabled states (account-wide)
		modules = {
			-- ["ModuleName"] = true/false
		},
	},

	-- Character-specific settings
	char = {
		-- Module-specific settings (per-character)
		moduleSettings = {
			-- ["ModuleName"] = { ... }
		},
	},
}

--[[
	Initialize the database
	Called from Init.lua during OnInitialize
]]
function ZandyTools:InitializeDatabase()
	-- Create database using AceDB
	self.db = LibStub("AceDB-3.0"):New("ZandyToolsDB", defaults, true)

	-- Perform version migration if needed
	self:MigrateDatabase()
end

--[[
	Migrate database from older versions

	This function handles any necessary data structure changes between versions
]]
function ZandyTools:MigrateDatabase()
	local dbVersion = self.db.global.version
	local currentVersion = self.Version

	if dbVersion == currentVersion then
		return
	end

	self:Print(string.format("Migrating database from %s to %s", dbVersion or "Unknown", currentVersion))

	-- Perform migrations here as needed
	-- Example:
	-- if not dbVersion or dbVersion < "1.0.0" then
	--     -- Migrate to 1.0.0 structure
	-- end

	-- Update version
	self.db.global.version = currentVersion
end

--[[
	Get module settings (per-character)

	@param moduleName string - Module identifier
	@return table - Module settings table
]]
function ZandyTools:GetModuleSettings(moduleName)
	if not self.db.char.moduleSettings[moduleName] then
		self.db.char.moduleSettings[moduleName] = {}
	end
	return self.db.char.moduleSettings[moduleName]
end

--[[
	Check if a module is enabled (account-wide)

	@param moduleName string - Module identifier
	@return boolean
]]
function ZandyTools:IsModuleEnabled(moduleName)
	return self.db.global.modules[moduleName] == true
end

--[[
	Enable a module (account-wide)

	@param moduleName string - Module identifier
]]
function ZandyTools:EnableModule(moduleName)
	self.db.global.modules[moduleName] = true
	self:LoadModule(moduleName)
end

--[[
	Disable a module (account-wide)

	@param moduleName string - Module identifier
]]
function ZandyTools:DisableModule(moduleName)
	self.db.global.modules[moduleName] = false
	self:UnloadModule(moduleName)
end
