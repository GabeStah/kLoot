-- Create Mixins
local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = LibStub("AceAddon-3.0"):NewAddon("kLoot", "AceComm-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceSerializer-3.0", "AceTimer-3.0")
_G.kLoot = kLoot
function kLoot:OnEnable() end
function kLoot:OnDisable() end
function kLoot:OnInitialize()
    -- Load Database
    self.db = LibStub("AceDB-3.0"):New("kLootDB", self.defaults)
    -- Inject Options Table and Slash Commands
	-- Create options	
	self.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.config = LibStub("AceConfig-3.0"):RegisterOptionsTable("kLoot", self.options, {"kloot", "kl"})
	self.dialog = LibStub("AceConfigDialog-3.0")
	self.AceGUI = LibStub("AceGUI-3.0")
	-- Init Events
	self:InitializeEvents()
	-- Init Settings
	kLoot:InitializeSettings()
	self.updateFrame = CreateFrame("Frame", "kLootUpdateFrame", UIParent);
	kLootUpdateFrame:SetScript("OnUpdate", function(frame,elapsed) kLoot:OnUpdate(1, elapsed) end)
end

function kLoot:InitializeSettings()
	self.settings = self.settings or {}
	self.settings.raid = self.settings.raid or {}
	-- Mature language filter
	BNSetMatureLanguageFilter(self.db.profile.cvars.matureLanguageFilterEnabled)
end

function kLoot:InitializeEvents()
	self:RegisterEvent('LOOT_OPENED')
	self:RegisterEvent('ZONE_CHANGED', 'Event_OnZoneChanged')
	self:RegisterEvent('ZONE_CHANGED_INDOORS', 'Event_OnZoneChanged')
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'Event_OnZoneChanged')
end

function kLoot:LOOT_OPENED(event, ...)
	if self.db.profile.autoloot.enabled and tContains(self.db.profile.autoloot.zones, GetRealZoneText()) then
		if (GetNumLootItems() > 0) then
			for i=1,GetNumLootItems() do
				local lootIcon, lootName, lootQuantity, rarity, locked = GetLootSlotInfo(i)
				local itemLink = GetLootSlotLink(i)
				local itemLooted, itemId = false, self:Item_GetItemIdFromItemLink(itemLink)
				if (not itemLooted) and (tContains(self.db.profile.autoloot.whitelist, lootName) or tContains(self.db.profile.autoloot.whitelist, itemId)) then
					LootSlot(i)
					itemLooted = true
					self:Debug('LOOT_OPENED' .. ' Looting ' .. lootName, 2)
				end
			end
		end
	end
end

--[[
Roles	
	Administrator -- Group Leader, acts as "server" for all high-level data confirmation
	Editor -- Any person able to "edit" basic data (assign auction winners, create auctions, etc.)
	IsRole(role='administrator',name='player')
	GetRole(name='player') -- Get current role
	SetRole(role,name='player')
	IsAdmin(player='player')
	IsEditor(player='player')
Raid management
	Start raid
	End raid
	IsRaidActive()
	SetRaidStatus()
	ToggleRaidStatus()
	
/slash commands
	auction [item]
	bid [item] [item] OR 
	
]]

--[[ Determine if a raid is currently active
return boolean - Raid active status.
]]
function kLoot:Raid_End()
	kLoot:Debug('Raid_End', 3)
	-- TODO: Process end of raid events
	-- Destroy active raid
	kLoot:Raid_Destroy()
end

function kLoot:Raid_IsActive()
	return self.db.profile.settings.raid.active
end

function kLoot:Raid_IsValidZone()
	for iZone,vZone in pairs(self.db.profile.zones.validZones) do
		if self.currentZone == vZone then return true end
	end
end

function kLoot:Raid_SetZone()
	self.currentZone = GetRealZoneText()	
end

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

function kLoot:Raid_Start()
	kLoot:Debug('Raid_Start', 3)
	-- TODO: Process start of raid events
	-- Is raid already active?
	if kLoot:Raid_IsActive() then
		-- Active raid
		-- Continue existing raid?
		-- TODO: Prompt dialog to continue raid		
	else
		-- No active raid
		-- Create new raid
		kLoot:Raid_Create()
	end
	-- Create active raid
end

--[[ Create a new raid instance in database
]]
function kLoot:Raid_Create()
	-- Verify role
	if not self:Role_IsAdmin() then
		self:Error('Raid_Create', 'Invalid permission to create raid.')
		return
	end
	local id = self:GetUniqueId(self.db.profile.raids)
	-- Rebuild roster
	self:Roster_Rebuild()
	-- Create empty raid table
	tinsert(self.db.profile.raids, {
		actors = self.roster.full,	
		id = id,
		time = time(),
		type = 'raid',
	})
	-- Bump active raid
	self.db.profile.settings.raid.active = id
end

--[[ Generate the initial raid roster
]]
function kLoot:Raid_GenerateRoster()
	local count, roster, currentTime, name, class, online = self:GetPlayerCount(), {}, time()
	if count == 1 then
		roster[UnitName('player')] = self:Actor_Create(UnitName('player'), UnitClass('player'), true, true, currentTime)
	else
		for i=1,count do
			name, _, _, _, class, _, _, online = GetRaidRosterInfo(i)
			roster[name] = self:Actor_Create(name, class, online and true or false, true, currentTime)
		end	
	end
	return roster
end

--[[ Get Raid by id or raid object
]]
function kLoot:Raid_Get(raid)
	if not raid then return end
	if type(raid) == 'string' then
		self:Debug('Raid_Get', 'type(raid) == string', raid, 1)
		raid = tonumber(raid)
	end
	if type(raid) == 'number' then
		self:Debug('Raid_Get', 'type(raid) == number', raid, 1)
		for i,v in pairs(self.db.profile.raids) do
			if v.id and v.id == raid then
				self:Debug('Raid_Get', 'Raid by id match found:', raid, v, 1)
				return v
			end
		end
	elseif type(raid) == 'table' then
		--self:Debug('Raid_Get', 'type(raid) == table', raid, 1)
		if raid.type and raid.type == 'raid' then
			self:Debug('Raid_Get', 'raid.type == raid', raid.type, 1)
			return raid
		end
	end
end

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

--[[ Update the raid roster
]]
function kLoot:Raid_UpdateRoster(raid)
	local raid = self:Raid_Get(raid or self.db.profile.settings.raid.active)
	if not raid then
		self:Debug('Raid_UpdateRoster', 'No raid found:', raid, 1)
		return
	end
	-- Rebuild roster
	self:Roster_Rebuild()
	-- Loop through full roster, update or add as needed
	for name,actor in pairs(self.roster.full) do
		if raid.actors[name] then
			self:Debug('Raid_UpdateRoster', 'Updating actor:', name, 1)
			self:Actor_Update(
				raid, 
				actor.name, 
				actor.class, 
				actor.events[#actor.events].online, 
				actor.events[#actor.events].inRaid, 
				actor.events[#actor.events].time,
				actor.guildNote) 
		else
			self:Debug('Raid_UpdateRoster', 'Creating actor:', name, 1)
			raid.actors[name] = self:Actor_Create(
				actor.name, 
				actor.class, 
				actor.events[#actor.events].online, 
				actor.events[#actor.events].inRaid, 
				actor.events[#actor.events].time,
				actor.guildNote)			
		end
	end
end

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
		type = 'actor',
	}
end

--[[ Get actor object in raid table
]]
function kLoot:Actor_Get(raid, actor)
	local raid = self:Raid_Get(raid)
	if not raid or not actor then return end
	if type(actor) == 'string' then
		if raid.actors[actor] then return raid.actors[actor] end
	elseif type(actor) == 'table' then
		if actor.type and actor.type == 'actor' then return actor end
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
				tinsert(actor.events, {
					inRaid = inRaid,
					online = online,
					time = time or time(),
				})
			end
		end
		-- Bump other values
		actor.name = name
		actor.class = class
		actor.guildNote = guildNote
		return true -- Found, return true
	end
end

--[[ Destroy an existing raid instance in database
TODO: Complete function
]]
function kLoot:Raid_Destroy()
	-- Invalidate current active raid
	self.db.profile.settings.raid.active = nil
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
	-- Send to Auction_Create
	self:Auction_Create(input)
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
	-- Send to Auction_Create
	self:Auction_Create(input)
end

--[[ Award an active auction
]]
function kLoot:Auction_Award(auction)
end

--[[ Create new auction
]]
function kLoot:Auction_Create(item)
	if not item then return end
	-- Validate role
	if (not self:Role_IsAdmin()) and (not self:Role_IsEditor()) then return end
	-- Parse item id
	local id = self:Item_Id(item)
	if not id then return end
	self:Debug('kLoot:Auction_Create', id, 3) 
	local auctionId = self:GetUniqueId(self.auctions)
	self:Debug('kLoot:Auction_Create', 'New auctionId', auctionId, 1)
end

--[[ Add vote to bid
]]
function kLoot:Bid_AddVote(bid)
end

--[[ Create new bid
]]
function kLoot:Bid_Create(auction)
end

function kLoot:Item_GetItemIdFromItemLink(link)
	if not link then return end
	self:Debug("FUNC: Item_GetItemIdFromItemLink, ItemLink: " .. link, 1)
	local found, _, itemString = string.find(link, "^|c%x+|H(.+)|h%[.*%]")
	if not itemString then return end
	local _, itemId = strsplit(":", itemString)	
	return itemId
end

--[[ Get item Id from item link, id, name
]]
function kLoot:Item_Id(item)
	-- Id
	if type(item) == 'number' then return item end
	-- Id (string type)
	if type(item) == 'string' and type(tonumber(item)) == 'number' then return tonumber(item) end
	-- Link
	local itemId = self:Item_GetItemIdFromItemLink(item)
	if type(item) == 'string' and itemId then return tonumber(itemId) end
	-- Item string
	local _, itemId = strsplit(":", item)
	if type(item) == 'string' and itemId then return tonumber(itemId) end
	local _, itemLink = GetItemInfo(item)
	itemId = self:Item_GetItemIdFromItemLink(itemLink)
	-- Name
	if itemLink and itemId then return tonumber(itemId) end
end

--[[ Get Role of player.
@[player] string (Default: 'player') - Player name
return string - Role assigned or nil
]]
function kLoot:Role_GetRole(player)
	player = player or UnitName('player')
end

--[[ Determine if a Player is assigned Administrator Role
@[player] string (Default: 'player') - Player name
return boolean - Result of role match
]]
function kLoot:Role_IsAdmin(player)
	player = player or UnitName('player')
	if not UnitExists(player) then return end
	return (GetNumGroupMembers() and UnitIsGroupLeader(player)) or (GetNumGroupMembers() == 0 and player == UnitName('player'))
end

--[[ Determine if a Player is assigned Editor Role
@[player] string (Default: 'player') - Player name
return boolean - Result of role match
]]
function kLoot:Role_IsEditor(player)
	player = player or UnitName('player')
	for i,v in pairs(self.db.profile.editors) do
		if v == player then return true end
	end
	return false
end

--[[ Determine if a player is assigned to a particular Role.
@[role] string (Default: 'administrator') - Full name or nickname of the role to check
@[player] string (Default: 'player') - Player name
return boolean - Result of role match for provided player
]]
function kLoot:Role_IsRole(role,player)
	role = role or 'administrator'
	player = player or UnitName('player')
	if role == 'administrator' or role == 'admin' then
		return self:Role_IsAdmin(player)
	elseif role == 'editor' then
		return self:Role_IsEditor(player)
	end
	return false
end

--[[ Assign role to a player.
@[role] string (Default: 'editor') - Full name or nickname of the role
@[player] string (Default: 'player') - Player name
return boolean - Success/failure
]]
function kLoot:Role_AddRole(role,player)
	role = role or 'editor'
	player = player or UnitName('player')
	if role == 'editor' then
		if not self:Role_IsEditor(player) then
			tinsert(self.db.profile.editors, player)			
		end
		return true
	end
	return false
end

--[[ Delete role from a player.
@[role] string (Default: 'editor') - Full name or nickname of the role
@[player] string (Default: 'player') - Player name
return boolean - Success/failure
]]
function kLoot:Role_DeleteRole(role,player)
	role = role or 'editor'
	player = player or UnitName('player')
	if role == 'editor' then
		if self:Role_IsEditor(player) then
			for i,v in pairs(self.db.profile.editors) do
				if v == player then
					tremove(self.db.profile.editors, i)
					return true
				end
			end
		end
	end	
	return false
end