local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

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