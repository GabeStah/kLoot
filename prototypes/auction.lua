local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random, tContains = table, table.insert, table.remove, wipe, sort, date, time, random, tContains
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

local parents = {kLoot:RaidPrototype()}
local auction = setmetatable({}, {
	__index = function(t, k)
		for i,v in ipairs(parents) do
			local attr = v[k]
			if attr ~= nil then
				return attr
			end
		end
	end
})
local instanceMetatable = {__index = auction}
auction.New = function(self, id) return setmetatable(
	{
		id = id or kLoot:GetUniqueId(),
	}, instanceMetatable) end
auction.type = 'auction'

function kLoot:AuctionPrototype()
	return auction
end

function kLoot:AuctionCreate()
	r1 = auction:New('auctionId')
	print(r1.id)
	print(r1:GetType())
end

--[[ PREVIOUS WORKING
local auction = kLoot.prototypes.auction

function kLoot:AuctionPrototype()
	auction = self:Class_Create(self.prototypes.raid)
	auction.type = 'auction'
	a1 = auction:New()
	
	print(a1:GetType())
end
]]