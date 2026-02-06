--[[
	Modules/RoleCheck.lua

	Automatically responds to group role checks with pre-configured roles.
	Useful for hybrid classes that want to consistently sign up for specific roles.
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

local RoleCheck = {
	displayName = "Auto Role Check",
	description = "Automatically respond to role checks with your preferred roles",
	version = "1.0.0",
}

function RoleCheck:Initialize()
	self.db = ZandyTools:GetModuleSettings(self.name)

	-- Initialize role settings if not present
	if self.db.roles == nil then
		self.db.roles = {
			TANK = false,
			HEALER = false,
			DAMAGER = false,
		}
	end
end

function RoleCheck:Enable()
	ZandyTools.RegisterEvent(self, "ROLE_POLL_BEGIN", "OnRolePollBegin")
end

function RoleCheck:Disable()
	ZandyTools.UnregisterAllEvents(self)
end

function RoleCheck:OnRolePollBegin()
	if UnitAffectingCombat("player") then
		ZandyTools:Print("Cannot set role while in combat")
		return
	end

	local rolesSet = {}
	for role, enabled in pairs(self.db.roles) do
		if enabled then
			UnitSetRole("player", role)
			table.insert(rolesSet, role)
		end
	end
end

function RoleCheck:GetAvailableRoles()
	local roles = {
		TANK = false,
		HEALER = false,
		DAMAGER = false,
	}

	for i = 1, GetNumSpecializations() do
		local _, _, _, _, role = GetSpecializationInfo(i)
		if role then
			roles[role] = true
		end
	end

	return roles
end

function RoleCheck:GetOptions()
	-- Texture escape sequences for role icons
	local tankIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t"
	local healerIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t"
	local damagerIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t"

	return {
		type = "group",
		name = self.displayName,
		args = {
			tank = {
				type = "toggle",
				name = tankIcon .. " Tank",
				desc = "Sign up as Tank",
				order = 1,
				hidden = function()
					return not RoleCheck:GetAvailableRoles().TANK
				end,
				get = function()
					return self.db and self.db.roles and self.db.roles.TANK
				end,
				set = function(info, value)
					if self.db and self.db.roles then
						self.db.roles.TANK = value
					end
				end,
			},
			healer = {
				type = "toggle",
				name = healerIcon .. " Healer",
				desc = "Sign up as Healer",
				order = 2,
				hidden = function()
					return not RoleCheck:GetAvailableRoles().HEALER
				end,
				get = function()
					return self.db and self.db.roles and self.db.roles.HEALER
				end,
				set = function(info, value)
					if self.db and self.db.roles then
						self.db.roles.HEALER = value
					end
				end,
			},
			damager = {
				type = "toggle",
				name = damagerIcon .. " Damage",
				desc = "Sign up as Damage",
				order = 3,
				hidden = function()
					return not RoleCheck:GetAvailableRoles().DAMAGER
				end,
				get = function()
					return self.db and self.db.roles and self.db.roles.DAMAGER
				end,
				set = function(info, value)
					if self.db and self.db.roles then
						self.db.roles.DAMAGER = value
					end
				end,
			},
		},
	}
end

ZandyTools:RegisterModule("RoleCheck", RoleCheck)
