local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Get inventory item
]]
function kLoot:Inventory_ItemLink(bagId, slotId)
	return GetContainerItemLink(bagId, slotId)
end

--[[ Get inventory item list
]]
function kLoot:Inventory_ItemList(location)
	location = location or 'inventory'
	local data
	if location == 'inventory' then
		for bag=1,NUM_BAG_SLOTS do
			local slots = GetContainerNumSlots(bag)
			if slots then
				for slot=1,slots do
					data = data or {}
					tinsert(data, (self:Inventory_ItemLink(bag,slot)))
				end
			end
		end
		return data
	elseif location == 'bank' then
	elseif location == 'transmog' then
	elseif location == 'keyring' then
	elseif location == 'tokens' then
	end
end