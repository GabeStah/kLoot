local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Colorize part of a string
]]
function kLoot:Utility_ColorizeSubstringInString(subject, substring, r, g, b)
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
	local sColor = self:Color_Get(r*255,g*255,b*255, nil, 'hex');
	for i = 1, strlen(subject) do
		if t[i] == true then
			sOut = ('%s|CFF%s%s|r'):format(sOut, sColor, strsub(subject, i, i))
		else
			sOut = ('%s%s'):format(sOut, strsub(subject, i, i))
		end
	end
	return strlen(sOut) > 0 and sOut or nil
end

--[[ Destroy all entries in a table, preserving table memory slot
]]
function kLoot:Utility_DestroyTable(table)
	for i,v in pairs(table) do table[i] = nil end
end

--[[ Generate a unique identifier
]]
function kLoot:Utility_GenerateUniqueId()
	local id = {}
	local characters = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 
		'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 
		's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', 
		'1', '2', '3', '4', '5', '6', '7', '8', '9'
	}
	local singlet
	for i=1,self.uniqueIdLength or 8 do
		case = math.random(1,2)
		char = math.random(1,#characters)
		if case == 1 then
			singlet = string.upper(characters[char])
		else
			singlet = characters[char]
		end
		table.insert(id, case == 1 and string.upper(characters[char]) or characters[char])
	end
	return(table.concat(id))
end	

--[[ Retrieve the player count in the party
]]
function kLoot:Utility_GetPlayerCount()
	return (GetNumGroupMembers() > 0) and GetNumGroupMembers() or 1
end

--[[ Retrieve specialization list for player
]]
function kLoot:Utility_GetSpecializations()
	local specs
	for i=1,GetNumSpecializations() do
		local id, name, description, icon, background, role = GetSpecializationInfo(i)
		specs = specs or {}
		if name then
			tinsert(specs, {
				name = name,
				icon = icon,
				role = role,
			})
		end
	end
	return specs
end

--[[ Retrieve the X entry of a non-indexed table
]]
function kLoot:Utility_GetTableEntry(data, num, getIndex)
	if not data or not type(data) == 'table' then return end
	num = num or 1
	local count = 0
	for i,v in pairs(data) do
		count = count + 1
		if num == count then
			if getIndex then return i else return v end
		end
	end
end

--[[ Determine if number if integer (whole)
]]
function kLoot:Utility_IsInteger(value)
	return math.floor(value) == value
end

--[[ Determine if player name is current player
]]
function kLoot:Utility_IsSelf(player)
	return (UnitName(player) == UnitName('player'))
end

--[[ Compare two tables
]]
function kLoot:Utility_MatchTables(tbl1, tbl2)
	for k,v in pairs(tbl1) do
		if (type(v) == 'table' and type(tbl2[k]) == 'table') then
			if (not self:Utility_TableCompare(v, tbl2[k])) then return false end
		else
			if (v ~= tbl2[k]) then return false end
		end
	end
	for k,v in pairs(tbl2) do
		if (type(v) == 'table' and type(tbl1[k]) == 'table') then
			if (not self:Utility_TableCompare(v, tbl1[k])) then return false end
		else
			if (v ~= tbl1[k]) then return false end
		end
	end
	return true
end

--[[ Round a number
]]
function kLoot:Utility_Round(value, decimal)
	if (decimal) then
		return math.floor((value * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(value+0.5)
	end
end

--[[ Split a string into a table
]]
function kLoot:Utility_SplitString(subject, delimiter)
	local result
	local from  = 1
	local delim_from, delim_to = string.find( subject, delimiter, from  )
	while delim_from do
		result = result or {}
		table.insert( result, string.sub( subject, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find( subject, delimiter, from  )
	end
	table.insert( result, string.sub( subject, from  ) )
	return result
end

--[[ Get difference in timestamps
]]
function kLoot:Utility_TimestampDiff(time1, time2, interval)
	if not time1 then return end
	interval = interval or 'second'	
	time2 = time2 or time()
	if not (type(time1) == 'number') then time1 = tonumber(time1) end	
	if not (type(time2) == 'number') then time2 = tonumber(time2) end	
	local diff = time2 - time1
	if interval == 'second' then
		return diff
	elseif interval == 'minute' then
		return diff / 60
	elseif interval == 'hour' then
		return diff / (60*60)
	elseif interval == 'day' then
		return diff / (60*60*24)
	end
end