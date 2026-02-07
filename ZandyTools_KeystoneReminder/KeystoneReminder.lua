--[[
	KeystoneReminder.lua

	Shows a reminder after completing a Mythic+ dungeon with your current
	keystone info, so you don't forget to change it before your next run.
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

local KeystoneReminder = {
	displayName = "Keystone Reminder",
	description = "Remind you to check your keystone after completing a Mythic+ dungeon",
	version = "1.0.0",
}

StaticPopupDialogs["ZANDYTOOLS_KEYSTONE_REMINDER"] = {
	text = "Your keystone is:\n\n|cffff8000%s|r\n\nDon't forget to change it if you don't want this key!",
	button1 = "Got it",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function KeystoneReminder:Initialize()
	self.db = ZandyTools:GetModuleSettings(self.name)
end

function KeystoneReminder:Enable()
	ZandyTools.RegisterEvent(self, "CHALLENGE_MODE_COMPLETED", "OnChallengeModeCompleted")
end

function KeystoneReminder:Disable()
	ZandyTools.UnregisterAllEvents(self)
end

function KeystoneReminder:OnChallengeModeCompleted()
	-- Delay to allow the keystone to update in bags
	C_Timer.After(2, function()
		self:ShowReminder()
	end)
end

local KEYSTONE_ITEM_ID = 180653

function KeystoneReminder:GetKeystoneInfo()
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.itemID == KEYSTONE_ITEM_ID then
				local link = C_Container.GetContainerItemLink(bag, slot)
				if link then
					local mapID, level = link:match("keystone:%d+:(%d+):(%d+)")
					if mapID and level then
						local name = C_ChallengeMode.GetMapUIInfo(tonumber(mapID))
						return tonumber(level), name
					end
				end
			end
		end
	end
	return nil, nil
end

function KeystoneReminder:ShowReminder()
	local level, name = self:GetKeystoneInfo()
	if not level then
		return
	end

	local keystoneText = string.format("+%d %s", level, name or "Unknown")
	StaticPopup_Show("ZANDYTOOLS_KEYSTONE_REMINDER", keystoneText)
end

function KeystoneReminder:GetOptions()
	return {
		type = "group",
		name = self.displayName,
		args = {},
	}
end

ZandyTools:RegisterModule("KeystoneReminder", KeystoneReminder)
