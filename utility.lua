local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot
function kLoot:ColorizeSubstringInString(subject, substring, r, g, b)
	local t = {};
	for i = 1, strlen(subject) do
		local iStart, iEnd = string.find(strlower(subject), strlower(substring), i, strlen(substring) + i - 1)
		if iStart and iEnd then
			for iTrue = iStart, iEnd do
				t[iTrue] = true;
			end
		else
			if not t[i] then
				t[i] = false;
			end
		end
	end
	local sOut = '';
	local sColor = self:RGBToHex(r*255,g*255,b*255);
	for i = 1, strlen(subject) do
		if t[i] == true then
			sOut = ('%s|CFF%s%s|r'):format(sOut, sColor, strsub(subject, i, i))
		else
			sOut = ('%s%s'):format(sOut, strsub(subject, i, i))
		end
	end
	return strlen(sOut) > 0 and sOut or nil
end
function kLoot:GetPlayerCount(groupType)
	groupType = groupType or 'raid';
	-- Check if post-MoP
	if groupType == 'raid' then
		return GetNumGroupMembers() - 1;
	else
		return GetNumSubgroupMembers() - 1;
	end
end
function kLoot:Debug(...)
	local isDevLoaded = IsAddOnLoaded('_Dev')
	local isSpewLoaded = IsAddOnLoaded('Spew')
	local prefix ='kLootDebug: '
	local threshold = select(select('#', ...), ...) or 3
	-- CHECK IF _DEV exists
	if self.db.profile.debug.enabled then
		if (threshold >= kLoot.db.profile.debug.threshold) then
			if isSpewLoaded then
				Spew(...)
			elseif isDevLoaded then
				dump(prefix, ...)
			else
				self:Print(ChatFrame1, ('%s%s'):format(prefix,...))			
			end
		end
	end
end
function kLoot:Error(...)
	if not ... then return end
	self:Print(ChatFrame1, ('Error: %s - %s'):format(...))
end
function kLoot:OnUpdate(elapsed)
	if not self.db.profile.debug.enableTimers then return end
	local updateType = 'core'
	local time, i = GetTime()
	self.update[updateType].timeSince = (self.update[updateType].timeSince or 0) + elapsed
	if (self.update[updateType].timeSince > self.db.profile.settings.update[updateType].interval) then	
		for i = #self.timers, 1, -1 do 
			-- Check if repeater
			if self.timers[i].loop then
				self.timers[i].elapsed = (self.timers[i].elapsed or 0) + self.update[updateType].timeSince
				if self.timers[i].elapsed >= (self.timers[i].time or 0) then
					local cancelTimer = false;
					-- Check if func is string
					if type(self.timers[i].func) == 'function' then
						if self.timers[i].args then
							cancelTimer = self.timers[i].func(unpack(self.timers[i].args));
						else
							cancelTimer = self.timers[i].func();
						end
					else
						if self.timers[i].args then
							cancelTimer = self[self.timers[i].func](unpack(self.timers[i].args));
						else
							cancelTimer = self[self.timers[i].func]();
						end
					end
					self.timers[i].elapsed = 0;
					-- Check if cancel required
					if cancelTimer then
						self:Debug("REMOVE FUNC", 1)
						tremove(self.timers, i)
					end
				end
			else
				if self.timers[i].time then
					if self.timers[i].time <= time then
						-- One-time exec, remove
						if type(self.timers[i].func) == 'function' then
							if self.timers[i].args then
								self.timers[i].func(unpack(self.timers[i].args));
							else
								self.timers[i].func();
							end
						else
							if self.timers[i].args then
								self[self.timers[i].func](unpack(self.timers[i].args));
							else
								self[self.timers[i].func]();
							end
						end
						tremove(self.timers, i)
					end
				end
			end
		end
		self.update[updateType].timeSince = 0
	end
end
function kLoot:ColorToHex(color)
	if not color or not type(color) == 'table' then return end
	return string.format("%02x%02x%02x", 
		self:Round(color.r * 255),
		self:Round(color.g * 255),
		self:Round(color.b * 255)
	)
end
function kLoot:RGBToHex(r, g, b)
	if type(r) == 'table' then
		g = r.g
		b = r.b
		r = r.r		
	end
	r = r <= 255 and r >= 0 and r or 0
	g = g <= 255 and g >= 0 and g or 0
	b = b <= 255 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r, g, b)
end
function kLoot:Round(value, decimal)
	if (decimal) then
		return math.floor((value * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(value+0.5)
	end
end
function kLoot:SplitString(subject, delimiter)
	local result = { }
	local from  = 1
	local delim_from, delim_to = string.find( subject, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( subject, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find( subject, delimiter, from  )
	end
	table.insert( result, string.sub( subject, from  ) )
	return result
end
function kLoot:GetPlayerCount()
	return (GetNumGroupMembers() > 0) and GetNumGroupMembers() or 1
end
function kLoot:GetUniqueId(data)
	local newId
	local isValidId = false
	while isValidId == false do
		local matchFound = false
		newId = (math.random(0,2147483647) * -1)
		for i,val in pairs(data) do
			if val.id == newId then matchFound = true end
		end
		if not matchFound then isValidId = true end
	end
	return newId
end
