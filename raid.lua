--[[
RAID CREATION
1. /raidstart
2. Check if current active raid exists (db.profile.settings.raid.active)
3. If raid is active, PROMPT to continue existing raid or start new raid
4. If new raid, process closure of active raid (settings.raid.active=nil) and create NEW raid
5. If continue raid, no change.
6. NEW raid: Assign UniqueId to settings.raid.active from db.profile.raids
7. CREATE new db.profile.raids entry {id, startDate, endDate, zone, actors}
]]

local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Destroy an existing raid instance in database
TODO: Complete function
]]
function kLoot:Raid_Destroy()
	-- Invalidate current active raid
	self.db.profile.settings.raid.active = nil
end

--[[ End process for Raid
]]
function kLoot:Raid_End()
	kLoot:Debug('Raid_End', 3)
	-- TODO: Process end of raid events
	-- Destroy active raid
	kLoot:Raid_Destroy()
end

--[[ Generate the initial raid roster
]]
function kLoot:Raid_GenerateRoster()
	local count, roster, currentTime, name, class, online = self:GetPlayerCount(), {}, time()
	if count == 1 then
		roster[UnitName('player')] = self:Actor_New(UnitName('player'), UnitClass('player'), true, true, currentTime)
	else
		for i=1,count do
			name, _, _, _, class, _, _, online = GetRaidRosterInfo(i)
			roster[name] = self:Actor_New(name, class, online and true or false, true, currentTime)
		end	
	end
	return roster
end

--[[ Get Raid by id or raid object, most recent if not specified
]]
function kLoot:Raid_Get(raid)
	if not raid then -- assume active raid
		if not self:Raid_IsActive() then return end
		return self:Raid_Get(self:Raid_GetActive())
	end
	if type(raid) == 'string' then
		--self:Debug('Raid_Get', 'type(raid) == string', raid, 1)
		raid = tonumber(raid)
	end
	if type(raid) == 'number' then
		--self:Debug('Raid_Get', 'type(raid) == number', raid, 1)
		for i,v in pairs(self.db.profile.raids) do
			if v.id and v.id == raid then
				self:Debug('Raid_Get', 'Raid by id match found:', raid, v, 1)
				return v
			end
		end
	elseif type(raid) == 'table' then
		--self:Debug('Raid_Get', 'type(raid) == table', raid, 1)
		if raid.objectType and raid.objectType == 'raid' then
			--self:Debug('Raid_Get', 'raid.objectType == raid', raid.objectType, 1)
			return raid
		end
	end
end

--[[ Return the current active raid
]]
function kLoot:Raid_GetActive()
	if not self:Raid_IsActive() then return end
	for i,v in pairs(self.db.profile.raids) do
		if v.id and v.id == self.db.profile.settings.raid.active then
			return v
		end
	end
end

--[[ Check if a raid is currently active
]]
function kLoot:Raid_IsActive()
	return self.db.profile.settings.raid.active
end

--[[ Check if currentzone is valid
-- TODO: verify
]]
function kLoot:Raid_IsValidZone()
	for i,v in pairs(self.db.profile.zones.validZones) do
		if self.currentZone == v then return true end
	end
end

--[[ Create a new raid instance in database
]]
function kLoot:Raid_New()
	-- Verify role
	if not self:Role_IsAdmin() then
		self:Error('Raid_New', 'Invalid permission to create raid.')
		return
	end
	local id = self:GetUniqueId()
	-- Rebuild roster
	self:Roster_Rebuild()
	-- Create empty raid table
	local raid = {
		actors = self.roster.full,
		auctions = {},
		id = id,
		time = time(),
		objectType = 'raid',
	}
	tinsert(self.db.profile.raids, raid)
	-- Bump active raid
	self.db.profile.settings.raid.active = id
	self:Debug('Raid_New', 'Raid created.', 3)
end

--[[ Rebuild temporary raid roster
]]
function kLoot:Raid_RebuildRoster()
	local roster = self:Raid_GenerateRoster()
	self.roster.raid = self.roster.raid or {}
	for i,v in pairs(roster) do
		self.roster.raid[i] = v
	end
	for i,v in pairs(self.roster.raid) do
		local found = false
		for iRoster,vRoster in pairs(roster) do
			if iRoster == i then found = true end
		end
		if not found then
			self:Debug('Raid_RebuildRoster', 'Not in raid detected:', i, 1)
			self.roster.raid[i].events[#self.roster.raid[i].events].inRaid = false
		end
	end
end

--[[ Resume an active raid
]]
function kLoot:Raid_Resume()
	if self:Raid_IsActive() then
		-- Refresh roster
		local raid = self:Raid_Get()
		self:Raid_UpdateRoster(raid)
		self:Debug('Raid_Resume', 'Roster updated.', 3)
		self:Debug('Raid_Resume', 'Resume complete.', 3)
	end
end

--[[ Set current zone
-- TODO: verify
]]
function kLoot:Raid_SetZone()
	self.currentZone = GetRealZoneText()	
end

--[[ Start a new raid
]]
function kLoot:Raid_Start()
	kLoot:Debug('Raid_Start', 3)
	-- TODO: Process start of raid events
	-- Is raid already active?
	if kLoot:Raid_IsActive() then
		-- Active raid
		-- Continue existing raid?
		kLoot:View_PromptResumeRaid()
	else
		-- No active raid
		-- Create new raid
		kLoot:Raid_New()
	end
	-- Create active raid
end

--[[ Update the raid roster
]]
function kLoot:Raid_UpdateRoster(raid)
	local raid = kLoot:Raid_Get(raid)
	if not raid then
		kLoot:Debug('Raid_UpdateRoster', 'No raid found:', raid, 1)
		return
	end
	-- Rebuild roster
	kLoot:Roster_Rebuild()
	-- Loop through full roster, update or add as needed
	for name,actor in pairs(kLoot.roster.full) do
		if raid.actors[name] then
			kLoot:Debug('Raid_UpdateRoster', 'Updating actor:', name, 1)
			kLoot:Actor_Update(
				raid, 
				actor.name, 
				actor.class, 
				actor.events[#actor.events].online, 
				actor.events[#actor.events].inRaid, 
				actor.events[#actor.events].time,
				actor.guildNote) 
		else
			kLoot:Debug('Raid_UpdateRoster', 'Creating actor:', name, 1)
			raid.actors[name] = kLoot:Actor_New(
				actor.name, 
				actor.class, 
				actor.events[#actor.events].online, 
				actor.events[#actor.events].inRaid, 
				actor.events[#actor.events].time,
				actor.guildNote)			
		end
	end
end