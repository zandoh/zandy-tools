--[[
	Main.lua

	Main entry point for ZandyTools
	This file is loaded last and performs final initialization
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

-- Verify addon loaded correctly
if not ZandyTools then
	error("ZandyTools failed to initialize properly!")
	return
end

--[[
	Perform final initialization tasks
	This runs after all core files and modules have been loaded
]]
local function FinalizeInitialization()
	-- All modules should be registered by now
	ZandyTools:Debug(string.format("Registered %d modules", #ZandyTools.moduleLoadOrder))

	-- Print module list if debug is enabled
	if ZandyTools.db and ZandyTools.db.global.debug then
		ZandyTools:Debug("Available modules:")
		for _, moduleName in ipairs(ZandyTools.moduleLoadOrder) do
			local module = ZandyTools.modules[moduleName]
			ZandyTools:Debug(string.format("  - %s v%s", module.displayName, module.version or "1.0.0"))
		end
	end
end

-- Register for PLAYER_LOGIN to do final initialization
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		FinalizeInitialization()
		self:UnregisterEvent("PLAYER_LOGIN")
	end
end)

-- Development helper: Expose addon table for debugging
if _G.SlashCmdList then
	-- Add a debug command to get addon info
	_G.SLASH_ZTDEBUG1 = "/ztdebug"
	_G.SlashCmdList["ZTDEBUG"] = function(msg)
		if msg == "reload" then
			ZandyTools:ReloadModules()
			ZandyTools:Print("Modules reloaded")
		elseif msg == "list" then
			ZandyTools:ListModules()
		elseif msg == "info" then
			local loaded = ZandyTools:GetLoadedModulesCount()
			local enabled = ZandyTools:GetEnabledModulesCount()
			local total = #ZandyTools.moduleLoadOrder
			ZandyTools:Print(string.format("Info: %d/%d enabled, %d loaded", enabled, total, loaded))
		else
			ZandyTools:Print("Debug commands:")
			ZandyTools:Print("  /ztdebug reload - Reload all modules")
			ZandyTools:Print("  /ztdebug list - List all modules")
			ZandyTools:Print("  /ztdebug info - Show module stats")
		end
	end
end

-- Success message
ZandyTools:Debug("Main.lua loaded successfully")
