local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Assign role to a player.
@[role] string (Default: 'editor') - Full name or nickname of the role
@[player] string (Default: 'player') - Player name
return boolean - Success/failure
]]
function kLoot:Role_Add(role, player, isClient)
	role = role or 'editor'
	player = player or UnitName('player')
	-- Check if role exists
	if role == 'editor' and not self:Role_IsEditor(player) then
		if not self:Role_IsEditor(player) then
			self.db.profile.editors[player] = {
				player = player,
				selected = false,
			}
		end
	end
	if not isClient then
		-- Send comm
		self:Comm_RoleAdd(role, player)
	end
end

--[[ Delete role from a player.
@[role] string (Default: 'editor') - Full name or nickname of the role
@[player] string (Default: 'player') - Player name
return boolean - Success/failure
]]
function kLoot:Role_Delete(role, player, isClient)
	role = role or 'editor'
	player = player or UnitName('player')
	if role == 'editor' then
		self.db.profile.editors[player] = nil
	end	
	if not isClient then
		-- Send comm
		self:Comm_RoleDelete(role, player)
	end
end

--[[ Get Role of player.
@[player] string (Default: 'player') - Player name
return string - Role assigned or nil
]]
function kLoot:Role_Get(player)
	player = player or UnitName('player')
	if self:Role_IsAdmin(player) then
		return 'admin'
	elseif self:Role_IsEditor(player) then
		return 'editor'
	end
end

--[[ Get sync string
]]
function kLoot:Role_GetResponseString()
	local data
	for i,v in pairs(self.db.profile.editors) do
		data = data and ('%s,e|%s'):format(data,v.player) or ('e|%s'):format(v.player)
	end
	return data
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
	if self.db.profile.editors[player] then return true end
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

--[[ Update from synced response string
]]
function kLoot:Role_UpdateFromResponse(response)
	local roles = self:Utility_SplitString(response, ',')
	local role, player
	for i,v in pairs(roles) do
		role, player = strsplit('|', v)
		if role and player and role == 'e' then
			if not self:Role_IsEditor(player) then
				self:Role_Add('editor', player, true)
			end
		end
	end
end