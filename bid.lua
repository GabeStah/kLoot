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

--[[ Create new bid
]]
function kLoot:Bid_Create(auction, id, items, player, bidType, specialization, isClient)
	auction = self:Auction_Get(auction)
	if not auction then
		self:Error('Bid_Create', 'Cannot generate bid for nil auction.')
		return
	end
	-- Check if bid exists
	if id and self:Bid_Get(id, auction) then return end	
	player = player or UnitName('player')
	bidType = bidType or self:GetTableEntry(self.bidTypes, nil, true)
	specialization = specialization or self:GetTableEntry(self.specializations)
	if specialization and type(specialization) == 'table' and specialization.name then
		specialization = specialization.name
	end
	if not items then
		items = {}
		local set = self:Set_GetByBidType(bidType)
		local slot = self:Item_GetSlotValue(self:Item_EquipLocation(auction.itemId), 'equipLocation', 'slotNumber')			
		if not slot then return end
		-- Check if slot is finger or trinket or weapon
		local setItems = {
			[11] = self:Set_SlotItem(set, 11, 'id'),
			[12] = self:Set_SlotItem(set, 12, 'id'),
			[13] = self:Set_SlotItem(set, 13, 'id'),
			[14] = self:Set_SlotItem(set, 14, 'id'),
			[16] = self:Set_SlotItem(set, 16, 'id'),
			[17] = self:Set_SlotItem(set, 17, 'id'),
		}
		setItems[slot] = self:Set_SlotItem(set, slot, 'id')
		if slot == 11 or slot == 12 then
			if setItems[11] then tinsert(items, setItems[11]) end
			if setItems[12] then tinsert(items, setItems[12]) end
		elseif slot == 13 or slot == 14 then
			if setItems[13] then tinsert(items, setItems[13]) end
			if setItems[14] then tinsert(items, setItems[14]) end
		elseif slot == 16 or slot == 17 then
			if setItems[16] then tinsert(items, setItems[16]) end
			if setItems[17] then tinsert(items, setItems[17]) end
		else
			if setItems[slot] then tinsert(items, setItems[slot]) end
		end	
	else
		-- items exist as ID or itemlink data
		
	end
	
	id = id or self:GetUniqueId()
	local bid = {
		bidType = bidType,	
		created = GetTime(),		
		id = id,
		items = items or {},
		objectType = 'bid',		
		player = player,
		specialization = specialization,
		timestamp = time(),
	}
	tinsert(auction.bids, bid)
	if not isClient then
		self:Comm_BidCreate(id, auction.id, items, player, bidType, specialization)
	end
	self:Debug('Bid_Create', 'Bid creation complete.', id, 3)
end

--[[ Delete auction
]]
function kLoot:Bid_Delete(bid)

end

--[[ Destroy auction
]]
function kLoot:Bid_Destroy(bid)
	
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
function kLoot:Bid_Update(bid)
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