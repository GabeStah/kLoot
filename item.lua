local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Get the color rgb for item based on rarity
]]
function kLoot:Item_ColorByRarity(rarity)
	if not rarity then return end
	return GetItemQualityColor(rarity)
end

--[[ Get item equip location
]]
function kLoot:Item_EquipLocation(item)
	item = self:Item_Id(item)
	if not item then return end
	local location = select(9, GetItemInfo(item))
	self:Debug('Item_EquipLocation', 'location: ', location, 'item: ', item, 2)
	return location
end

--[[ Retrieve equipped item(s) from slot
]]
function kLoot:Item_EquippedBySlot(slot)
	if slot and type(slot) == 'string' then -- assume equipLocation, get slotNumber
		slot = self:Item_GetSlotValue(slot, 'equipLocation', 'slotNumber')
	end
	if not slot then return end
	if slot == 11 or slot == 12 then
		return GetInventoryItemLink('player', 11), GetInventoryItemLink('player', 12)
	elseif slot == 13 or slot == 14 then
		return GetInventoryItemLink('player', 13), GetInventoryItemLink('player', 14)
	elseif slot == 16 or slot == 17 then
		return GetInventoryItemLink('player', 16), GetInventoryItemLink('player', 17)
	end	
	return GetInventoryItemLink('player', slot)
end

--[[ Get itemId from an itemlink string
]]
function kLoot:Item_GetIdFromLink(link)
	if not link then return end
	self:Debug("FUNC: Item_GetIdFromLink, ItemLink: " .. link, 1)
	local found, _, itemString = string.find(link, "^|c%x+|H(.+)|h%[.*%]")
	if not itemString then return end
	local _, itemId = strsplit(":", itemString)	
	return itemId
end

--[[ Retrieve the slot name from the slot number
]]
function kLoot:Item_GetSlotValue(value, valueType, returnType)
	if not value then return end
	valueType = valueType or 'slotNumber'
	returnType = returnType or 'slotName'
	for i,v in pairs(self.itemSlotData) do
		if v[valueType] == value then return v[returnType] end
	end
end

--[[ Get the icon texture for the item
]]
function kLoot:Item_Icon(item)
	item = self:Item_Id(item)
	if not item then return end
	return select(10, GetItemInfo(item))
end

--[[ Get item Id from item link, id, name
]]
function kLoot:Item_Id(item)
	if not item then return end
	local itemId
	-- Id
	if type(item) == 'number' then 
		if item == 0 then return nil end
		return item
	end
	-- Id (string type)
	if type(item) == 'string' or type(tonumber(item)) == 'number' then 
		if tonumber(item) == 0 then return end
		return tonumber(item)
	end
	-- Table
	if type(item) == 'table' then
		if item.itemId and type(tonumber(item.itemId)) == 'number' then
			return tonumber(item.itemId)
		end
		if item.id and type(tonumber(item.id)) == 'number' then
			return tonumber(item.id)
		end
	end
	-- Link
	local found, _, itemString = string.find(item, "^|c%x+|H(.+)|h%[.*%]")
	if itemString then 
		itemId = select(2, strsplit(':', itemString))
		return tonumber(itemId) 
	end
	-- Item string
	_, itemId = strsplit(":", item)
	if type(item) == 'string' and itemId then return tonumber(itemId) end
	-- Name	
	local _, itemLink = GetItemInfo(item)
	if itemLink then return self:Item_Id(itemLink) end
end

--[[ Get item level
]]
function kLoot:Item_Level(item)
	item = self:Item_Id(item)
	if not item then return end
	return select(4, GetItemInfo(item))
end

--[[ Get item link
]]
function kLoot:Item_Link(item)
	item = self:Item_Id(item)
	if not item then return end
	return select(2, GetItemInfo(item))
end

--[[ Extract the link from a string
]]
function kLoot:Item_LinkFromString(item, instance)
	if not item then return end
	instance = instance or 1
	local count = 0
	for word in string.gmatch(item, "(|c.-|r)") do 
		count = count + 1
		if count == instance then return word end
	end
end

--[[ Count the number of links to be extracted from passed string
]]
function kLoot:Item_LinkFromStringCount(item)
	if not item then return end
	local count
	for word in string.gmatch(item, "(|c.-|r)") do
		count = (count or 0) + 1
	end
	return count
end

--[[ Get item name
]]
function kLoot:Item_Name(item)
	item = self:Item_Id(item)
	if not item then return end
	return select(1, GetItemInfo(item))
end

--[[ Get item rarity
]]
function kLoot:Item_Rarity(item)
	item = self:Item_Id(item)
	if not item then return end
	return select(3, GetItemInfo(item))
end