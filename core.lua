local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = LibStub("AceAddon-3.0"):NewAddon("kLoot", "AceComm-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceTimer-3.0")
_G.kLoot = kLoot

--[[
Roles	
	Administrator -- Group Leader, acts as "server" for all high-level data confirmation
	Editor -- Any person able to "edit" basic data (assign auction winners, create auctions, etc.)
	IsRole(role='administrator',name='player')
	GetRole(name='player') -- Get current role
	SetRole(role,name='player')
	IsAdmin(player='player')
	IsEditor(player='player')
Raid management
	Start raid
	End raid
	IsRaidActive()
	SetRaidStatus()
	ToggleRaidStatus()
	
/slash commands
	auction [item]
	bid [item] [item] OR 
	
]]

function kLoot:OnEnable() end
function kLoot:OnDisable() end
function kLoot:OnInitialize()
    -- Load Database
    self.db = LibStub("AceDB-3.0"):New("kLootDB", self.defaults)
	-- Init Settings
	self:InitializeSettings()	
	-- Create defaults
	self:Options_Default()	
    -- Inject Options Table and Slash Commands
	-- Create options		
	self:Options_Generate()	
	self.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.config = LibStub("AceConfig-3.0"):RegisterOptionsTable("kLoot", self.options, {"kloot", "kl"})
	self.dialog = LibStub("AceConfigDialog-3.0")
	self.AceGUI = LibStub("AceGUI-3.0")
	-- Init Events
	self:InitializeEvents()
	self.updateFrame = CreateFrame("Frame", "kLootUpdateFrame", UIParent);
	kLootUpdateFrame:SetScript("OnUpdate", function(self, elapsed) 
		kLoot:Auction_OnUpdate(elapsed)
		kLoot:OnUpdate(elapsed)
	end)
	self:InitializeTimers()
end

function kLoot:InitializeSettings()
	-- Version
	self.minRequiredVersion = '0.0.100'
	self.version = '0.0.100'	

	self.autoLootZoneSelected = 1
	self.autoLootWhitelistItemSelected = 1
	self.auctions = {}
	self.bidTypes = {
		mainspec = 'Mainspec',
		offspec = 'Offspec',
		rot = 'Rot',
	}
	self.color = {
		red = {r=1, g=0, b=0},
		green = {r=0, g=1, b=0},
		blue = {r=0, g=0, b=1},
		purple = {r=1, g=0, b=1},
		yellow = {r=1, g=1, b=0},
	}	
	self.itemSlotData = {
		{equipLocation = "INVTYPE_AMMO", slotName = "AmmoSlot", slotNumber = 0, formattedName = "Ammo",},
		{equipLocation = "INVTYPE_HEAD", slotName = "HeadSlot", slotNumber = 1, formattedName = "Head",},
		{equipLocation = "INVTYPE_NECK", slotName = "NeckSlot", slotNumber = 2, formattedName = "Neck",},
		{equipLocation = "INVTYPE_SHOULDER", slotName = "ShoulderSlot", slotNumber = 3, formattedName = "Shoulder",},
		{equipLocation = "INVTYPE_BODY", slotName = "ShirtSlot", slotNumber = 4, formattedName = "Shirt",},
		{equipLocation = "INVTYPE_CHEST", slotName = "ChestSlot", slotNumber = 5, formattedName = "Chest",},
		{equipLocation = "INVTYPE_ROBE", slotName = "ChestSlot", slotNumber = 5, formattedName = "Chest",},
		{equipLocation = "INVTYPE_WAIST", slotName = "WaistSlot", slotNumber = 6, formattedName = "Waist",},
		{equipLocation = "INVTYPE_LEGS", slotName = "LegsSlot", slotNumber = 7, formattedName = "Legs",},
		{equipLocation = "INVTYPE_FEET", slotName = "FeetSlot", slotNumber = 8, formattedName = "Feet",},
		{equipLocation = "INVTYPE_WRIST", slotName = "WristSlot", slotNumber = 9, formattedName = "Wrist",},
		{equipLocation = "INVTYPE_HAND", slotName = "HandsSlot", slotNumber = 10, formattedName = "Hands",},
		{equipLocation = "INVTYPE_FINGER", slotName = "Finger0Slot", slotNumber = 11, formattedName = "Finger",},
		{equipLocation = "INVTYPE_FINGER", slotName = "Finger1Slot", slotNumber = 12, formattedName = "Finger",},
		{equipLocation = "INVTYPE_TRINKET", slotName = "Trinket0Slot", slotNumber = 13, formattedName = "Trinket",},
		{equipLocation = "INVTYPE_TRINKET", slotName = "Trinket1Slot", slotNumber = 14, formattedName = "Trinket",},
		{equipLocation = "INVTYPE_CLOAK", slotName = "BackSlot", slotNumber = 15, formattedName = "Back",},
		{equipLocation = "INVTYPE_WEAPON", slotName = "MainHandSlot", slotNumber = 16, formattedName = "Main Hand",},
		{equipLocation = "INVTYPE_SHIELD", slotName = "SecondaryHandSlot", slotNumber = 17, formattedName = "Offhand",},
		{equipLocation = "INVTYPE_2HWEAPON", slotName = "MainHandSlot", slotNumber = 16, formattedName = "Main Hand",},
		{equipLocation = "INVTYPE_WEAPONMAINHAND", slotName = "MainHandSlot", slotNumber = 16, formattedName = "Main Hand",},
		{equipLocation = "INVTYPE_WEAPONOFFHAND", slotName = "SecondaryHandSlot", slotNumber = 17, formattedName = "Offhand",},
		{equipLocation = "INVTYPE_HOLDABLE", slotName = "SecondaryHandSlot", slotNumber = 17, formattedName = "Offhand",},
		{equipLocation = "INVTYPE_RANGED", slotName = "MainHandSlot", slotNumber = 16, formattedName = "Main Hand",},
		{equipLocation = "INVTYPE_THROWN", slotName = "MainHandSlot", slotNumber = 16, formattedName = "Main Hand",},
		{equipLocation = "INVTYPE_RANGEDRIGHT", slotName = "MainHandSlot", slotNumber = 16, formattedName = "Main Hand",},
		{equipLocation = "INVTYPE_RELIC", slotName = "MainHandSlot", slotNumber = 16, formattedName = "Main Hand",},
		{equipLocation = "INVTYPE_TABARD", slotName = "TabardSlot", slotNumber = 19, formattedName = "Tabard",},
		{equipLocation = "INVTYPE_BAG", slotName = "Bag0Slot", slotNumber = 20, formattedName = "Bag",},
		{equipLocation = "INVTYPE_QUIVER", slotName = nil, slotNumber = 20, formattedName = "Ammo",},
	};	
	self.roster = {}
	self.sets = {}
	self.setAddons = {
		{
			id = 'outfitter', 
			loaded = function() 
				if IsAddOnLoaded('Outfitter') and 
					Outfitter and 
					Outfitter.Settings and 
					Outfitter.Settings.Outfits and 
					Outfitter.Settings.Outfits.Complete then
					return true
				end
			end,
			name = 'Outfitter', 
		},
	}
	self.specializations = self:GetSpecializations()
	self.update = {}
	self.update.auction = {}
	self.update.core = {}
	self.versions = {}	
	
	-- Mature language filter
	BNSetMatureLanguageFilter(self.db.profile.cvars.matureLanguageFilterEnabled)
end

function kLoot:InitializeEvents()
	--self:RegisterEvent('ADDON_LOADED', 'Event_AddOnLoaded')
	self:RegisterEvent('EQUIPMENT_SETS_CHANGED', 'Event_EquipmentSetsChanged')
	self:RegisterEvent('LOOT_OPENED')
	self:RegisterEvent('ZONE_CHANGED', 'Event_OnZoneChanged')
	self:RegisterEvent('ZONE_CHANGED_INDOORS', 'Event_OnZoneChanged')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Event_OnZoneChanged')
end

function kLoot:InitializeTimers()
	-- Create roster update timer
	self:Timer_Raid_UpdateRoster()
	-- Create set creation delay timer
	self:Timer_Set_Generate()
end

function kLoot:LOOT_OPENED(event, ...)
	if self.db.profile.autoloot.enabled and tContains(self.db.profile.autoloot.zones, GetRealZoneText()) then
		if (GetNumLootItems() > 0) then
			for i=1,GetNumLootItems() do
				local lootIcon, lootName, lootQuantity, rarity, locked = GetLootSlotInfo(i)
				local itemLink = GetLootSlotLink(i)
				local itemLooted, itemId = false, self:Item_GetIdFromLink(itemLink)
				if (not itemLooted) and (tContains(self.db.profile.autoloot.whitelist, lootName) or tContains(self.db.profile.autoloot.whitelist, itemId)) then
					LootSlot(i)
					itemLooted = true
					self:Debug('LOOT_OPENED' .. ' Looting ' .. lootName, 2)
				end
			end
		end
	end
end