local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create a basic font string attached to the parent item
]]
function kLoot:View_FontString_Create(name, parent, text, color)
	if not parent then return end
	name = self:View_Name(name, parent)
	color = color or {r=1,g=1,b=1,a=1}
	local object = _G[name] or parent:CreateFontString(name)
	object.objectType = 'FontString'
	object:SetFont([[Interface\AddOns\kLoot\media\fonts\DORISPP.TTF]], 14)
	object:SetJustifyV('TOP')
	object:SetText(text)
	object:SetTextColor(color.r, color.g, color.b, color.a)
	object:SetPoint('CENTER')
	return object
end