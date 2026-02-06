--[[
	Core/Config.lua

	AceConfig UI implementation
	Handles configuration interface with module toggles and settings
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--[[
	Build the configuration options table
	This is called dynamically to include all registered modules

	@return table - AceConfig options table
]]
local function GetOptionsTable()
	local options = {
		type = "group",
		name = "ZandyTools",
		args = {
			header = {
				type = "description",
				name = "|cff00ccffZandyTools|r v" .. ZandyTools.Version .. "\n" ..
					   "A modular suite of tools\n",
				fontSize = "medium",
				order = 1,
			},
		},
	}

	-- Add module toggles from registry
	local moduleOrder = 10
	for moduleName, registry in pairs(ZandyTools.moduleRegistry) do
		local module = ZandyTools.modules[moduleName]
		local displayName = module and module.displayName or registry.displayName
		local description = module and module.description or registry.description

		options.args[moduleName] = {
			type = "group",
			name = displayName,
			order = moduleOrder,
			inline = true,
			args = {
				enabled = {
					type = "toggle",
					name = "Enable " .. displayName,
					desc = description or "No description available",
					order = 1,
					width = "full",
					get = function()
						return ZandyTools:IsModuleEnabled(moduleName)
					end,
					set = function(info, value)
						if value then
							ZandyTools:EnableModule(moduleName)
						else
							ZandyTools:DisableModule(moduleName)
						end
					end,
				},
			},
		}

		-- Add module-specific options if module is loaded
		if module and module.GetOptions and type(module.GetOptions) == "function" then
			local moduleOptions = module:GetOptions()
			if moduleOptions and moduleOptions.args then
				local optionOrder = 10
				for optionKey, optionValue in pairs(moduleOptions.args) do
					optionValue.order = optionOrder
					optionValue.disabled = function()
						return not ZandyTools:IsModuleEnabled(moduleName)
					end
					options.args[moduleName].args[optionKey] = optionValue
					optionOrder = optionOrder + 1
				end
			end
		end

		moduleOrder = moduleOrder + 1
	end

	return options
end

--[[
	Initialize the configuration UI
	Called after all modules are registered
]]
function ZandyTools:InitializeConfig()
	AceConfig:RegisterOptionsTable(ADDON_NAME, GetOptionsTable)
	self.configDialog = AceConfigDialog:AddToBlizOptions(ADDON_NAME, "ZandyTools")
end

--[[
	Open the configuration UI
]]
function ZandyTools:OpenConfig()
	-- Ensure config is initialized
	if not self.configDialog then
		self:InitializeConfig()
	end

	-- Open the configuration dialog
	AceConfigDialog:Open(ADDON_NAME)
end

--[[
	Close the configuration UI
]]
function ZandyTools:CloseConfig()
	AceConfigDialog:Close(ADDON_NAME)
end

--[[
	Refresh the configuration UI
	Used when module states change
]]
function ZandyTools:RefreshConfigUI()
	-- Re-register the options table to pick up any changes
	AceConfig:RegisterOptionsTable(ADDON_NAME, GetOptionsTable)
end

-- Setup default config (called from Init.lua)
-- This is now handled dynamically in GetOptionsTable
function ZandyTools:SetupDefaultConfig()
	-- Initialize config after a short delay to ensure all modules are registered
	C_Timer.After(0.1, function()
		self:InitializeConfig()
	end)
end
