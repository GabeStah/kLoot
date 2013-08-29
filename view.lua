local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

function kLoot:View_CreateBidDialog(auction)
	auction = self:Auction_Get(auction)
	if not auction then return end
	local viewId = 'Bid'
	
	local f = self:View_CreateFrame('DialogBid')
	f:SetPoint('TOP', 0, -100)
	
	-- CURRENT
	local currentString = self:View_CreateFontString('CurrentString', f, 'CURRENT')
	currentString:SetPoint('TOPLEFT', (f:GetWidth() / 3) * 1 - (currentString:GetWidth() / 2), -15) -- Left third

	-- AUCTION
	local auctionString = self:View_CreateFontString('AuctionString', f, 'AUCTION')
	auctionString:SetPoint('TOPRIGHT', -1 * (f:GetWidth() / 3) * 1 + (auctionString:GetWidth() / 2), -15) -- Right third	

	local auctionItemFrame = self:View_CreateFrame('AuctionItem', f, 300, 35, {r = 1, g = 0, b = 0, a = 0})
	auctionItemFrame:SetPoint('TOPRIGHT', -1 * (f:GetWidth() / 3) * 1 + (auctionItemFrame:GetWidth() / 2), -35) -- Right third	

	auctionItemFrame:SetScript('OnEnter', function(self)
		kLoot:View_ItemTooltip(auction.itemId, self)
	end)
	auctionItemFrame:SetScript('OnLeave', function(self) GameTooltip:Hide() end)	
	
	local auctionItemString = self:View_CreateFontString('Text', auctionItemFrame, self:Item_Name(auction.itemId), self:Color_Get(self:Item_ColorByRarity(self:Item_Rarity(auction.itemId))))
	auctionItemString:SetAllPoints(auctionItemFrame)
	
	--[[
	local frame = CreateFrame("Frame", nil, f)
	frame:Hide()
	
	-- TODO: Create frame widget with font string inside for SetScript interaction

	--local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	--label:SetJustifyH("LEFT")
	--label:SetJustifyV("TOP")
	
	-- AUCTION ITEM
	local auctionItem = self:View_CreateFontString('AuctionItem', frame, self:Item_Name(auction.itemId))
	auctionItem:SetTextColor(self:Item_ColorByRarity(self:Item_Rarity(auction.itemId)))
	--auctionItem:SetPoint('TOPRIGHT', -1 * (f:GetWidth() / 3) * 1 + (auctionItem:GetWidth() / 2), -35) -- Right third
	auctionItem:SetJustifyH("LEFT")
	auctionItem:SetJustifyV("TOP")	
	auctionItem:SetScript('OnEnter', function(self)
		kLoot:View_ItemTooltip(self, auction.itemId)
	end)
	auctionItem:SetScript('OnLeave', function(self) GameTooltip:Hide() end)
	
	frame:SetPoint('TOPRIGHT', -1 * (f:GetWidth() / 3) * 1 + (frame:GetWidth() / 2), -35) -- Right third
	frame:Show()
	]]
	
	f:Show()
	return f
end

--[[ Create a basic frame
]]
function kLoot:View_CreateFrame(name, parent, width, height, color)
	name = self:View_Name(name, parent)
	self:Debug('View_CreateFrame', 'name: ', name, 'parent: ', parent, 2)
	local frame = _G[name] or CreateFrame('Frame', name, parent or UIParent)
	local width = width or 500
	local height = height or 350
	local color = color or {r=0,g=0,b=0,a=0.8}

	frame:SetWidth(width)
	frame:SetHeight(height)
	frame.margin = 4
	
	-- Create background texture
	self:View_CreateTexture(frame, color)
	
	frame:Show()
	return frame
end

--[[ Create texture for frame
]]
function kLoot:View_CreateTexture(frame, color)
	if not frame then return end
	local texture = frame.texture or frame:CreateTexture(nil,'BACKGROUND')
	color = color or {r=0,g=0,b=0,a=0.8}
	texture:SetTexture(color.r, color.g, color.b, color.a)
	texture:SetAllPoints(frame)
	frame.texture = texture
end

--[[ Update texture for frame
]]
function kLoot:View_UpdateTexture(frame, color)
	if not frame or not frame.texture or not color then return end
	frame.texture:SetTexture(color.r, color.g, color.b, color.a)
	texture:SetAllPoints(frame)
end

--[[ Generate the view object name
]]
function kLoot:View_Name(object, parent)
	if not object then return end
	-- Assign actual object name
	if type(object) == 'table' then 
		if object:GetName() then
			object = object:GetName()
		end
	end
	-- Check if object contains kLoot already, indicating full path
	if string.find(object, 'kLoot') then return object end
	
	if parent then
		if type(parent) == 'string' and string.find(parent, 'kLoot') then
			return ('%s%s'):format(parent, object)
		elseif type(parent) == 'table' and string.find(parent:GetName(), 'kLoot') then
			return ('%s%s'):format(parent:GetName(), object)		
		end		
	end
	return ('kLoot%s'):format(object)	
end

--[[ Create a basic font string attached to the parent item
]]
function kLoot:View_CreateFontString(name, parent, text, color)
	if not parent then return end
	name = self:View_Name(name, parent)
	color = color or {r=1,g=1,b=1,a=1}
	local object = parent:CreateFontString(name)
	object:SetFont('Fonts\\FRIZQT__.TTF', 14)
	object:SetJustifyV('TOP')
	object:SetText(text)
	object:SetTextColor(color.r, color.g, color.b, color.a)
	return object
end

function kLoot:View_CreateDialog(id, text, width, height, margin, color)
   id = id or 'Default'
   width = width or 300
   height = height or 150
   color = color or {r=0,g=0,b=0,a=0.8}
   local frameName = ('%s%s'):format('kLootDialog', id)
   
   local f = _G[frameName] or CreateFrame('Frame', frameName, UIParent)
   f.Close = f.Close or function() f:Hide() end
   f:SetWidth(width)
   f:SetHeight(height)
   f.margin = margin or 4
   local t = f.texture or f:CreateTexture(nil,'BACKGROUND')
   t:SetTexture(color.r, color.g, color.b, color.a)
   t:SetAllPoints(f)
   f.texture = t
   f:SetPoint('TOP',0,-100)
   
   local fontString = f.fontString or f:CreateFontString(('%s%s'):format(f:GetName(),'Text'))
   f.fontString = fontString
   fontString:SetPoint('BOTTOMRIGHT', -5, 35)
   fontString:SetPoint('TOPLEFT', 5, -5)
   fontString:SetFont('Fonts\\FRIZQT__.TTF', 14)
   fontString:SetJustifyV('TOP')
   fontString:SetText(('|cFF%skLoot|r|n%s'):format(self:Color_Get(self.color.green, nil, nil, nil, 'hex'), text))
   f:Show()
   return f
end

function kLoot:View_CreateDialogButton(id, text, parent, onClick, height, color, hoverColor)
   id = id or 'Button'
   text = text or 'Yes'
   height = height or 30
   color = color or {r=1,g=1,b=1,a=0.5}   
   hoverColor = hoverColor or {r=0,g=0.7,b=0,a=1}
   parent.buttons = parent.buttons or {}
   local AddButtonFrame = function(id, parent)
      parent.buttons = parent.buttons or {}
      for i,v in pairs(parent.buttons) do
         if v.id == id then return v.frame end
      end
      local f = CreateFrame('Frame', ('%sButton%s'):format(parent:GetName(),id), parent)   
      table.insert(parent.buttons, {id = id, frame = f})
      return f
   end
   local f = AddButtonFrame(id, parent)
   local t = f.texture or f:CreateTexture(nil,'BACKGROUND')   
   f.texture = t
   f:SetScript('OnMouseDown', function() onClick() end)
   f:SetScript('OnEnter', function(self) 
         self.texture:SetTexture(hoverColor.r,hoverColor.g,hoverColor.b,hoverColor.a)
   end)
   f:SetScript('OnLeave', function(self) self.texture:SetTexture(color.r,color.g,color.b,color.a) end)   
   
   t:SetTexture(color.r,color.g,color.b,color.a)
   t:SetAllPoints(f)
   
   f:SetHeight(height)
   
   local fontString = f.fontString or f:CreateFontString(('%s%s'):format(f:GetName(),'Text'))
   f.fontString = fontString
   fontString:SetPoint('CENTER', 0, 0)
   fontString:SetFont('Fonts\\FRIZQT__.TTF', 14, 'OUTLINE')
   fontString:SetText(text)
   
   -- Adjust buttons
   for i,v in pairs(parent.buttons) do
      v.frame:SetWidth((v.frame:GetParent():GetWidth()-(parent.margin*(1+#parent.buttons)))/#parent.buttons)
      v.frame:ClearAllPoints()
      if i==1 then
         v.frame:SetPoint('BOTTOMLEFT',parent.margin,parent.margin)
      else
         v.frame:SetPoint('LEFT', parent.buttons[i-1].frame, 'RIGHT', parent.margin, 0)
      end
   end   
   f:Show()   
end

function kLoot:View_CreateDialogTextBox(parent, text, highlightText)
   text = text or ''
   local textbox = parent.textbox or CreateFrame('EditBox', ('%s%s'):format(parent:GetName(),'TextBox'),parent, 'InputBoxTemplate')
   parent.textbox = textbox
   textbox:SetPoint('BOTTOM', 0,45)
   textbox:SetWidth(parent:GetWidth()-10)
   textbox:SetHeight(1)
   textbox:SetText(text)
   textbox:SetMultiLine(false)
   if highlightText then textbox:HighlightText() end
   textbox:SetCursorPosition(0)
   textbox:SetAutoFocus(false)
   textbox:SetTextInsets(0,0,0,0)
   textbox:ClearFocus()
   textbox:Show()
   
   local textboxT = textbox.texture or textbox:CreateTexture(nil,'BACKGROUND')
   textboxT:SetTexture(0, 0,0,0.3)
   textboxT:SetAllPoints(textbox)
   textbox.texture = textboxT
end

--[[ Display item tooltip attached to specified parent
]]
function kLoot:View_ItemTooltip(item, parent, anchorPoint, anchorFramePoint)
	item = self:Item_Link(item)
	if not parent or not item then return end
	local anchorPoint = anchorPoint or 'BOTTOMLEFT'
	local anchorFramePoint = anchorFramePoint or 'TOPLEFT'
	GameTooltip:SetOwner(WorldFrame,'ANCHOR_NONE')
	GameTooltip:ClearLines()
	GameTooltip:SetPoint(anchorPoint, parent, anchorFramePoint)
	GameTooltip:SetHyperlink(item)
	GameTooltip:Show()
end

--[[ Prompt to resume active raid
]]
function kLoot:View_PromptResumeRaid()
	local raid = self:Raid_Get()
	if not raid then return end
	local dialog = self:View_CreateDialog('ResumeRaid',
		'Do you wish to resume the currently active raid?')
	self:View_CreateDialogButton('resume', 'Resume', dialog, function() 
		self:Raid_Resume()
		dialog.Close()
	end)
	self:View_CreateDialogButton('new', 'New Raid', dialog, function()
		self:Raid_End()
		self:Raid_Start()
		dialog.Close()
	end)
end