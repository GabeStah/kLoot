local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random, tContains = table, table.insert, table.remove, wipe, sort, date, time, random, tContains
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Retrieve the prefix valid
]]
function kLoot:Comm_GetPrefix(text)
	if not text or not (type(text) == 'string') then return end
	local prefix, commType = strsplit('-', text)
	if not prefix or not commType then return end
	return prefix, commType
end

--[[ Process comm receiving
]]
function kLoot:OnCommReceived(prefix, serialObject, channel, sender)
	if not self:Comm_ValidatePrefix(prefix) then
		self:Error('OnCommReceived', 'Invalid prefix received, cannot continue: ', prefix)
		return
	end
	if not self:Comm_ValidateChannel(channel) then
		self:Error('OnCommReceived', 'Invalid channel received, cannot continue: ', channel)
		return
	end
	local success, command, data = self:Deserialize(serialObject)
	if success then
		-- TODO: Validate sender (possibly from raid?)
		self:Debug('OnCommReceived', prefix, serialObject, channel, sender, 2)
		local prefix, commType = self:Comm_GetPrefix(prefix)
		self:Comm_Receive(command, data, sender, commType)
	end
end

--[[ Receive a comm message
]]
function kLoot:Comm_Receive(command, sender, commType, ...)
	if not command or not data then return end
	commType = commType or 'c'
	local name = ('Client_On%s'):format(command)	
	if commType == 's' then name = ('Server_On%s'):format(command) end
	if self[name] then
		self[name](sender, ...)
	end	
end

--[[ Send a comm message
]]
function kLoot:Comm_Send(command, commType, channel, ...)
	if not command or not data then return end
	if commType and type(commType) == 'string' then commType = strlower(strsub(commType, 1, 1)) end
	commType = commType or 'c'
	channel = self:Comm_ValidateChannel(channel) and channel or self:GetTableEntry(self.comm.validChannels)
	local prefix = ('%s-%s'):format(self.comm.prefix, commType)
	self:SendCommMessage(prefix, self:Serialize(command, data), channel)
	self:Debug('Comm_Send', prefix, command, data, channel, 2)
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