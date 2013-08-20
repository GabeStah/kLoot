local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random, tContains = table, table.insert, table.remove, wipe, sort, date, time, random, tContains
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Auction received
]]
function kLoot:Client_OnAuction(sender, id, item, expiration, timestamp)
--[[
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
]]
end

--[[ Raid received
]]
function kLoot:Client_OnRaid(sender, id)

end