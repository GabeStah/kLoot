local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random, tContains = table, table.insert, table.remove, wipe, sort, date, time, random, tContains
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Auction received
]]
function kLoot:Client_OnAuctionCreate(sender, id, itemId, raidId, duration)
	kLoot:Debug('Client_OnAuctionCreate', sender, id, itemId, raidId, duration, 3)
	-- Ignore self
	if kLoot:IsSelf(sender) then return end
	if not (kLoot:Role_IsAdmin(sender) or kLoot:Role_IsEditor(sender)) then
		kLoot:Error('Client_OnAuctionCreate', 'Auction sent from invalid sender: ', sender)
		return
	end
	-- Validate id
	if not id then
		kLoot:Error('Client_OnAuctionCreate', 'Auction sent with invalid id.')
		return
	end
	-- If auction exists, don't proceed
	if kLoot:Auction_Get(id) then
		kLoot:Debug('Client_OnAuctionCreate', 'Auction exists: ', id, 2)
		return
	end
	-- Create new entry for client
	kLoot:Auction_Create(itemId, raidId, id, duration)
end

--[[ Raid end
]]
function kLoot:Client_OnRaidEnd(sender, id)
	-- Ignore self
	if kLoot:IsSelf(sender) then return end
	if not (kLoot:Role_IsAdmin(sender) or kLoot:Role_IsEditor(sender)) then
		kLoot:Error('Client_OnRaidEnd', 'Raid sent from invalid sender: ', sender)
		return
	end
	-- Validate id
	if not id then
		kLoot:Error('Client_OnRaidEnd', 'Raid sent with invalid id.')
		return
	end
	kLoot:Debug('Client_OnRaidEnd', 'id: ', id, 3)
	-- Destroy raid
	kLoot:Raid_Destroy(id)
end

--[[ Raid start
]]
function kLoot:Client_OnRaidStart(sender, id)
	-- Ignore self
	if kLoot:IsSelf(sender) then return end
	if not (kLoot:Role_IsAdmin(sender) or kLoot:Role_IsEditor(sender)) then
		kLoot:Error('Client_OnRaidStart', 'Raid sent from invalid sender: ', sender)
		return
	end
	-- Validate id
	if not id then
		kLoot:Error('Client_OnRaidStart', 'Raid sent with invalid id.')
		return
	end
	-- If raid exists, don't proceed
	if kLoot:Raid_Get(id) then return end
	-- Create new entry for client
	kLoot:Raid_Create(id)
end

--[[ Update role of player
]]
function kLoot:Client_OnRole(sender, player, role)
	kLoot:Debug('Client_OnRole', sender, player, role, 2)
	if not player then return end
	-- Validate sender as admin
	if not kLoot:Role_IsAdmin(sender) then return end
	-- Check if update required
	if role then
		kLoot:Role_Add(role, player)
	else -- No role, remove role
		kLoot:Role_Delete(role, player)
	end
end