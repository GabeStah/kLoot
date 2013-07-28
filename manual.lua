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
			local found, _, itemString = string.find(input['input'], "^auction%s(.+)")
			input = itemString
		else
			input = select(1, input)
		end
	end
	if type(input) == 'string' then input = strtrim(input) end
	-- Send to Auction_New
	self:Auction_New(input)
end

--[[ Manually bid an item via /kl bid item [item]
]]
function kLoot:Manual_Bid(input)
	if not input then return end
	if type(input) == 'table' then
		-- Check if manual input field exists
		if input['input'] then
			local found, _, itemString = string.find(input['input'], "^auction%s(.+)")
			input = itemString
		else
			input = select(1, input)
		end
	end
	if type(input) == 'string' then input = strtrim(input) end
	-- Send to Auction_New
	self:Auction_New(input)
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