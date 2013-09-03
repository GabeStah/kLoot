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
	local texture = frame.texture or frame:CreateTexture(nil,'BACKGROUND')
	texture.objectType = 'Texture'
	color = color or frame.color or {r=0,g=0,b=0,a=0.8}
	texture:SetTexture(color.r, color.g, color.b, color.a)
	texture:SetAllPoints(frame)
	frame.texture = texture
end

--[[ Update texture for frame
]]
function kLoot:View_Texture_Update(frame, color)
	if not frame or not frame.texture then return end
	color = color or frame.color
	if not color then return end
	frame.texture:SetTexture(color.r, color.g, color.b, color.a)
	frame.texture:SetAllPoints(frame)
end