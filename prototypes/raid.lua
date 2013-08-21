local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random, tContains = table, table.insert, table.remove, wipe, sort, date, time, random, tContains
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

local parents = {...}
local raid = setmetatable({}, {
	__index = function(t, k)
		for i,v in ipairs(parents) do
			local attr = v[k]
			if attr ~= nil then
				return attr
			end
		end
	end
})
local instanceMetatable = {__index = raid}
-- Attributes
raid.type = 'raid'

function raid:GetType()
	return self.type
end

-- Create a new raid
function raid:New(id)
	-- Verify role
	if not kLoot:Role_IsAdmin() then
		kLoot:Error('Raid_New', 'Invalid permission to create raid.')
		return
	end

	if not id then -- assume active raid
		
	else
		if type(id) == 'string' then
			--self:Debug('Raid_Get', 'type(id) == string', id, 1)
			id = tonumber(id)
		end
		if type(id) == 'number' then
			--self:Debug('Raid_Get', 'type(id) == number', id, 1)
			for i,v in pairs(kLoot.db.profile.raids) do
				if v.id and v.id == id then
					self:Debug('raid:New', 'Raid by id match found:', id, v, 1)
					return v
				end
			end
		else	
	end
	
	-- Raid exists?
	for i,v in pairs(kLoot.db.profile.raids) do
		
	end
	
	-- Rebuild roster
	kLoot:Roster_Rebuild()
	-- Create empty raid table
	local raid = {
		actors = kLoot.roster.full,
		auctions = {},
		id = id,
		time = time(),
		objectType = 'raid',
	}
	tinsert(self.db.profile.raids, raid)
	-- Bump active raid
	self.db.profile.settings.raid.active = id
	self:Debug('Raid_New', 'Raid created.', 3)

	local raid = {
		id = id or kLoot:GetUniqueId(),
	}
	return setmetatable(raid, instanceMetatable)
end

function kLoot:RaidPrototype()
	return raid
end

function kLoot:RaidCreate()
	r1 = raid:New()
	print(r1.id)
end

--[[ PREVIOUS WORKING
local raid = kLoot.prototypes.raid

function kLoot:RaidPrototypeCreate(...)
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
	class.New = function(self, id) return setmetatable(
		{
			id = id or kLoot:GetUniqueId()
		}, instanceMetatable) end
	return class
end

function kLoot:RaidPrototype()
	raid = self:RaidPrototypeCreate()
	raid.type = 'raid'
	r1 = raid:New('abcd1234')
	print(r1.id)
end
]]