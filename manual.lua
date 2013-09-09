local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Manually auction an item via /kl auction item
]]
function kLoot:Manual_Auction(input)
	if not input then return end
	if type(input) == 'table' then
		-- Check if manual input field exists
		if input['input'] then
			local found, _, itemString = string.find(input['input'], "^auction%s+(.+)")
			input = itemString
		else
			input = select(1, input)
		end
	end
	if type(input) == 'string' then input = strtrim(input) end
	-- Validate role
	if (not self:Role_IsAdmin()) and (not self:Role_IsEditor()) then
		self:Error('Manual_Auction', 'Invalid permission to create new Auction.')
		return
	end	
	-- Send to Auction_Create
	self:Auction_Create(input)
end

--[[ Manually bid an item via /kl bid item [item]
]]
function kLoot:Manual_Bid(input)
	if not input then return end
	if type(input) == 'table' then
		-- Check if manual input field exists
		if input['input'] then
			local found, _, itemString = string.find(input['input'], "^bid%s+(.+)")
			input = itemString
		else
			input = select(1, input)
		end
	end
	if type(input) == 'string' then input = strtrim(input) end
	self:Debug('Manual_Bid', input, 3)
	local count = self:Item_LinkFromStringCount(input)
	if not count then return end
	local auction, items = self:Auction_ByItem(self:Item_LinkFromString(input, 1))
	if not auction then return end	
	local bidType = self:Utility_GetTableEntry(self.bidTypes, nil, true)	
	if (count >= 2) then -- Items passed
		items = {}	
		-- Bid item(s) specified
		for i=2,count do
			tinsert(items, self:Item_Id(self:Item_LinkFromString(input, i)))
		end
	else -- No items passed, use set items or current items
		local set = self:Set_GetByBidType(bidType)
		items = self:Set_GetItemsByAuction(set, auction)
	end
	self:Bid_Create(nil, auction, items, nil, bidType)
end

--[[ Manually start or stop a raid via /kl raid [stop/start/begin/end]
]]
function kLoot:Manual_Raid(input)
	if not input then return end
	local validations = {
		{text = '^raid%s+start', func = 'Raid_Start'},
		{text = '^raid%s+begin', func = 'Raid_Start'},
		{text = '^r%s+start', func = 'Raid_Start'},
		{text = '^r%s+begin', func = 'Raid_Start'},
		{text = '^raid%s+stop', func = 'Raid_End'},
		{text = '^raid%s+end', func = 'Raid_End'},
		{text = '^r%s+stop', func = 'Raid_End'},
		{text = '^r%s+end', func = 'Raid_End'},
	}
	if type(input) == 'table' then
		-- Check if manual input field exists
		if input['input'] then
			for i,v in pairs(validations) do
				if string.find(input['input'], v.text) then
					self[v.func]()
					return
				end
			end
		end
	end
	if type(input) == 'string' then
		input = strtrim(input)
		for i,v in pairs(validations) do
			if string.find(input, v.text) then
				self[v.func]()
				return
			end
		end
	end
end