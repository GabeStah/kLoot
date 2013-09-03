local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create square frame button
]]
function kLoot:View_SquareButton_Create(name, parent, headerText, subText, category, standardColor, selectedColor, hoverColor)
	self:Debug('View_SquareButton_Create', 'name: ', name, 'parent: ', parent, 2)
	local frame = self:View_Frame_Create(name, parent, 80, 80, standardColor or {r=0,g=0,b=0,a=0.8})
	frame.category = category or 'default'
	frame.objectType = 'SquareButton'
	frame.selected = false
	frame.color = standardColor or {r=0,g=0,b=0,a=0.8}
	frame.standardColor = standardColor or {r=0,g=0,b=0,a=0.8}
	frame.selectedColor = selectedColor or {r=0,g=1,b=0,a=0.8}
	frame.hoverColor = hoverColor or {r=1,g=1,b=1,a=0.8}

	frame:SetScript('OnMouseDown', function(object)
		self:View_SquareButton_ResetSelections(parent, category)
		object.selected = not object.selected
		self:View_UpdateColor(object, 'OnMouseDown')		
	end)
	
	frame:SetScript('OnEnter', function(object)
		self:View_UpdateColor(object, 'OnEnter')
	end)
	frame:SetScript('OnLeave', function(object)
		self:View_UpdateColor(object, 'OnLeave')
	end)
	
	local topText = self:View_FontString_Create('HeaderText', frame, headerText)
	topText:SetFont([[Interface\AddOns\kLoot\media\fonts\DORISPP.TTF]], 50)
	
	local bottomText = self:View_FontString_Create('BottomText', frame, subText)
	bottomText:SetFont([[Interface\AddOns\kLoot\media\fonts\DORISPP.TTF]], 20)
	bottomText:SetPoint('BOTTOM')
	
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