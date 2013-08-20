local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Award an active auction
]]
function kLoot:Auction_Award(auction)
	-- TODO: Complete
end

--[[ Get Auction object by item
]]
function kLoot:Auction_ByItem(item)
	-- Parse item
	item = self:Item_Id(item)
	if not item then return end
	-- Active raid
	local raid = self:Raid_Get()
	if not raid then return end
	for i = #raid.auctions, 1, -1 do
		if raid.auctions[i].itemId == item then
			return raid.auctions[i]
		end
	end
end

--[[ Close auction and process
]]
function kLoot:Auction_Close(auction)
	auction = self:Auction_Get(auction)
	if not auction then
		self:Error('Auction_Close', 'Invalid auction specified, cannot close.')
		return
	end
	if auction.closed then return end
	-- Award auction
	self:Auction_Award(auction)
	-- Set as closed
	auction.closed = true
	self:Debug('Auction_Close', 'Closing auction.', auction, 3)
end

--[[ Get Auction by id or object, most recent if not specified
]]
function kLoot:Auction_Get(auction)
	local raid = self:Raid_Get()
	if not auction then -- assume most recent auction of active raid
		if not raid then return end
		if #raid.auctions and (#raid.auctions > 0) then
			return self:Auction_Get(raid.auctions[#raid.auctions].id)
		end
	end
	if type(auction) == 'string' then
		self:Debug('Auction_Get', 'type(auction) == string', auction, 1)
		auction = tonumber(auction)
	end
	if type(auction) == 'number' then
		self:Debug('Auction_Get', 'type(auction) == number', auction, 1)
		if not raid then
			self:Debug('Auction_Get', 'type(auction) == number, invalid raid.', 2)
			return
		end		
		for iAuction,vAuction in pairs(raid.auctions) do
			if vAuction.id and vAuction.id == auction then
				self:Debug('Auction_Get', 'auction by id match found:', auction, vAuction, 1)
				return vAuction
			end
		end
	elseif type(auction) == 'table' then
		self:Debug('Auction_Get', 'type(auction) == table', auction, 1)
		if auction.objectType and auction.objectType == 'auction' then
			self:Debug('Auction_Get', 'auction.objectType == auction', auction.objectType, 1)
			return auction
		end
	end
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
	local auctionId = self:GetUniqueId()
	self:Debug('Auction_New', 'New auctionId', auctionId, 1)
	local auction = {
		bids = {},
		closed = false,		
		created = GetTime(),
		expiration = GetTime() + self.db.profile.auction.duration,		
		id = auctionId,
		itemId = itemId,
		objectType = 'auction',		
		timestamp = time(),
	}
	tinsert(raid.auctions, auction)
	self:Debug('Auction_New', 'Auction creation complete.', itemId, 3)
end

--[[ Process auctions for expiration and similar
]]
function kLoot:Auction_OnUpdate(elapsed)
	local updateType = 'auction'
	self.update[updateType].timeSince = (self.update[updateType].timeSince or 0) + elapsed
	if (self.update[updateType].timeSince > self.db.profile.settings.update[updateType].interval) then
		local raid = self:Raid_Get()
		if not raid then return end
		local time = GetTime()	
		-- Loop auctions
		for i,auction in pairs(raid.auctions) do
			if (auction.expiration <= time) and not auction.closed then -- Expired
				self:Auction_Close(auction)
			end
		end
		-- Reset uptime timer
		self.update[updateType].timeSince = 0
	end	
end