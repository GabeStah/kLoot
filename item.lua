local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Get itemId from an itemlink string
]]
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