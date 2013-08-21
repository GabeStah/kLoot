local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create new Actor entry
]]
function kLoot:Actor_Create(name, class, online, inRaid, time, guildNote)
	return {
		class = class,					
		events = {
			{
				inRaid = inRaid,
				online = online,
				time = time or time(),
			},
		},
		guildNote = guildNote,
		name = name, 
		objectType = 'actor',
	}
end

--[[ Get actor object from raid table
]]
function kLoot:Actor_Get(raid, actor)
	local raid = self:Raid_Get(raid)
	if not raid or not actor then return end
	if type(actor) == 'string' then
		if raid.actors[actor] then return raid.actors[actor] end
	elseif type(actor) == 'table' then
		if actor.objectType and actor.objectType == 'actor' then return actor end
	end
end

--[[ Update actor entry in raid table
]]
function kLoot:Actor_Update(raid, name, class, online, inRaid, time, guildNote)
	local raid = self:Raid_Get(raid)
	if not raid or not name then 
		self:Debug('Actor_Update', 'Raid or name not found.', name, raid, 1)
		return
	end
	local actor = raid.actors[name]
	if actor then
		--self:Debug('Actor_Update', 'Actor found:', actor, 1)
		-- Check if last event online status does not match current online status
		if actor.events and #actor.events >= 1 then
			self:Debug('Actor_Update', 'Actor events found:', actor.events, 1)
			if (actor.events[#actor.events].online ~= online) or (actor.events[#actor.events].inRaid ~= inRaid) then
				self:Debug('Actor_Update', 'Actor online or inRaid mismatch, updating.', 1)
				-- Create new event
				local event = {
					inRaid = inRaid,
					online = online,
					time = time or time(),
				}
				tinsert(actor.events, event)
			end
		end
		-- Bump other values
		actor.name = name
		actor.class = class
		actor.guildNote = guildNote
		return true -- Found, return true
	end
end