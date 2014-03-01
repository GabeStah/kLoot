local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create HybridScrollFrame
]]
function kLoot:View_HybridScrollFrame_Create(name, parent, width, height, defaultColor)
	self:Debug('View_HybridScrollFrame_Create', 'name: ', name, 'parent: ', parent, 2)
	local frame = self:View_Frame_Create(name, parent, width, height, defaultColor, 'HybridScrollFrameTemplate', 'ScrollFrame')
	
	-- Events
	frame:addEvent('OnEnter', function()
		self:Debug('View_HybridScrollFrame_OnEnter', 2)
	end)
	
	-- Flags
	frame.objectType = 'HybridScrollFrame'
	frame.scrollOffset = 0
	frame.stepSize = 20
	frame.buttonHeight = 20
	frame.update = self:View_HybridScrollFrame_Update(frame)
	
	-- Colors
	self:View_SetColor(frame, 'default', defaultColor)
	
	-- Texts
	
	-- Methods
	frame.getScrollOffset = function(self)
		return self.scrollOffset
	end
	frame.setScrollOffset = function(self, offset)
		self.scrollOffset = offset
	end
	
	-- Color redraw
	self:View_UpdateColor(frame)
	
	-- ScrollBar
	frame.scrollBar = self:View_HybridScrollFrameScrollBar_Create('ScrollBar', frame)
	--local scrollMax = height - 400
	frame.scrollBar:SetOrientation("VERTICAL");
	frame.scrollBar:SetSize(16, self:View_Frame_GetHeight(parent))
	frame.scrollBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	--[[
	frame.scrollBar:SetMinMaxValues(0, 5)
	frame.scrollBar:SetValue(0)
	frame.scrollBar:SetScript("OnValueChanged", function(self)
		frame:SetVerticalScroll(self:GetValue())
	end)
	]]
	
	-- Set points
	frame:ClearAllPoints()
	frame:SetAllPoints()

	return frame
end

--[[ Create a ScrollFrame ScrollBar
]]
function kLoot:View_HybridScrollFrameScrollBar_Create(name, parent)
	self:Debug('View_ScrollFrameScrollBar_Create', 'name: ', name, 'parent: ', parent, 2)
	local frame = self:View_Frame_Create(name, parent, nil, nil, nil, 'HybridScrollBarTemplate', 'Slider')
	parent.scrollBar = frame -- Set scrollBar to parent frame
	
	-- scrollbar is just to the right of the scrollframe
	--parent.scrollBar = CreateFrame("Slider","CKBIScrollFrameScrollBar",self.scrollFrame,"HybridScrollBarTemplate")
	--parent.scrollBar:SetPoint("TOPLEFT",KeyBindingFrameScrollFrameScrollBar,"TOPLEFT",0,0)
	--parent.scrollBar:SetPoint("BOTTOMRIGHT",KeyBindingFrameScrollFrameScrollBar,"BOTTOMRIGHT",1,0)
	-- ScrollFrame creation
	--parent.stepSize = 12*4 -- jump by 4 buttons on mousewheel
	--parent.update = self.Update
	--parent.scrollBar = frame
	-- Set up internal textures for the scrollbar, background and thumb texture
	if not frame.bg then
		frame.bg = frame:CreateTexture(nil, "BACKGROUND")
		frame.bg:SetAllPoints(true)
		frame.bg:SetTexture(0, 0, 0, 0.5)
	end
	 
	if not frame.thumb then
		frame.thumb = frame:CreateTexture(nil, "OVERLAY")
		frame.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		frame.thumb:SetSize(25, 25)
		frame:SetThumbTexture(frame.thumb)
	end	
	return frame
end

function kLoot:View_HybridScrollFrame_Update(frame)
	HybridScrollFrame_Update(frame, 20*5, 20)
end