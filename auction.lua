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
function kLoot:Auction_New(item, raid)
	if not item then
		self:Error('Auction_New', 'Attempt to auction null item.')
		return
	end
	raid = self:Raid_Get(raid)
	if not raid then
		self:Error('Auction_New', 'Cannot create auction without valid active raid.')
		return
	end
	-- Validate role
	if (not self:Role_IsAdmin()) and (not self:Role_IsEditor()) then
		self:Error('Auction_New', 'Invalid permission to create new Auction.')
		return
	end
	-- Parse item id
	local itemId = self:Item_Id(item)
	if not itemId then return end
	local auctionId = self:GetUniqueId(self.auctions)
	self:Debug('Auction_New', 'New auctionId', auctionId, 1)
	-- TODO: Complete
	tinsert(raid.auctions, {
		bids = {},
		id = auctionId,
		itemId = itemId,
		createdTime = time(),
	})
	self:Debug('Auction_New', 'Auction creation complete.', itemId, 3)
end