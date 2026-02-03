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

-- Module registry
ZandyTools.modules = {}
ZandyTools.moduleLoadOrder = {}

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
	self:Print("Enabled. Type /zt or /zandytools for options.")

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
	-- Disable all active modules
	self:DisableAllModules()
end

--[[
	Handle slash commands
	@param input string - The command input
]]
function ZandyTools:HandleSlashCommand(input)
	input = input:trim():lower()

	if input == "" or input == "config" or input == "options" then
		-- Open configuration UI
		self:OpenConfig()
	elseif input == "version" or input == "v" then
		-- Display version information
		self:Print(string.format("Version %s by %s", self.Version, self.Author))
	elseif input == "modules" or input == "list" then
		-- List all registered modules
		self:ListModules()
	elseif input == "help" or input == "?" then
		-- Display help
		self:ShowHelp()
	else
		self:Print("Unknown command. Type '/zt help' for available commands.")
	end
end

--[[
	Show help information
]]
function ZandyTools:ShowHelp()
	self:Print("Available commands:")
	self:Print("  /zt config - Open configuration")
	self:Print("  /zt version - Show version info")
	self:Print("  /zt modules - List all modules")
	self:Print("  /zt help - Show this help")
end

--[[
	List all registered modules
]]
function ZandyTools:ListModules()
	self:Print("Registered Modules:")

	if #self.moduleLoadOrder == 0 then
		self:Print("  No modules registered yet.")
		return
	end

	for _, moduleName in ipairs(self.moduleLoadOrder) do
		local module = self.modules[moduleName]
		local status = module.enabled and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"
		local loaded = module.loaded and " (Loaded)" or ""
		self:Print(string.format("  %s - %s%s", moduleName, status, loaded))
	end
end

--[[
	Register a new module with the addon
	This is called by individual module files

	@param moduleName string - Unique module identifier
	@param moduleTable table - Module implementation
	@return table - The registered module
]]
function ZandyTools:RegisterModule(moduleName, moduleTable)
	if not moduleName or type(moduleName) ~= "string" then
		error("Module name must be a non-empty string")
	end

	if self.modules[moduleName] then
		error(string.format("Module '%s' is already registered", moduleName))
	end

	-- Set up module structure
	local module = moduleTable or {}
	module.name = moduleName
	module.displayName = module.displayName or moduleName
	module.description = module.description or "No description provided"
	module.enabled = false
	module.loaded = false
	module.dependencies = module.dependencies or {}

	-- Store module
	self.modules[moduleName] = module
	table.insert(self.moduleLoadOrder, moduleName)

	-- Debug output
	if self.db and self.db.global.debug then
		self:Print(string.format("Registered module: %s", moduleName))
	end

	return module
end

--[[
	Get a registered module by name

	@param moduleName string - Module identifier
	@return table|nil - The module or nil if not found
]]
function ZandyTools:GetModule(moduleName)
	return self.modules[moduleName]
end

--[[
	Check if a module exists

	@param moduleName string - Module identifier
	@return boolean
]]
function ZandyTools:HasModule(moduleName)
	return self.modules[moduleName] ~= nil
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
