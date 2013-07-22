-- Create Mixins
local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = LibStub("AceAddon-3.0"):NewAddon("kLoot", "AceComm-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceTimer-3.0")
_G.kLoot = kLoot
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
	kLoot:InitializeSettings()
	self.updateFrame = CreateFrame("Frame", "kLootUpdateFrame", UIParent);
	kLootUpdateFrame:SetScript("OnUpdate", function(frame,elapsed) kLoot:OnUpdate(1, elapsed) end)
end

function kLoot:InitializeSettings()
	self.settings = self.settings or {}
	self.settings.raid = self.settings.raid or {}
	-- Mature language filter
	BNSetMatureLanguageFilter(self.db.profile.cvars.matureLanguageFilterEnabled)
end

function kLoot:InitializeEvents()
	self:RegisterEvent('LOOT_OPENED')
	self:RegisterEvent('ZONE_CHANGED', 'Event_OnZoneChanged')
	self:RegisterEvent('ZONE_CHANGED_INDOORS', 'Event_OnZoneChanged')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Event_OnZoneChanged')
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

--[[ Determine if a raid is currently active
return boolean - Raid active status.
]]
function kLoot:Raid_IsRaidActive()
	return self.db.profile.settings.raid.active
end

-- Set the active status of the raid
function kLoot:Raid_SetRaidStatus(status)
	self.db.profile.settings.raid.active = status or false
end

-- Toggle the active status of the raid
function kLoot:Raid_ToggleRaidStatus()
	self.db.profile.settings.raid.active = not self.db.profile.settings.raid.active
end

function kLoot:Raid_IsValidZone()
	for iZone,vZone in pairs(self.db.profile.zones.validZones) do
		if self.currentZone == vZone then return true end
	end
end

function kLoot:Raid_SetZone()
	self.currentZone = GetRealZoneText()	
end

--[[ Manually auction an item via /kl auction item
]]
function kLoot:Manual_Auction(item)
	if not item then return end
	if type(item) == 'table' then
		-- Check if manual input field exists
		if item['input'] then
			local found, _, itemString = string.find(item['input'], "^auction%s(.+)")
			item = itemString
		else
			item = select(1, item)
		end
	end
	if type(item) == 'string' then item = strtrim(item) end
	-- Send to Auction_Create
	self:Auction_Create(item)
end

--[[ Award an active auction
]]
function kLoot:Auction_Award(auction)
end

--[[ Create new auction
]]
function kLoot:Auction_Create(item)
	if not item then return end
	-- Validate role
	if (not self:Role_IsAdmin()) and (not self:Role_IsEditor()) then return end
	-- Parse item id
	local id = self:Item_Id(item)
	if not id then return end
	self:Debug('kLoot:Auction_Create', id, 3) 
	local auctionId = self:GetUniqueId(self.auctions)
	self:Debug('kLoot:Auction_Create', 'New auctionId', auctionId, 1)
end

--[[ Add vote to bid
]]
function kLoot:Bid_AddVote(bid)
end

--[[ Create new bid
]]
function kLoot:Bid_Create(auction)
end

function kLoot:Item_GetItemIdFromItemLink(link)
	if not link then return end
	self:Debug("FUNC: Item_GetItemIdFromItemLink, ItemLink: " .. link, 1)
	local found, _, itemString = string.find(link, "^|c%x+|H(.+)|h%[.*%]")
	if not itemString then return end
	local _, itemId = strsplit(":", itemString)	
	return itemId
end

--[[ Get item Id from item link, id, name
]]
function kLoot:Item_Id(item)
	-- Id
	if type(item) == 'number' then return item end
	-- Id (string type)
	if type(item) == 'string' and type(tonumber(item)) == 'number' then return tonumber(item) end
	-- Link
	local itemId = self:Item_GetItemIdFromItemLink(item)
	if type(item) == 'string' and itemId then return tonumber(itemId) end
	-- Item string
	local _, itemId = strsplit(":", item)
	if type(item) == 'string' and itemId then return tonumber(itemId) end
	local _, itemLink = GetItemInfo(item)
	itemId = self:Item_GetItemIdFromItemLink(itemLink)
	-- Name
	if itemLink and itemId then return tonumber(itemId) end
end

--[[ Get Role of player.
@[player] string (Default: 'player') - Player name
return string - Role assigned or nil
]]
function kLoot:Role_GetRole(player)
	player = player or UnitName('player')
end

--[[ Determine if a Player is assigned Administrator Role
@[player] string (Default: 'player') - Player name
return boolean - Result of role match
]]
function kLoot:Role_IsAdmin(player)
	player = player or UnitName('player')
	if not UnitExists(player) then return end
	return (GetNumGroupMembers() and UnitIsGroupLeader(player)) or (GetNumGroupMembers() == 0 and player == UnitName('player'))
end

--[[ Determine if a Player is assigned Editor Role
@[player] string (Default: 'player') - Player name
return boolean - Result of role match
]]
function kLoot:Role_IsEditor(player)
	player = player or UnitName('player')
	for i,v in pairs(self.db.profile.editors) do
		if v == player then return true end
	end
	return false
end

--[[ Determine if a player is assigned to a particular Role.
@[role] string (Default: 'administrator') - Full name or nickname of the role to check
@[player] string (Default: 'player') - Player name
return boolean - Result of role match for provided player
]]
function kLoot:Role_IsRole(role,player)
	role = role or 'administrator'
	player = player or UnitName('player')
	if role == 'administrator' or role == 'admin' then
		return self:Role_IsAdmin(player)
	elseif role == 'editor' then
		return self:Role_IsEditor(player)
	end
	return false
end

--[[ Assign role to a player.
@[role] string (Default: 'editor') - Full name or nickname of the role
@[player] string (Default: 'player') - Player name
return boolean - Success/failure
]]
function kLoot:Role_AddRole(role,player)
	role = role or 'editor'
	player = player or UnitName('player')
	if role == 'editor' then
		if not self:Role_IsEditor(player) then
			tinsert(self.db.profile.editors, player)			
		end
		return true
	end
	return false
end

--[[ Delete role from a player.
@[role] string (Default: 'editor') - Full name or nickname of the role
@[player] string (Default: 'player') - Player name
return boolean - Success/failure
]]
function kLoot:Role_DeleteRole(role,player)
	role = role or 'editor'
	player = player or UnitName('player')
	if role == 'editor' then
		if self:Role_IsEditor(player) then
			for i,v in pairs(self.db.profile.editors) do
				if v == player then
					tremove(self.db.profile.editors, i)
					return true
				end
			end
		end
	end	
	return false
end