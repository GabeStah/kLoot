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
	
	frame:ClearAllPoints()
	frame:SetAllPoints()
	return frame
end

--[[ Create basic button frame
]]
function kLoot:View_Button_Create(name, parent, width, height, defaultColor, selectedColor, hoverColor)
	self:Debug('View_Button_Create', 'name: ', name, 'parent: ', parent, 2)
	width = width or 80
	height = height or 80
	local frame = self:View_Frame_Create(name, parent, width, height, defaultColor)
	-- Flags
	frame.objectType = 'Button'
	frame.selected = false		
	
	-- Colors
	self:View_SetColor(frame, 'default', defaultColor)
	self:View_SetColor(frame, 'selected', selectedColor)
	self:View_SetColor(frame, 'hover', hoverColor)
		
	-- Events
	frame.addEvent('OnEnter', function()
		self:View_UpdateColor(frame, 'OnEnter')
	end)	
	frame.addEvent('OnLeave', function()
		self:View_UpdateColor(frame, 'OnLeave')
	end)
	frame.addEvent('OnMouseDown', function()
		frame.selected = not frame.selected
		self:View_UpdateColor(frame, 'OnMouseDown')
	end)
	
	-- Set point
	frame:SetPoint('CENTER')
	
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