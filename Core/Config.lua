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
			-- General settings tab
			general = {
				type = "group",
				name = "General",
				order = 1,
				args = {
					header = {
						type = "description",
						name = "|cff00ccffZandyTools|r v" .. ZandyTools.Version .. "\n" ..
							   "A modular suite of tools for World of Warcraft\n\n" ..
							   "Enable or disable individual modules below.",
						fontSize = "medium",
						order = 1,
					},
					spacer1 = {
						type = "description",
						name = " ",
						order = 2,
					},
					debug = {
						type = "toggle",
						name = "Debug Mode",
						desc = "Enable debug messages in chat",
						order = 3,
						width = "full",
						get = function()
							return ZandyTools.db.global.debug
						end,
						set = function(info, value)
							ZandyTools.db.global.debug = value
							if value then
								ZandyTools:Print("Debug mode enabled")
							else
								ZandyTools:Print("Debug mode disabled")
							end
						end,
					},
					reload = {
						type = "execute",
						name = "Reload All Modules",
						desc = "Reload all enabled modules (useful after changing settings)",
						order = 4,
						width = "normal",
						func = function()
							ZandyTools:ReloadModules()
							ZandyTools:Print("All modules reloaded")
						end,
					},
				},
			},

			-- Modules tab
			modules = {
				type = "group",
				name = "Modules",
				order = 2,
				args = {
					header = {
						type = "description",
						name = "Enable or disable individual modules.\n" ..
							   "Changes take effect immediately.\n",
						fontSize = "medium",
						order = 1,
					},
					spacer1 = {
						type = "description",
						name = " ",
						order = 2,
					},
				},
			},

			-- Profiles tab
			profiles = {
				type = "group",
				name = "Profiles",
				order = 100,
				args = {}, -- Will be filled by AceDBOptions
			},
		},
	}

	-- Add module toggles dynamically
	local moduleOrder = 10
	for _, moduleName in ipairs(ZandyTools.moduleLoadOrder) do
		local module = ZandyTools.modules[moduleName]

		options.args.modules.args[moduleName] = {
			type = "group",
			name = module.displayName,
			order = moduleOrder,
			inline = true,
			args = {
				enabled = {
					type = "toggle",
					name = "Enable " .. module.displayName,
					desc = module.description or "No description available",
					order = 1,
					width = "full",
					get = function()
						return ZandyTools:IsModuleEnabled(moduleName)
					end,
					set = function(info, value)
						if value then
							ZandyTools:EnableModule(moduleName)
							ZandyTools:Print(string.format("Enabled module: %s", module.displayName))
						else
							ZandyTools:DisableModule(moduleName)
							ZandyTools:Print(string.format("Disabled module: %s", module.displayName))
						end
					end,
				},
				status = {
					type = "description",
					name = function()
						local status = "Status: "
						if module.loaded then
							status = status .. "|cff00ff00Loaded|r"
						else
							status = status .. "|cffaaaaaaNot loaded|r"
						end
						return status
					end,
					order = 2,
				},
			},
		}

		-- Add module-specific options if they exist
		if module.GetOptions and type(module.GetOptions) == "function" then
			local moduleOptions = module:GetOptions()
			if moduleOptions and moduleOptions.args then
				-- Add a spacer
				options.args.modules.args[moduleName].args.spacer = {
					type = "description",
					name = " ",
					order = 3,
				}

				-- Add module options
				local optionOrder = 10
				for optionKey, optionValue in pairs(moduleOptions.args) do
					optionValue.order = optionOrder
					optionValue.disabled = function()
						return not ZandyTools:IsModuleEnabled(moduleName)
					end
					options.args.modules.args[moduleName].args[optionKey] = optionValue
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
	-- Register options table
	AceConfig:RegisterOptionsTable(ADDON_NAME, GetOptionsTable)

	-- Add profiles support
	local AceDBOptions = LibStub("AceDBOptions-3.0")
	local profileOptions = AceDBOptions:GetOptionsTable(self.db)
	AceConfig:RegisterOptionsTable(ADDON_NAME .. "Profiles", profileOptions)

	-- Create config dialog
	self.configDialog = AceConfigDialog:AddToBlizOptions(ADDON_NAME, "ZandyTools")
	AceConfigDialog:AddToBlizOptions(ADDON_NAME .. "Profiles", "Profiles", "ZandyTools")

	self:Debug("Configuration UI initialized")
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
