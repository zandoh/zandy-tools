--[[
	GearCheck.lua

	Displays visual indicators on the character panel when equipped gear
	is missing enchants, gems, or available sockets.
]]

local ADDON_NAME = "ZandyTools"
local ZandyTools = _G[ADDON_NAME]

local GearCheck = {
	displayName = "Gear Check",
	description = "Show missing enchants, gems, and sockets on the character panel",
	version = "1.0.0",
}

local ICON_PATH_ENCHANT = "Interface\\Icons\\Trade_Engraving"
local ICON_PATH_GEM     = "Interface\\Icons\\INV_Misc_Gem_Diamond_07"
local ICON_PATH_SOCKET  = "Interface\\Icons\\INV_Misc_Gem_01"

local INDICATOR_ICON_SIZE = 18
local SETTINGS_ICON_SIZE = 16

local function IconString(path, size)
	return "|T" .. path .. ":" .. size .. "|t"
end

local function IsWeapon(itemLink)
	if not itemLink then return false end
	local _, _, _, itemEquipLoc = C_Item.GetItemInfoInstant(itemLink)
	local weaponLocs = {
		INVTYPE_WEAPON = true,
		INVTYPE_2HWEAPON = true,
		INVTYPE_WEAPONMAINHAND = true,
		INVTYPE_WEAPONOFFHAND = true,
		INVTYPE_RANGED = true,
		INVTYPE_RANGEDRIGHT = true,
	}
	return weaponLocs[itemEquipLoc] or false
end

local SLOT_CONFIG = {
	{ slotID = INVSLOT_HEAD,      frameName = "CharacterHeadSlot",           enchantable = false, maxSockets = 1, side = "left" },
	{ slotID = INVSLOT_NECK,      frameName = "CharacterNeckSlot",           enchantable = false, maxSockets = 2, side = "left" },
	{ slotID = INVSLOT_BACK,      frameName = "CharacterBackSlot",           enchantable = true,  maxSockets = 0, side = "left" },
	{ slotID = INVSLOT_CHEST,     frameName = "CharacterChestSlot",          enchantable = true,  maxSockets = 0, side = "left" },
	{ slotID = INVSLOT_WRIST,     frameName = "CharacterWristSlot",          enchantable = true,  maxSockets = 1, side = "left" },
	{ slotID = INVSLOT_WAIST,     frameName = "CharacterWaistSlot",          enchantable = false, maxSockets = 1, side = "right" },
	{ slotID = INVSLOT_LEGS,      frameName = "CharacterLegsSlot",           enchantable = true,  maxSockets = 0, side = "right" },
	{ slotID = INVSLOT_FEET,      frameName = "CharacterFeetSlot",           enchantable = true,  maxSockets = 0, side = "right" },
	{ slotID = INVSLOT_FINGER1,   frameName = "CharacterFinger0Slot",        enchantable = true,  maxSockets = 2, side = "right" },
	{ slotID = INVSLOT_FINGER2,   frameName = "CharacterFinger1Slot",        enchantable = true,  maxSockets = 2, side = "right" },
	{ slotID = INVSLOT_MAINHAND,  frameName = "CharacterMainHandSlot",       enchantable = true,  maxSockets = 0, side = "bottom" },
	{ slotID = INVSLOT_OFFHAND,   frameName = "CharacterSecondaryHandSlot",  enchantable = true,  maxSockets = 0, side = "bottom",
		enchantCondition = function(itemLink) return IsWeapon(itemLink) end },
}

local SOCKET_STAT_KEYS = {
	"EMPTY_SOCKET_PRISMATIC",
	"EMPTY_SOCKET_RED",
	"EMPTY_SOCKET_YELLOW",
	"EMPTY_SOCKET_BLUE",
	"EMPTY_SOCKET_META",
	"EMPTY_SOCKET_SINGINGSEA",
	"EMPTY_SOCKET_SINGINGTHUNDER",
	"EMPTY_SOCKET_SINGINGWIND",
}

local function ParseItemLink(itemLink)
	if not itemLink then return nil end
	-- item:itemID:enchantID:gem1:gem2:gem3:gem4:...
	local fields = {}
	for field in itemLink:gmatch("item:([^|]+)") do
		for value in field:gmatch("([^:]*):?") do
			fields[#fields + 1] = value
		end
		break
	end
	return #fields > 0 and fields or nil
end

-- Check if an item is missing an enchant
-- fields index: 1=itemID, 2=enchantID, 3-6=gem IDs
local function IsMissingEnchant(itemLink, slotConfig)
	if not slotConfig.enchantable then return false end
	if slotConfig.enchantCondition and not slotConfig.enchantCondition(itemLink) then
		return false
	end
	local fields = ParseItemLink(itemLink)
	if not fields then return false end
	local enchantID = fields[2]
	return not enchantID or enchantID == "" or enchantID == "0"
end

local function CountGems(itemLink)
	local fields = ParseItemLink(itemLink)
	if not fields then return 0 end
	local count = 0
	for i = 3, 6 do
		local gemID = fields[i]
		if gemID and gemID ~= "" and gemID ~= "0" then
			count = count + 1
		end
	end
	return count
end

local function CountSockets(itemLink)
	if not itemLink then return 0 end
	local stats = C_Item.GetItemStats(itemLink)
	if not stats then
		-- Fallback: assume socket count equals gem count (no false positive)
		return CountGems(itemLink)
	end
	local count = 0
	for _, key in ipairs(SOCKET_STAT_KEYS) do
		count = count + (stats[key] or 0)
	end
	return count
end

-- Check a single slot and return issues (or nil if all good / skipped)
local function CheckSlot(slotID, slotConfig, settings)
	-- Skip checks if player is below minimum level
	if UnitLevel("player") < settings.minLevel then return nil end

	local itemLink = GetInventoryItemLink("player", slotID)
	if not itemLink then return nil end

	local result = nil

	-- Enchant check
	if settings.checkEnchants and IsMissingEnchant(itemLink, slotConfig) then
		result = result or {}
		result.missingEnchant = true
	end

	-- Socket checks (gems + available sockets)
	local totalSockets = CountSockets(itemLink)
	local filledGems = CountGems(itemLink)
	local emptyGems = totalSockets - filledGems

	if settings.checkGems and emptyGems > 0 then
		result = result or {}
		result.emptyGems = true
	end

	if settings.checkSockets and slotConfig.maxSockets > 0 and totalSockets < slotConfig.maxSockets then
		result = result or {}
		result.missingSockets = true
	end

	return result
end

local ICON_GAP = 2

local function CreateIndicator(parent, side)
	local iconSize = INDICATOR_ICON_SIZE
	local maxIcons = 3
	local totalWidth = (maxIcons * iconSize) + ((maxIcons - 1) * ICON_GAP)

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(totalWidth, iconSize)
	frame:SetFrameLevel(parent:GetFrameLevel() + 5)
	frame.side = side

	if side == "left" then
		frame:SetPoint("LEFT", parent, "RIGHT", 12, 0)
	elseif side == "right" then
		frame:SetPoint("RIGHT", parent, "LEFT", -12, 0)
	else -- bottom (weapons)
		frame:SetPoint("BOTTOM", parent, "TOP", 0, 12)
	end

	-- Pre-create 3 reusable texture slots
	frame.iconTextures = {}
	for i = 1, maxIcons do
		local tex = frame:CreateTexture(nil, "OVERLAY")
		tex:SetSize(iconSize, iconSize)
		tex:Hide()
		frame.iconTextures[i] = tex
	end

	-- Tooltip support
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Gear Check", 1, 0.82, 0)
		if self.tooltipLines then
			for _, line in ipairs(self.tooltipLines) do
				GameTooltip:AddLine(line, 1, 1, 1, true)
			end
		end
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	frame:Hide()
	return frame
end

function GearCheck:Initialize()
	self.db = ZandyTools:GetModuleSettings(self.name)

	-- Set defaults
	if self.db.checkEnchants == nil then self.db.checkEnchants = true end
	if self.db.checkGems == nil then self.db.checkGems = true end
	if self.db.checkSockets == nil then self.db.checkSockets = true end
	if self.db.minLevel == nil then self.db.minLevel = 70 end

	self.indicators = {}
	self.hooked = false
end

function GearCheck:CreateIndicators()
	if self.indicatorsCreated then return end

	for _, slotConfig in ipairs(SLOT_CONFIG) do
		local button = _G[slotConfig.frameName]
		if button then
			self.indicators[slotConfig.slotID] = CreateIndicator(button, slotConfig.side)
		end
	end

	self.indicatorsCreated = true
end

function GearCheck:UpdateSlot(slotConfig)
	local indicator = self.indicators[slotConfig.slotID]
	if not indicator then return end

	local issues = CheckSlot(slotConfig.slotID, slotConfig, self.db)

	-- Hide all icon textures first
	for _, tex in ipairs(indicator.iconTextures) do
		tex:Hide()
		tex:ClearAllPoints()
	end

	if not issues then
		indicator:Hide()
		return
	end

	-- Collect visible icons in order (enchant, gem, socket)
	local visibleIcons = {}
	local tooltipLines = {}

	if issues.missingEnchant then
		visibleIcons[#visibleIcons + 1] = ICON_PATH_ENCHANT
		tooltipLines[#tooltipLines + 1] = "Missing enchant"
	end
	if issues.emptyGems then
		visibleIcons[#visibleIcons + 1] = ICON_PATH_GEM
		tooltipLines[#tooltipLines + 1] = "Empty gem socket(s)"
	end
	if issues.missingSockets then
		visibleIcons[#visibleIcons + 1] = ICON_PATH_SOCKET
		tooltipLines[#tooltipLines + 1] = "Socket(s) can be added"
	end

	-- Position icons packed from the slot outward
	local iconSize = INDICATOR_ICON_SIZE
	local side = indicator.side

	for i, path in ipairs(visibleIcons) do
		local tex = indicator.iconTextures[i]
		tex:SetTexture(path)
		local offset = (i - 1) * (iconSize + ICON_GAP)

		if side == "right" then
			-- Pack right-to-left: first icon closest to slot (rightmost)
			tex:SetPoint("RIGHT", indicator, "RIGHT", -offset, 0)
		elseif side == "left" then
			-- Pack left-to-right: first icon closest to slot (leftmost)
			tex:SetPoint("LEFT", indicator, "LEFT", offset, 0)
		else -- bottom
			-- Center: pack left-to-right from center
			local totalWidth = (#visibleIcons * iconSize) + ((#visibleIcons - 1) * ICON_GAP)
			local startX = -totalWidth / 2
			tex:SetPoint("LEFT", indicator, "CENTER", startX + offset, 0)
		end

		tex:Show()
	end

	indicator.tooltipLines = tooltipLines
	indicator:Show()
end

function GearCheck:UpdateAllSlots()
	if not self.indicatorsCreated then return end
	for _, slotConfig in ipairs(SLOT_CONFIG) do
		self:UpdateSlot(slotConfig)
	end
end

function GearCheck:HideAllIndicators()
	for _, indicator in pairs(self.indicators) do
		indicator:Hide()
	end
end

-- Hook CharacterFrame show/hide. Deferred until CharacterFrame exists
-- because it is a LoadOnDemand addon (Blizzard_CharacterFrame).
function GearCheck:HookCharacterFrame()
	if self.hooked then return end
	if not CharacterFrame then return end

	hooksecurefunc(CharacterFrame, "Show", function()
		if not self.enabled then return end
		self:CreateIndicators()
		self:UpdateAllSlots()
	end)

	CharacterFrame:HookScript("OnHide", function()
		if not self.enabled then return end
		self:HideAllIndicators()
	end)

	self.hooked = true

	-- If character frame is already shown, update now
	if CharacterFrame:IsShown() then
		self:CreateIndicators()
		self:UpdateAllSlots()
	end
end

function GearCheck:Enable()
	ZandyTools.RegisterEvent(self, "PLAYER_EQUIPMENT_CHANGED", "OnEquipmentChanged")
	ZandyTools.RegisterEvent(self, "SOCKET_INFO_UPDATE", "OnSocketUpdate")
	ZandyTools.RegisterEvent(self, "BAG_UPDATE_DELAYED", "OnBagUpdate")

	-- CharacterFrame is LoadOnDemand; hook now if available, otherwise wait
	if CharacterFrame then
		self:HookCharacterFrame()
	else
		EventUtil.ContinueOnAddOnLoaded("Blizzard_CharacterFrame", function()
			self:HookCharacterFrame()
		end)
	end
end

function GearCheck:Disable()
	ZandyTools.UnregisterAllEvents(self)
	self:HideAllIndicators()
end

function GearCheck:OnEquipmentChanged()
	if CharacterFrame and CharacterFrame:IsShown() then
		self:UpdateAllSlots()
	end
end

function GearCheck:OnSocketUpdate()
	if CharacterFrame and CharacterFrame:IsShown() then
		self:UpdateAllSlots()
	end
end

function GearCheck:OnBagUpdate()
	if CharacterFrame and CharacterFrame:IsShown() then
		self:UpdateAllSlots()
	end
end

function GearCheck:GetOptions()
	return {
		type = "group",
		name = self.displayName,
		args = {
			checkEnchants = {
				type = "toggle",
				name = IconString(ICON_PATH_ENCHANT, SETTINGS_ICON_SIZE) .. " Enchants",
				desc = "Show missing enchant warnings",
				order = 1,
				get = function() return self.db.checkEnchants end,
				set = function(_, value)
					self.db.checkEnchants = value
					if CharacterFrame and CharacterFrame:IsShown() then self:UpdateAllSlots() end
				end,
			},
			checkGems = {
				type = "toggle",
				name = IconString(ICON_PATH_GEM, SETTINGS_ICON_SIZE) .. " Gems",
				desc = "Show empty gem socket warnings",
				order = 2,
				get = function() return self.db.checkGems end,
				set = function(_, value)
					self.db.checkGems = value
					if CharacterFrame and CharacterFrame:IsShown() then self:UpdateAllSlots() end
				end,
			},
			checkSockets = {
				type = "toggle",
				name = IconString(ICON_PATH_SOCKET, SETTINGS_ICON_SIZE) .. " Sockets",
				desc = "Show warnings when sockets can be added",
				order = 3,
				get = function() return self.db.checkSockets end,
				set = function(_, value)
					self.db.checkSockets = value
					if CharacterFrame and CharacterFrame:IsShown() then self:UpdateAllSlots() end
				end,
			},
			minLevel = {
				type = "range",
				name = "Minimum Character Level",
				desc = "Only check gear on characters at or above this level",
				order = 4,
				min = 1,
				max = GetMaxLevelForPlayerExpansion(),
				step = 1,
				width = "full",
				get = function() return self.db.minLevel end,
				set = function(_, value)
					self.db.minLevel = value
					if CharacterFrame and CharacterFrame:IsShown() then self:UpdateAllSlots() end
				end,
			},
		},
	}
end

ZandyTools:RegisterModule("GearCheck", GearCheck)
