local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create and initialize a new timer
]]
function kLoot:Timer_Create(func,time,loop,...)
	if type(func) == 'string' then
		self:Debug('CreateTimer', 'New timer function:', func, 1)
	end
	table.insert(self.timers, {id = self:GetUniqueId(self.timers), time = loop and time or (GetTime() + time), func = func, loop = loop, args = ...})
end

function kLoot:Timer_RosterUpdate()
	self:Timer_Create('Raid_UpdateRoster', 10, true)
end