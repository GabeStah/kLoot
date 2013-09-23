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

--[[ Cancel a bid
]]
function kLoot:Bid_Cancel(bid, auction, isClient)
	auction = self:Auction_Get(auction)
	if not auction then
		self:Error('Bid_Cancel', 'Cannot cancel bid for invalid Auction.')
		return
	end
	bid = self:Bid_Get(bid, auction)
	if not bid then
		self:Error('Bid_Cancel', 'Cannot cancel bid for invalid Bid.')
		return
	end
	-- Destroy bid entry
	for i,v in pairs(auction.bids) do
		if v.id == bid.id then
			tremove(auction.bids, i)
			break
		end
	end
	if not isClient then
		-- Cancel message to others
		self:Comm_BidCancel(bid.id, auction.id)
	end	
end

--[[ Create new bid
]]
function kLoot:Bid_Create(id, auction, items, player, bidType, specialization, flags, isClient)
	auction = self:Auction_Get(auction)
	if not auction then
		self:Error('Bid_Create', 'Cannot generate bid for nil auction.')
		return
	end
	-- Check if bid exists
	if id and self:Bid_Get(id, auction) then return end	
	player = player or UnitName('player')
	bidType = bidType or self:Utility_GetTableEntry(self.bidTypes, nil, true)
	specialization = specialization or self:Utility_GetTableEntry(self.specializations)
	if specialization and type(specialization) == 'table' and specialization.name then
		specialization = specialization.name
	end
	
	id = id or self:Utility_GenerateUniqueId()
	local bid = {
		bidType = bidType,	
		created = GetTime(),
		flags = flags,
		id = id,
		items = items,
		objectType = 'bid',		
		player = player,
		specialization = specialization,
		timestamp = time(),
	}
	tinsert(auction.bids, bid)
	if not isClient then
		self:Comm_BidCreate(id, auction.id, items, player, bidType, specialization, flags)
	end
	self:Debug('Bid_Create', 'Bid creation complete.', id, 3)
end

--[[ Destroy auction
]]
function kLoot:Bid_Destroy(bid)
	
end

--[[ Get Bid by id or object, most recent if not specified
]]
function kLoot:Bid_Get(bid, auction)
	auction = self:Auction_Get(auction)
	--[[
	if not bid then -- assume most recent bid of most recent auction
		if not auction then return end
		if #auction.bids and (#auction.bids > 0) then
			return self:Bid_Get(auction.bids[#auction.bids].id)
		end
	end
	]]
	if type(bid) == 'number' then
		self:Debug('Bid_Get', 'type(bid) == number', bid, 1)
		bid = tostring(bid)
	end
	if type(bid) == 'string' then
		self:Debug('Bid_Get', 'type(bid) == string', bid, 1)
		if not auction then
			self:Debug('Bid_Get', 'type(bid) == string, invalid auction.', 2)
			return
		end
		for i,v in pairs(auction.bids) do
			if v.id and v.id == bid then
				self:Debug('Bid_Get', 'bid by id match found:', bid, v, 1)
				return v
			end
		end
	elseif type(bid) == 'table' then
		self:Debug('Bid_Get', 'type(bid) == table', bid, 1)
		if bid.objectType and bid.objectType == 'bid' then
			self:Debug('Bid_Get', 'bid.objectType == bid', bid.objectType, 1)
			return bid
		end
	end
end

--[[ Update bid
]]
function kLoot:Bid_Update(bid, auction, items, bidType, specialization, flags, isClient)
	auction = self:Auction_Get(auction)
	if not auction then
		self:Error('Bid_Update', 'Cannot update bid for nil auction.')
		return
	end
	-- Check if bid exists
	bid = self:Bid_Get(bid, auction)
	if not bid then
		self:Error('Bid_Update', 'Cannot update bid for nil bid.')
		return
	end
	
	-- Update settings
	bid.bidType = bidType
	bid.flags = flags
	bid.items = items
	bid.specialization = specialization

	if not isClient then
		self:Comm_BidUpdate(bid.id, auction.id, items, bidType, specialization, flags)
	end
	self:Debug('Bid_Update', 'Bid update complete.', bid.id, 3)
end

--[[ Add vote to bid
]]
function kLoot:Bid_AddVote(bid)
end

--[[ Get Bid object for auction based on player
]]
function kLoot:Bid_ByPlayer(auction, player)
	auction = self:Auction_Get(auction)
	if not auction then return end
	player = player or UnitName('player')	
	for i,v in pairs(auction.bids) do
		if v.player == player then
			return v
		end
	end
end

--[[ Determine if bid is from player
]]
function kLoot:Bid_IsFromPlayer(bid, auction, player)
	bid = self:Bid_Get(bid, auction)
	if not bid then return end
	player = player or UnitName('player')
	return (bid.player == player)
end

--[[ Determine if Bid data has been altered from UI settings
]]
function kLoot:Bid_IsUpdated(bid, auction, settings)
	bid = self:Bid_Get(bid, auction)
	if not bid then return end
	if not self:Utility_MatchTables(bid.items, settings.items) then
		return true
	end	
	if settings.bidType ~= bid.bidType then
		return true
	end
	if settings.specialization ~= bid.specialization then
		return true
	end
	if not self:Utility_MatchTables(bid.flags, settings.flags) then
		return true
	end
end