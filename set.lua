local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[
Create: Create instance of object in data
Destroy: Process closure of object methods
Delete: Delete object from data
Get: Retrieve object
Update: Update values of object
]]

--[[ Create a new set
]]
function kLoot:Set_Create(id, addon, name, icon)
	if not id then return end
	name = name or id
	addon = addon or 'blizzard'
	-- Create empty raid table
	local set = {
		addon = addon,	
		id = id,
		icon = icon,
		name = name,
		objectType = 'set',
	}
	self:Debug('Set_Create', 'New set generated: ', set, 2)
	tinsert(self.sets, set)
	return self.sets[#self.sets]
end

--[[ Retrieve a set from existing table
]]
function kLoot:Set_Get(id, addon, name)
	if not id then return end
	if type(id) == 'table' and id.objectType and id.objectType == 'set' then
		return id
	elseif type(id) == 'string' or type(id) == 'number' then
		name = name or id
		addon = addon or 'blizzard'
		for i,v in pairs(self.sets) do
			if v.id == id and v.addon == addon then return v end
		end	
	end
end

--[[ Add an item to a set
]]
function kLoot:Set_AddItem(set, itemId, slot, link, name, equipLocation, level, rarity)
	set = self:Set_Get(set)
	if not set or not itemId or not slot then return end
	itemId = self:Item_Id(itemId)
	if not itemId then return end
	if not set then return end
	-- Populate item table
	set.items = set.items or {}
	local item = {
		equipLocation = equipLocation or self:Item_EquipLocation(itemId),
		id = itemId,
		level = level or self:Item_Level(itemId),
		link = link or self:Item_Link(itemId),
		name = name or self:Item_Name(itemId),
		rarity = rarity or self:Item_Rarity(itemId),
		slot = slot,
	}
	tinsert(set.items, item)
end

--[[ Determine addon of set
]]
function kLoot:Set_Addon(set)
	set = self:Set_Get(set)
	if not set then return end
	return set.addon
end

--[[ Get a list of set addons
]]
function kLoot:Set_AddonList()
	local addons = {}
	for i,v in pairs(self.setAddons) do
		if self:Set_AddonLoaded(v) then
			addons[v.id] = v.name
		end
	end
	addons['blizzard'] = 'Blizzard Equipment Manager'
	return addons
end

--[[ Determine if specifif addon is loaded
]]
function kLoot:Set_AddonLoaded(addon)
	if not addon then return end
	if type(addon) == 'string' then
		for i,v in pairs(self.setAddons) do
			if v.name == addon or v.id == addon then
				return self:Set_AddonLoaded(v)
			end
		end
	elseif type(addon) == 'table' then
		if addon.loaded() then 
			return true
		end	
	end
end

--[[ Determine if all addons are loaded
]]
function kLoot:Set_AddonsLoaded()
	for i,v in pairs(kLoot.setAddons) do
		if not kLoot:Set_AddonLoaded(v) then return false end
	end
	return true
end

--[[ Retrieve sets by addon
]]
function kLoot:Set_ListByAddon(addon)
	if not addon then return end
	local sets
	for i,v in pairs(self.sets) do
		if v.addon and v.addon == addon then
			sets = sets or {}
			sets[v.id] = v.id
		end
	end
	return sets
end

--[[ Generates all sets of all types
data: self.sets
]]
function kLoot:Set_Generate()
	-- Reset table
	kLoot:DestroyTable(kLoot.sets)
	-- Regenerate
	kLoot:Set_GenerateBlizzard()
	kLoot:Set_GenerateOutfitter()
	return true
end

--[[ Retrieve all Blizzard sets
]]
function kLoot:Set_GenerateBlizzard()
	if not (GetNumEquipmentSets() >= 1) then return end
	for i=1,GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(i)
		local set = self:Set_Create(name, 'blizzard', name, icon)
		local items = GetEquipmentSetItemIDs(name)
		if items then
			for slot,id in pairs(items) do
				if id and (tonumber(id) > 2) then
					local itemName, itemLink, itemRarity, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(id)
					self:Set_AddItem(set, 
									id, 
									self:Item_GetSlotValue(slot, 'slotNumber', 'slotName'), 
									itemLink, 
									itemName, 
									itemEquipLoc, 
									itemLevel, 
									itemRarity)					
				end
			end
		end
	end
end

--[[ Retrieve all Outfitter sets
]]
function kLoot:Set_GenerateOutfitter()
	if not IsAddOnLoaded('Outfitter') then return end
	if not Outfitter or 
		not Outfitter.Settings or 
		not Outfitter.Settings.Outfits or 
		not Outfitter.Settings.Outfits.Complete then
			return
		end
	for i,outfit in pairs(Outfitter.Settings.Outfits.Complete) do
		local icon
		if Outfitter.OutfitBar then
			icon = Outfitter.OutfitBar:GetOutfitTexture(outfit) or nil
		end
		local set = self:Set_Create(outfit.Name, 'outfitter', outfit.Name, icon)
		-- Populate items
		for slot, vItem in pairs(outfit.Items) do
			self:Set_AddItem(set, 
							vItem.Code, 
							slot, 
							vItem.Link, 
							vItem.Name, 
							vItem.InvType, 
							vItem.Level, 
							vItem.Quality)
		end
	end
end

--[[ Retrieve first set of basic type
]]
function kLoot:Set_GetByBidType(bidType)
	bidType = bidType or self:GetTableEntry(self.bidTypes, nil, true)
	for i,v in pairs(self.db.profile.bidding.sets) do
		if v.bidType and v.bidType == bidType then
			return self:Set_Get(v.set, v.addon)
		end
	end
end

--[[ Retrieve the item for the slot of the matching set
]]
function kLoot:Set_SlotItem(set, slot, key)
	if not set or not slot then return end
	set = self:Set_Get(set)
	if not set.items then return end
	-- if number, convert to name
	if type(slot) == 'number' then slot = self:Item_GetSlotValue(slot) end
	for i,v in pairs(set.items) do
		if v.slot == slot then
			if key and v[key] then
				return v[key]
			elseif not key then
				return v
			end
		end
	end
end