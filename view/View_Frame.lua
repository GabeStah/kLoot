local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create a basic frame
]]
function kLoot:View_Frame_Create(name, parent, width, height, color)
	name = self:View_Name(name, parent)
	self:Debug('View_Frame_Create', 'name: ', name, 'parent: ', parent, 2)
	local frame = _G[name] or CreateFrame('Frame', name, parent or UIParent)
	local width = width or 500
	local height = height or 350
	frame.objectType = 'Frame'
	frame.color = color or {r=0,g=0,b=0,a=0.8}

	frame:SetWidth(width)
	frame:SetHeight(height)
	frame.margin = 4
	
	-- Create background texture
	self:View_Texture_Create(frame, frame.color)
	
	frame:Show()
	return frame
end

--[[ Retrieve the height of a frame
]]
function kLoot:View_Frame_GetHeight(frame)
	if not frame then return end
	return frame:GetHeight()
end

--[[ Retrieve the width of a frame
]]
function kLoot:View_Frame_GetWidth(frame)
	if not frame then return end
	return frame:GetWidth()
end