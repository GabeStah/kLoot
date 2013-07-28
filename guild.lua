local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Generate and return current guild roster
]]
function kLoot:Guild_GenerateRoster()
	GuildRoster()
	local count = select(2, GetNumGuildMembers())
	local roster, currentTime = {}, time()
	--self:Debug('Guild_GenerateRoster', 'count', count, 1)
	--self:Debug('Guild_GenerateRoster', 'GetNumGuildMembers()', GetNumGuildMembers(), 1)
	for i=1,count do
		local name,_, _, _, class, _, note, _, online = GetGuildRosterInfo(i)		
		-- Check for match
		roster[name] = self:Actor_Create(name, class, online and true or false, false, currentTime, note)
	end	
	return roster
end

--[[ Rebuild temporary guild roster
]]
function kLoot:Guild_RebuildRoster()
	local roster = self:Guild_GenerateRoster()
	self.roster.guild = self.roster.guild or {}
	for i,v in pairs(roster) do
		self.roster.guild[i] = v
	end
	for i,v in pairs(self.roster.guild) do
		local found = false
		for iRoster,vRoster in pairs(roster) do
			if iRoster == i then found = true end
		end
		if not found then
			self:Debug('Guild_RebuildRoster', 'Offline detected:', i, 1)
			self.roster.guild[i].events[#self.roster.guild[i].events].online = false
		end
	end
end