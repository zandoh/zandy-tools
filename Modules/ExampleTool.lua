--[[
	Modules/ExampleTool.lua

	A basic example module template showing the minimal implementation pattern.
	Use this as a starting point for creating new modules.
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

-- Create module table
local ExampleTool = {
	-- Module metadata
	displayName = "Example Tool",
	description = "A basic example module demonstrating the module template",
	version = "1.0.0",

	-- Dependencies (if any)
	dependencies = {}, -- e.g., {"OtherModuleName"}
}

--[[
	Initialize the module
	Called once when the module is first loaded
	Use this to set up initial state, defaults, etc.
]]
function ExampleTool:Initialize()
	-- Get module settings storage
	self.db = ZandyTools:GetModuleSettings(self.name)

	-- Set up default settings if they don't exist
	if self.db.exampleSetting == nil then
		self.db.exampleSetting = true
	end

	ZandyTools:Debug(string.format("%s initialized", self.displayName))
end

--[[
	Enable the module
	Called when the module is enabled (either at startup or when user enables it)
	Register events, hook functions, create frames, etc.
]]
function ExampleTool:Enable()
	-- Register events
	ZandyTools.RegisterEvent(self, "PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")

	-- Print activation message
	ZandyTools:Print(string.format("%s is now active", self.displayName))
end

--[[
	Disable the module
	Called when the module is being disabled
	Unregister events, unhook functions, hide frames, etc.
]]
function ExampleTool:Disable()
	-- Unregister all events
	ZandyTools.UnregisterAllEvents(self)

	ZandyTools:Debug(string.format("%s disabled", self.displayName))
end

--[[
	Cleanup the module
	Called when the module is being unloaded completely
	Release resources, clear references, etc.
]]
function ExampleTool:Cleanup()
	-- Clean up any resources
	self.db = nil

	ZandyTools:Debug(string.format("%s cleaned up", self.displayName))
end

--[[
	Event handler: PLAYER_ENTERING_WORLD
	Example event handler
]]
function ExampleTool:OnPlayerEnteringWorld(event, isInitialLogin, isReloadingUI)
	if isInitialLogin then
		ZandyTools:Debug("Player logged in for the first time this session")
	elseif isReloadingUI then
		ZandyTools:Debug("UI was reloaded")
	end
end

--[[
	Get configuration options for this module
	This is called by Config.lua to build the options UI

	@return table - AceConfig options table
]]
function ExampleTool:GetOptions()
	return {
		type = "group",
		name = self.displayName,
		args = {
			exampleSetting = {
				type = "toggle",
				name = "Example Setting",
				desc = "This is an example setting that doesn't do anything",
				get = function()
					return self.db.exampleSetting
				end,
				set = function(info, value)
					self.db.exampleSetting = value
					ZandyTools:Print(string.format("Example setting changed to: %s", tostring(value)))
				end,
			},
			exampleButton = {
				type = "execute",
				name = "Test Button",
				desc = "Click to test the module",
				func = function()
					ZandyTools:Print("Example Tool button clicked!")
				end,
			},
		},
	}
end

-- Register this module with ZandyTools
ZandyTools:RegisterModule("ExampleTool", ExampleTool)
