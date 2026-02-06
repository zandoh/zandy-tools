--[[
	Core/Init.lua

	Core initialization system for ZandyTools
	Handles addon namespace setup, version management, and core utilities
]]

local ADDON_NAME = "ZandyTools"

-- Create addon namespace
local ZandyTools = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")

-- Store reference globally
_G[ADDON_NAME] = ZandyTools

-- Core metadata
ZandyTools.Name = ADDON_NAME
ZandyTools.Version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "Dev"
ZandyTools.Author = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Author") or "Unknown"

-- Module storage (populated by ModuleRegistry.lua and ModuleLoader.lua)
ZandyTools.modules = {}

--[[
	Initialize the core addon
	Called by Ace3 when the addon is first loaded
]]
function ZandyTools:OnInitialize()
	self:Print("Initializing v" .. self.Version)

	-- Initialize database (will be loaded by Database.lua)
	self:InitializeDatabase()

	-- Register slash commands
	self:RegisterChatCommand("zandytools", "HandleSlashCommand")
	self:RegisterChatCommand("zt", "HandleSlashCommand")

	-- Set up default configuration
	self:SetupDefaultConfig()
end

--[[
	Enable the addon
	Called by Ace3 when PLAYER_LOGIN fires
]]
function ZandyTools:OnEnable()
	self:Print("Enabled. Type /zt for options.")

	-- Load enabled modules
	self:LoadEnabledModules()

	-- Fire custom event for modules that need to know when addon is ready
	self:SendMessage("ADDONSUITE_READY")
end

--[[
	Disable the addon
	Called when addon is being disabled
]]
function ZandyTools:OnDisable()
	-- Modules are disabled individually via UnloadModule
	for moduleName, module in pairs(self.modules) do
		if module.initialized then
			self:UnloadModule(moduleName)
		end
	end
end

--[[
	Handle slash commands
	@param input string - The command input
]]
function ZandyTools:HandleSlashCommand(input)
	self:OpenConfig()
end



--[[
	Print a message to chat with addon prefix

	@param ... any - Message parts to print
]]
function ZandyTools:Print(...)
	local message = string.join(" ", ...)
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[ZandyTools]|r " .. message)
end

--[[
	Print a debug message (only if debug mode is enabled)

	@param ... any - Message parts to print
]]
function ZandyTools:Debug(...)
	if self.db and self.db.global.debug then
		self:Print("|cffaaaaaa[DEBUG]|r", ...)
	end
end

--[[
	Print an error message

	@param ... any - Message parts to print
]]
function ZandyTools:Error(...)
	self:Print("|cffff0000[ERROR]|r", ...)
end

-- Return namespace for other files to use
return ZandyTools
