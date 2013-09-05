local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create texture for frame
]]
function kLoot:View_Texture_Create(frame, color)
	if not frame then return end
	local object = frame.texture or frame:CreateTexture(nil,'BACKGROUND')
	object.objectType = 'Texture'
	self:View_SetColor(object, 'default', color)
	color = self:Color_Get(self:View_GetColor(object, 'default'))
	object:SetTexture(color.r, color.g, color.b, color.a)
	object:SetAllPoints(frame)
	frame.texture = object
end

--[[ Update texture for frame
]]
function kLoot:View_Texture_Update(frame, color)
	if not frame or not frame.texture then return end
	color = self:Color_Get(color) or self:Color_Get(self:View_GetColor(object, 'default'))
	if not color then return end
	frame.texture:SetTexture(color.r, color.g, color.b, color.a)
	frame.texture:SetAllPoints(frame)
end