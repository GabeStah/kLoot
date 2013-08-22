local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Get item equip location
]]
function kLoot:Item_EquipLocation(item)
	item = self:Item_Id(item)
	if not item then return end
	return select(9, GetItemInfo(item))
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
	if type(item) == 'string' and type(tonumber(item)) == 'number' then 
		if item == '0' then return end
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