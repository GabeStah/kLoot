local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create square frame button
]]
function kLoot:View_SquareButton_Create(name, parent, headerText, subText, category, defaultColor, selectedColor, hoverColor)
	self:Debug('View_SquareButton_Create', 'name: ', name, 'parent: ', parent, 2)
	local frame = self:View_Button_Create(name, parent, 80, 80, defaultColor, selectedColor, hoverColor)
	-- Flags
	frame.objectType = 'SquareButton'	
	
	-- Colors
	self:View_SetColor(frame, 'default', defaultColor)
	self:View_SetColor(frame, 'selected', selectedColor)
	self:View_SetColor(frame, 'hover', hoverColor)	
	
	-- Events
	frame.addEvent('OnMouseDown', function()
		self:View_SquareButton_ResetSelections(parent, category)
	end, 1)	-- Add this to first index, to occur prior to normal button events
	
	-- Texts
	local topText = self:View_FontString_Create('HeaderText', frame, headerText)
	topText:SetFont([[Interface\AddOns\kLoot\media\fonts\DORISPP.TTF]], 50)
	
	local bottomText = self:View_FontString_Create('BottomText', frame, subText)
	bottomText:SetFont([[Interface\AddOns\kLoot\media\fonts\DORISPP.TTF]], 20)
	bottomText:SetPoint('BOTTOM')
	
	-- Methods
	frame.setFont = function(size, textType, path)
		textType = textType or 'header'
		path = path or [[Interface\AddOns\kLoot\media\fonts\DORISPP.TTF]]
		size = size or 50
		if textType == 'header' then
			topText:SetFont(path, size)
		elseif textType == 'bottom' then
			bottomText:SetFont(path, size)
		end
	end	
	
	frame:ClearAllPoints()
	frame:SetAllPoints()
	return frame
end

--[[ Update selection values for all SquareButtons in parent of type category
]]
function kLoot:View_SquareButton_ResetSelections(parent, category)
	if not parent or not parent:GetNumChildren() then return end
	category = category or 'default'
	for i,v in ipairs({parent:GetChildren()}) do
		if v.objectType and v.objectType == 'SquareButton' then
			v.selected = false
			self:View_UpdateColor(v) -- Reset color
		else
			-- Check for children and recursively loop
			if v:GetNumChildren() then
				self:View_SquareButton_ResetSelections(v, category)
			end
		end
	end
end