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
    -- Inject Options Table and Slash Commands
	-- Create options	
	self.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.config = LibStub("AceConfig-3.0"):RegisterOptionsTable("kLoot", self.options, {"kloot", "kl"})
	self.dialog = LibStub("AceConfigDialog-3.0")
	self.AceGUI = LibStub("AceGUI-3.0")
	-- Init Events
	self:InitializeEvents()
	-- Init Settings
	self:InitializeSettings()
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
	self.color = {
		red = {r=1, g=0, b=0},
		green = {r=0, g=1, b=0},
		blue = {r=0, g=0, b=1},
		purple = {r=1, g=0, b=1},
		yellow = {r=1, g=1, b=0},
	}	
	self.roster = {}
	self.update = {}
	self.update.auction = {}
	self.update.core = {}
	self.versions = {}	
	
	-- Mature language filter
	BNSetMatureLanguageFilter(self.db.profile.cvars.matureLanguageFilterEnabled)
end

function kLoot:InitializeEvents()
	self:RegisterEvent('LOOT_OPENED')
	self:RegisterEvent('ZONE_CHANGED', 'Event_OnZoneChanged')
	self:RegisterEvent('ZONE_CHANGED_INDOORS', 'Event_OnZoneChanged')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Event_OnZoneChanged')
end

function kLoot:InitializeTimers()
	-- Create roster update timer
	self:Timer_RosterUpdate()
end

function kLoot:LOOT_OPENED(event, ...)
	if self.db.profile.autoloot.enabled and tContains(self.db.profile.autoloot.zones, GetRealZoneText()) then
		if (GetNumLootItems() > 0) then
			for i=1,GetNumLootItems() do
				local lootIcon, lootName, lootQuantity, rarity, locked = GetLootSlotInfo(i)
				local itemLink = GetLootSlotLink(i)
				local itemLooted, itemId = false, self:Item_GetItemIdFromItemLink(itemLink)
				if (not itemLooted) and (tContains(self.db.profile.autoloot.whitelist, lootName) or tContains(self.db.profile.autoloot.whitelist, itemId)) then
					LootSlot(i)
					itemLooted = true
					self:Debug('LOOT_OPENED' .. ' Looting ' .. lootName, 2)
				end
			end
		end
	end
end