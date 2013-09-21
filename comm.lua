local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random, tContains = table, table.insert, table.remove, wipe, sort, date, time, random, tContains
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Trigger when auction is created
]]
function kLoot:Comm_AuctionCreate(id, itemId, raidId, duration)
	if not id or not self:Auction_Get(id) or not raidId or not itemId then return end
	self:Comm_Send('AuctionCreate', 'c', 'RAID', id, itemId, raidId, duration)
end

--[[ Trigger when Bid is cancelled
]]
function kLoot:Comm_BidCancel(id, auctionId)
	if not id then return end
	self:Comm_Send('BidCancel', 'c', 'RAID', id, auctionId)
end

--[[ Trigger when auction is created
]]
function kLoot:Comm_BidCreate(id, auctionId, items, player, bidType, specialization, flags)
	if not id or not self:Bid_Get(id, auctionId) or not player or not bidType then return end
	self:Comm_Send('BidCreate', 'c', 'RAID', id, auctionId, items, player, bidType, specialization, flags)
end

--[[ Retrieve the prefix valid
]]
function kLoot:Comm_GetPrefix(text)
	if not text or not (type(text) == 'string') then return end
	local prefix, commType = strsplit('-', text)
	if not prefix or not commType then return end
	return prefix, commType
end

--[[ Trigger when raid is created
]]
function kLoot:Comm_RaidCreate(id)
	if not id or not self:Raid_Get(id) then return end
	self:Comm_Send('RaidCreate', 'c', 'RAID', id)
end

--[[ Trigger when raid is destroyed
]]
function kLoot:Comm_RaidDestroy(id)
	if not id or not self:Raid_Get(id) then return end
	self:Comm_Send('RaidDestroy', 'c', 'RAID', id)
end

--[[ Receive a comm message
]]
function kLoot:Comm_Receive(command, sender, commType, data)
	if not command then return end
	commType = commType or 'c'
	local name = ('Client_On%s'):format(command)	
	if commType == 's' then name = ('Server_On%s'):format(command) end
	self:Debug('Comm_Receive', 'Communication received.', 'Func: ', name, command, sender, commType, 2)
	if self[name] then
		self[name](nil, sender, self:Comm_TypeIsClient(commType), select(2, self:Deserialize(data)))
	else
		self:Debug('Comm_Receive', 'No matching function: ', name, self[name], 2)
	end	
end

--[[ Register comm prefixes
]]
function kLoot:Comm_Register()
	for i,v in pairs(self.comm.validCommTypes) do
		self:RegisterComm(('%s-%s'):format(self.comm.prefix, v))
	end
end

--[[ Trigger when raid is created
]]
function kLoot:Comm_RoleAdd(role, player)
	if not role or not player then return end
	self:Comm_Send('RoleAdd', 'c', 'RAID', role, player)
end

--[[ Trigger when raid is created
]]
function kLoot:Comm_RoleDelete(role, player)
	if not role or not player then return end
	self:Comm_Send('RoleDelete', 'c', 'RAID', role, player)
end

--[[ Trigger when role response is generated
]]
function kLoot:Comm_RoleResponse()
	-- Create role>player list string
	local sync = self:Role_GetResponseString()
	if sync then
		self:Comm_Send('RoleResponse', 'c', 'RAID', sync)
	end
end

--[[ Send a comm message
]]
function kLoot:Comm_Send(command, commType, channel, ...)
	if not command then return end
	if commType and type(commType) == 'string' then commType = strlower(strsub(commType, 1, 1)) end
	commType = commType or 'c'
	channel = self:Comm_ValidateChannel(channel) and channel or self:Utility_GetTableEntry(self.comm.validChannels)
	local prefix = ('%s-%s'):format(self.comm.prefix, commType)
	if self:InDebug() and (channel == 'RAID' or channel == 'GUILD') and self:Utility_IsSelf('Kulltest') then
		channel = 'PARTY' -- Set PARTY default channel for starter account
	elseif self:InDebug() and channel == 'RAID' and self:Utility_GetPlayerCount() == 1 then
		channel = 'GUILD' -- Set GUILD default channel for debug purposes if not in raid
	end
	self:SendCommMessage(prefix, self:Serialize(command, self:Serialize(...)), channel)
	self:Debug('Comm_Send', prefix, command, channel, 2)
end

--[[ Determine if commType is client
]]
function kLoot:Comm_TypeIsClient(commType)
	return (commType and commType == 'c')
end

--[[ Check if channel is valid
]]
function kLoot:Comm_ValidateChannel(text)
	if not text or not (type(text) == 'string') then return end
	return tContains(self.comm.validChannels, text)
end

--[[ Check if prefix is valid
]]
function kLoot:Comm_ValidatePrefix(text)
	if not text or not (type(text) == 'string') then return end
	local prefix, commType = self:Comm_GetPrefix(text)
	if prefix ~= self.comm.prefix then return false end
	return tContains(self.comm.validCommTypes, commType)
end