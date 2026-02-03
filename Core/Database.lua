--[[
	Core/Database.lua

	Database management with AceDB
	Handles SavedVariables, profiles, and per-module settings storage
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

-- Default database structure
local defaults = {
	-- Profile-specific settings (per character/shared)
	profile = {
		-- Global addon settings
		minimap = {
			hide = false,
		},

		-- Module enabled states (profile-specific so different characters can use different modules)
		modules = {
			-- ["ModuleName"] = { enabled = true }
		},
	},

	-- Global settings (shared across all characters)
	global = {
		debug = false,
		version = ZandyTools.Version,

		-- Module-specific global data
		moduleData = {
			-- ["ModuleName"] = { ... }
		},
	},

	-- Character-specific settings
	char = {
		-- Module-specific character data
		moduleData = {
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

	-- Set up profile callbacks
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

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
	Refresh configuration
	Called when profile changes
]]
function ZandyTools:RefreshConfig()
	self:Print("Profile changed. Reloading configuration...")

	-- Reload all modules based on new profile
	self:ReloadModules()
end

--[[
	Get module settings from profile database

	@param moduleName string - Module identifier
	@return table - Module settings table
]]
function ZandyTools:GetModuleSettings(moduleName)
	if not self.db.profile.modules[moduleName] then
		self.db.profile.modules[moduleName] = {
			enabled = false,
		}
	end

	return self.db.profile.modules[moduleName]
end

--[[
	Get module global data

	@param moduleName string - Module identifier
	@return table - Module global data table
]]
function ZandyTools:GetModuleGlobalData(moduleName)
	if not self.db.global.moduleData[moduleName] then
		self.db.global.moduleData[moduleName] = {}
	end

	return self.db.global.moduleData[moduleName]
end

--[[
	Get module character data

	@param moduleName string - Module identifier
	@return table - Module character data table
]]
function ZandyTools:GetModuleCharData(moduleName)
	if not self.db.char.moduleData[moduleName] then
		self.db.char.moduleData[moduleName] = {}
	end

	return self.db.char.moduleData[moduleName]
end

--[[
	Check if a module is enabled in current profile

	@param moduleName string - Module identifier
	@return boolean
]]
function ZandyTools:IsModuleEnabled(moduleName)
	local settings = self:GetModuleSettings(moduleName)
	return settings.enabled == true
end

--[[
	Enable a module in current profile

	@param moduleName string - Module identifier
	@param skipLoad boolean - If true, don't load the module immediately
]]
function ZandyTools:EnableModule(moduleName, skipLoad)
	local module = self:GetModule(moduleName)
	if not module then
		self:Error(string.format("Cannot enable unknown module: %s", moduleName))
		return
	end

	local settings = self:GetModuleSettings(moduleName)
	settings.enabled = true

	if not skipLoad then
		self:LoadModule(moduleName)
	end
end

--[[
	Disable a module in current profile

	@param moduleName string - Module identifier
]]
function ZandyTools:DisableModule(moduleName)
	local module = self:GetModule(moduleName)
	if not module then
		self:Error(string.format("Cannot disable unknown module: %s", moduleName))
		return
	end

	local settings = self:GetModuleSettings(moduleName)
	settings.enabled = false

	if module.loaded then
		self:UnloadModule(moduleName)
	end
end

--[[
	Reset all settings to defaults
]]
function ZandyTools:ResetDatabase()
	self.db:ResetDB()
	self:Print("Database reset to defaults. Reloading UI recommended.")
	self:ReloadModules()
end

--[[
	Get the profile list for dropdown
	Used by Config.lua

	@return table - List of profile names
]]
function ZandyTools:GetProfiles()
	return self.db:GetProfiles()
end

--[[
	Set the active profile

	@param profileName string - Profile name to activate
]]
function ZandyTools:SetProfile(profileName)
	self.db:SetProfile(profileName)
end

--[[
	Get the current profile name

	@return string - Current profile name
]]
function ZandyTools:GetCurrentProfile()
	return self.db:GetCurrentProfile()
end

--[[
	Copy a profile

	@param sourceName string - Source profile name
]]
function ZandyTools:CopyProfile(sourceName)
	self.db:CopyProfile(sourceName)
end

--[[
	Delete a profile

	@param profileName string - Profile to delete
]]
function ZandyTools:DeleteProfile(profileName)
	self.db:DeleteProfile(profileName)
end

--[[
	Reset current profile to defaults
]]
function ZandyTools:ResetProfile()
	self.db:ResetProfile()
	self:Print("Profile reset to defaults.")
	self:ReloadModules()
end
