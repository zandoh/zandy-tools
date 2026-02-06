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
