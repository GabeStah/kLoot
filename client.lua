local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random, tContains = table, table.insert, table.remove, wipe, sort, date, time, random, tContains
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[
params
sender - player sending comm
commType - 'c' or 's' for client or server communication
]]

--[[ Auction received
]]
function kLoot:Client_OnAuctionCreate(sender, isClient, id, itemId, raidId, duration)
	kLoot:Debug('Client_OnAuctionCreate', sender, id, itemId, raidId, duration, 3)
	-- Ignore self
	if kLoot:Utility_IsSelf(sender) then return end
	if not (kLoot:Role_IsAdmin(sender) or kLoot:Role_IsEditor(sender)) then
		kLoot:Error('Client_OnAuctionCreate', ('Auction sent from invalid sender: %s'):format(tostring(sender)))
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
	kLoot:Auction_Create(itemId, raidId, id, duration, isClient)
end

--[[ Bid cancelled
]]
function kLoot:Client_OnBidCancel(sender, isClient, id, auctionId)
	kLoot:Debug('Client_OnBidCancel', sender, id, 3)
	-- Ignore self
	if kLoot:Utility_IsSelf(sender) then return end
	-- Validate id
	if not id then
		kLoot:Error('Client_OnBidCancel', 'Bid cancellation sent with invalid id.')
		return
	end
	-- If bid doesn't exist, don't proceed
	if not kLoot:Bid_Get(id, auctionId) then
		kLoot:Debug('Client_OnBidCancel', ("Bid [%s] doesn't exist, no cancel needed."):format(id), 2)
		return
	end
	-- Validate player
	if not kLoot:Bid_IsFromPlayer(id, auctionId, sender) then
		kLoot:Error('Client_OnBidCancel', 'Cannot cancel Bid not owned by sending player.')
		return
	end	
	-- Cancel bid
	kLoot:Bid_Cancel(id, auctionId, isClient)
end

--[[ Bid receieved
]]
function kLoot:Client_OnBidCreate(sender, isClient, id, auctionId, items, player, bidType, specialization)
	kLoot:Debug('Client_OnBidCreate', sender, id, auctionId, items, player, bidType, specialization, 3)
	-- Ignore self
	if kLoot:Utility_IsSelf(sender) then return end
	-- Validate id
	if not id then
		kLoot:Error('Client_OnBidCreate', 'Bid sent with invalid id.')
		return
	end
	-- If bid exists, don't proceed
	if kLoot:Bid_Get(id, auctionId) then
		kLoot:Debug('Client_OnBidCreate', 'Bid exists: ', id, 2)
		return
	end
	-- Create new entry for client
	kLoot:Bid_Create(id, auctionId, items, player, bidType, specialization, isClient)	
end

--[[ Raid create
]]
function kLoot:Client_OnRaidCreate(sender, isClient, id)
	-- Ignore self
	if kLoot:Utility_IsSelf(sender) then return end
	if not (kLoot:Role_IsAdmin(sender) or kLoot:Role_IsEditor(sender)) then
		kLoot:Error('Client_OnRaidCreate', ('Raid sent from invalid sender: %s'):format(tostring(sender)))
		return
	end
	-- Validate id
	if not id then
		kLoot:Error('Client_OnRaidCreate', 'Raid sent with invalid id.')
		return
	end
	-- If raid exists, don't proceed
	if kLoot:Raid_Get(id) then return end
	-- Create new entry for client
	kLoot:Raid_Create(id, isClient)
end

--[[ Raid destroy
]]
function kLoot:Client_OnRaidDestroy(sender, isClient, id)
	-- Ignore self
	if kLoot:Utility_IsSelf(sender) then return end
	if not (kLoot:Role_IsAdmin(sender) or kLoot:Role_IsEditor(sender)) then
		kLoot:Error('Client_OnRaidDestroy', ('Raid sent from invalid sender: %s'):format(tostring(sender)))
		return
	end
	-- Validate id
	if not id then
		kLoot:Error('Client_OnRaidDestroy', 'Raid sent with invalid id.')
		return
	end
	kLoot:Debug('Client_OnRaidDestroy', 'id: ', id, 3)
	-- Destroy raid
	kLoot:Raid_Destroy(id, isClient)
end

--[[ Add role to player
]]
function kLoot:Client_OnRoleAdd(sender, isClient, role, player)
	if not role or not player then return end
	-- Validate sender as admin
	if not kLoot:Role_IsAdmin(sender) then return end
	kLoot:Debug('Client_OnRoleAdd', sender, role, player, 2)	
	kLoot:Role_Add(role, player, isClient)
end

--[[ Delete role of player
]]
function kLoot:Client_OnRoleDelete(sender, isClient, role, player)
	if not role or not player then return end
	-- Validate sender as admin
	if not kLoot:Role_IsAdmin(sender) then return end
	kLoot:Debug('Client_OnRoleDelete', sender, role, player, 2)
	kLoot:Role_Delete(role, player, isClient)
end

--[[ Role response sent
]]
function kLoot:Client_OnRoleResponse(sender, isClient, response)
	if not response then return end
	-- Validate sender as admin
	if not kLoot:Role_IsAdmin(sender) then return end
	kLoot:Debug('Client_OnRoleResponse', sender, response, 2)
	kLoot:Role_UpdateFromResponse(response)
end