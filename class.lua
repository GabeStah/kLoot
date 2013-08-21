local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random, tContains = table, table.insert, table.remove, wipe, sort, date, time, random, tContains
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[function raid:GetType()
	return self.type
end

local auction = self:Class_Create(raid)
auction.type = 'auction'

local bid = self:Class_Create(auction)
bid.type = 'bid'

local monster = self:Class_Create(auction, bid)

m1 = monster:New()
m2 = bid:New()

print(m1:GetType())
print(m2:GetType())
]]

function kLoot:Class_Create(...)
	local parents = {...}
	local class = setmetatable({}, {
		__index = function(t, k)
			for i,v in ipairs(parents) do
				local attr = v[k]
				if attr ~= nil then
					return attr
				end
			end
		end
	})
	local instanceMetatable = {__index = class}
	class.New = function(self) return setmetatable({}, instanceMetatable) end
	class.GetType = function(self) return self.type end
	return class
end