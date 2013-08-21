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
	self:Comm_Send('AuctionCreate', nil, 'RAID', id, itemId, raidId, duration)
end

--[[ Retrieve the prefix valid
]]
function kLoot:Comm_GetPrefix(text)
	if not text or not (type(text) == 'string') then return end
	local prefix, commType = strsplit('-', text)
	if not prefix or not commType then return end
	return prefix, commType
end

--[[ Trigger when raid ends
]]
function kLoot:Comm_RaidEnd(id)
	if not id or not self:Raid_Get(id) then return end
	self:Comm_Send('RaidEnd', nil, 'RAID', id)
end

--[[ Trigger when raid starts
]]
function kLoot:Comm_RaidStart(id)
	if not id or not self:Raid_Get(id) then return end
	self:Comm_Send('RaidStart', nil, 'RAID', id)
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
		self[name](nil, sender, select(2, self:Deserialize(data)))
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

--[[ Send a comm message
]]
function kLoot:Comm_Send(command, commType, channel, ...)
	if not command then return end
	if commType and type(commType) == 'string' then commType = strlower(strsub(commType, 1, 1)) end
	commType = commType or 'c'
	channel = self:Comm_ValidateChannel(channel) and channel or self:GetTableEntry(self.comm.validChannels)
	local prefix = ('%s-%s'):format(self.comm.prefix, commType)
	if self:InDebug() and channel == 'RAID' and self:GetPlayerCount() == 1 then
		channel = 'GUILD' -- Set GUILD default channel for debug purposes if not in raid
	end
	self:SendCommMessage(prefix, self:Serialize(command, self:Serialize(...)), channel)
	self:Debug('Comm_Send', prefix, command, channel, 2)
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