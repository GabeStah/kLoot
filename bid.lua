local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

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

--[[ Get Bid by id or object, most recent if not specified
]]
function kLoot:Bid_Get(bid, auction)
	auction = self:Auction_Get(auction)
	if not bid then -- assume most recent bid of most recent auction
		if not auction then return end
		if #auction.bids and (#auction.bids > 0) then
			return self:Bid_Get(auction.bids[#auction.bids].id)
		end
	end
	if type(bid) == 'string' then
		self:Debug('Bid_Get', 'type(bid) == string', bid, 1)
		bid = tonumber(bid)
	end
	if type(bid) == 'number' then
		self:Debug('Bid_Get', 'type(bid) == number', bid, 1)
		if not auction then
			self:Debug('Bid_Get', 'type(bid) == number, invalid auction.', 2)
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
		if bid.type and bid.type == 'bid' then
			self:Debug('Bid_Get', 'bid.type == bid', bid.type, 1)
			return bid
		end
	end
end

--[[ Create new bid
]]
function kLoot:Bid_New(auction, player)
	auction = self:Auction_Get(auction)
	if not auction then
		self:Error('Bid_New', 'Cannot generate bid for invalid auction.')
		return
	end
	player = player or UnitName('player')
	local id = self:GetUniqueId(auction.bids)
	tinsert(auction.bids, {
		created = GetTime(),		
		id = id,
		items = {},
		player = player,		
		timestamp = time(),
		type = 'bid',
	})
	self:Debug('Bid_New', 'Bid creation complete.', id, 3)
end