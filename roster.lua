local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Generate full roster from raid/guild rosters
]]
function kLoot:Roster_Generate()
	local roster = {}
	for i,v in pairs(self.roster.raid) do
		roster[i] = v
	end
	for iGuild,vGuild in pairs(self.roster.guild) do
		if not roster[iGuild] then
			roster[iGuild] = vGuild
		end
	end
	return roster
end

--[[ Rebuild full roster from raid/guild rosters
]]
function kLoot:Roster_Rebuild()
	self:Guild_RebuildRoster()
	self:Raid_RebuildRoster()
	self.roster.full = self:Roster_Generate()
end