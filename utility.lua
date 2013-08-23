local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot
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
	local sColor = self:Utility_RGBToHex(r*255,g*255,b*255);
	for i = 1, strlen(subject) do
		if t[i] == true then
			sOut = ('%s|CFF%s%s|r'):format(sOut, sColor, strsub(subject, i, i))
		else
			sOut = ('%s%s'):format(sOut, strsub(subject, i, i))
		end
	end
	return strlen(sOut) > 0 and sOut or nil
end

function kLoot:Utility_IsSelf(player)
	return (UnitName(player) == UnitName('player'))
end

function kLoot:Utility_ColorToHex(color)
	if not color or not type(color) == 'table' then return end
	return string.format("%02x%02x%02x", 
		self:Utility_Round(color.r * 255),
		self:Utility_Round(color.g * 255),
		self:Utility_Round(color.b * 255)
	)
end
function kLoot:Utility_DestroyTable(table)
	for i,v in pairs(table) do
		table[i] = nil
	end
end
function kLoot:Utility_RGBToHex(r, g, b)
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
function kLoot:Utility_Round(value, decimal)
	if (decimal) then
		return math.floor((value * 10^decimal) + 0.5) / (10^decimal)
	else
		return math.floor(value+0.5)
	end
end
function kLoot:Utility_SplitString(subject, delimiter)
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
function kLoot:Utility_GetPlayerCount()
	return (GetNumGroupMembers() > 0) and GetNumGroupMembers() or 1
end

--[[ Get a unique identifier
]]
function kLoot:Utility_GetUniqueId()
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