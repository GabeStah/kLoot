local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create a BidDialog frame
]]
function kLoot:View_BidDialog_Create(auction)
	auction = self:Auction_Get(auction)
	if not auction then return end
	local viewId = 'Bid'
	
	local dialog = self:View_Frame_Create('DialogBid', nil, 800, 600)	
	dialog:SetPoint('TOP', 0, -100)
	dialog:Show()	
	dialog.auctionId = auction.id
	
	-- CURRENT
	local currentItem = self:Item_GetCurrentItem(auction.itemLink)
	local currentItemFrame = self:View_BidDialog_CreateItemFrame('Current', currentItem, dialog)

	local auctionItemFrame = self:View_BidDialog_CreateItemFrame('Auction', auction.itemLink, dialog)
	
	-- BID TYPE FRAME
	local bidTypeFrame = self:View_Frame_Create('BidType', dialog, self:View_Frame_GetWidth(dialog) * 0.7, 100,  {r = 1, g = 1, b = 0, a = 0.5})
	bidTypeFrame:SetPoint('CENTER')
	
	-- normal bid
	local mainspecBidSquareButton = self:View_SquareCategoryButton_Create('BidMainspec', bidTypeFrame, 'bidType', 'M', 'Mainspec')
	mainspecBidSquareButton:ClearAllPoints()
	mainspecBidSquareButton:SetPoint('TOPLEFT', mainspecBidSquareButton.margin, -mainspecBidSquareButton.margin)
	mainspecBidSquareButton.setFont(14, 'bottom')
	
	mainspecBidSquareButton:addEvent('OnMouseDown', function()
		self:Debug('MainspecBid', 'OnMouseDown', dialog.auctionId, 2)
		if self:Bid_IsUpdated(self:Bid_ByPlayer(dialog.auctionId), dialog.auctionId, self:View_BidDialog_GetBidSettings()) then
			self:Debug('MainspecBid', 'OnMouseDown', 'Bid_IsUpdated == true', 2)
		end
	end)
	
	-- offspec bid
	local offspecBidSquareButton = self:View_SquareCategoryButton_Create('BidOffspec', bidTypeFrame, 'bidType', 'O', 'Offspec')
	offspecBidSquareButton:ClearAllPoints()
	offspecBidSquareButton:SetPoint('TOPLEFT', mainspecBidSquareButton, 'TOPRIGHT', offspecBidSquareButton.margin, 0)
	
	offspecBidSquareButton:addEvent('OnMouseDown', function()
		self:Debug('OffspecBid', 'OnMouseDown', dialog.auctionId, 2)
		if self:Bid_IsUpdated(self:Bid_ByPlayer(dialog.auctionId), dialog.auctionId, self:View_BidDialog_GetBidSettings()) then
			self:Debug('OffspecBid', 'OnMouseDown', 'Bid_IsUpdated == true', 2)
		end
	end)
	
	-- rot bid
	local rotBidSquareButton = self:View_SquareCategoryButton_Create('BidRot', bidTypeFrame, 'bidType', 'R', 'Rot')
	rotBidSquareButton:ClearAllPoints()
	rotBidSquareButton:SetPoint('TOPLEFT', offspecBidSquareButton, 'TOPRIGHT', rotBidSquareButton.margin, 0)
	
	rotBidSquareButton:addEvent('OnMouseDown', function()
		self:Debug('RotBid', 'OnMouseDown', dialog.auctionId, 2)
		if self:Bid_IsUpdated(self:Bid_ByPlayer(dialog.auctionId), dialog.auctionId, self:View_BidDialog_GetBidSettings()) then
			self:Debug('RotBid', 'OnMouseDown', 'Bid_IsUpdated == true', 2)
		end
	end)
	
	-- FLAGS FRAME
	local flagsFrame = self:View_Frame_Create('Flags', dialog, self:View_Frame_GetWidth(dialog) * 0.7, 100,  {r = 1, g = 1, b = 0, a = 0.5})
	flagsFrame:SetPoint('TOP', bidTypeFrame, 'BOTTOM')
	
	-- BIS
	local flagBISSquareButton = self:View_SquareButton_Create('FlagBIS', flagsFrame, 'B', 'BIS')
	flagBISSquareButton:ClearAllPoints()
	flagBISSquareButton:SetPoint('TOPLEFT', flagBISSquareButton.margin, -flagBISSquareButton.margin)
	
	flagBISSquareButton:addEvent('OnMouseDown', function()
		self:Debug('BISFlag', 'OnMouseDown', dialog.auctionId, 2)
		if self:Bid_IsUpdated(self:Bid_ByPlayer(dialog.auctionId), dialog.auctionId, self:View_BidDialog_GetBidSettings()) then
			self:Debug('BISFlag', 'OnMouseDown', 'Bid_IsUpdated == true', 2)
		end
	end)
	
	-- Set
	local flagSetSquareButton = self:View_SquareButton_Create('FlagSet', flagsFrame, 'S', 'Set')
	flagSetSquareButton:ClearAllPoints()
	flagSetSquareButton:SetPoint('TOPLEFT', flagBISSquareButton, 'TOPRIGHT', flagSetSquareButton.margin, 0)	
	
	flagSetSquareButton:addEvent('OnMouseDown', function()
		self:Debug('SetFlag', 'OnMouseDown', dialog.auctionId, 2)
		if self:Bid_IsUpdated(self:Bid_ByPlayer(dialog.auctionId), dialog.auctionId, self:View_BidDialog_GetBidSettings()) then
			self:Debug('SetFlag', 'OnMouseDown', 'Bid_IsUpdated == true', 2)
		end
	end)
	
	-- Transmog
	local flagTransmogSquareButton = self:View_SquareButton_Create('FlagTransmog', flagsFrame, 'T', 'Transmog')
	flagTransmogSquareButton:ClearAllPoints()
	flagTransmogSquareButton:SetPoint('TOPLEFT', flagSetSquareButton, 'TOPRIGHT', flagTransmogSquareButton.margin, 0)	
	flagTransmogSquareButton.setFont(12, 'bottom')
	
	flagTransmogSquareButton:addEvent('OnMouseDown', function()
		self:Debug('TransmogFlag', 'OnMouseDown', dialog.auctionId, 2)
		if self:Bid_IsUpdated(self:Bid_ByPlayer(dialog.auctionId), dialog.auctionId, self:View_BidDialog_GetBidSettings()) then
			self:Debug('TransmogFlag', 'OnMouseDown', 'Bid_IsUpdated == true', 2)
			local bidButton = self:View_FindObject(dialog, 'Bid', 'SquareButton')
			if bidButton then
				self:Debug('TransmogFlag', 'Bid > SquareButton found: ', bidButton, 2)
			end
		end
	end)
	
	-- Close button
	local closeButton = self:View_SquareButton_Create('Close', dialog, 'Close')
	closeButton:ClearAllPoints()
	closeButton:SetPoint('BOTTOMLEFT')
	closeButton:SetWidth(150)
	
	closeButton:deleteEvents('OnMouseDown')
	
	closeButton:addEvent('OnMouseDown', function()
		self:Debug('Close', 'OnMouseDown', dialog.auctionId, 2)
		dialog:Hide()
	end)
	
	-- Bid button
	-- Check if bid for this auction exists
	local bidButton = self:View_SquareButton_Create('Bid', dialog, self:Bid_ByPlayer(dialog.auctionId) and 'Cancel' or 'Bid')
	bidButton:ClearAllPoints()
	bidButton:SetPoint('BOTTOMRIGHT')
	bidButton:SetWidth(150)
	
	bidButton:deleteEvents('OnMouseDown')
	
	bidButton:addEvent('OnMouseDown', function()
		self:Debug('Bid', 'OnMouseDown', dialog.auctionId, 2)
		-- Assign current bid
		local currentBid = self:Bid_ByPlayer(dialog.auctionId)		
		if currentBid then -- If current bid, process cancel
			self:Bid_Cancel(
				currentBid,
				dialog.auctionId
			)
		elseif self:View_BidDialog_GetBidType() then
			-- Generate bid
			self:Bid_Create(
				nil, -- No id, new bid passed			
				auction,
				currentItemFrame.getItems(), -- Items table
				nil, -- Current player
				self:View_BidDialog_GetBidType(),
				nil, -- Current specialization
				self:View_BidDialog_GetFlags() -- Get current set flags
			)
		end
		-- Update text
		bidButton.setText(self:Bid_ByPlayer(dialog.auctionId) and 'Cancel' or 'Bid')		
	end)	
		
	-- Color redraw
	self:View_UpdateColor(frame)
	return dialog
end

--[[ Create an item frame for the BidDialog
]]
function kLoot:View_BidDialog_CreateItemFrame(name, item, parent)
	if not name then return end
	local tooltipFlip = false
	if name == 'Auction' then tooltipFlip = true end
	
	local frame = self:View_Frame_Create(('%sItem'):format(name), parent, 300, 150)
	frame.item = item
	-- Methods
	-- Retrieve the item for the current Item Frame.
	frame.getItems = function()
		return {frame.item}
	end
	if name == 'Current' then
		frame:SetPoint('TOPLEFT', (parent:GetWidth() / 3) * 1 - (frame:GetWidth() / 2), -15) -- Left third	
	elseif name == 'Auction' then
		frame:SetPoint('TOPRIGHT', -1 * (parent:GetWidth() / 3) * 1 + (frame:GetWidth() / 2), -15) -- Right third
	end
	
	frame:SetScript('OnEnter', function(self)
		kLoot:View_ItemTooltip(item, frame, 
			tooltipFlip and 'TOPLEFT' or 'TOPRIGHT', 
			tooltipFlip and 'TOPRIGHT' or 'TOPLEFT')
	end)
	frame:SetScript('OnLeave', function(self) GameTooltip:Hide() end)		
	
	local titleString = self:View_FontString_Create('Title', frame, strupper(name))
	titleString:SetPoint('TOPLEFT')
	titleString:SetPoint('TOPRIGHT')
	
	local itemString = self:View_FontString_Create('Name', frame, self:Item_Name(item), self:Color_Get(self:Item_ColorByRarity(self:Item_Rarity(item))))
	itemString:ClearAllPoints()
	itemString:SetPoint('LEFT')
	itemString:SetPoint('RIGHT')
	itemString:SetPoint('TOP', titleString, 'BOTTOM', 0, -10)
	itemString.setFont(20) 
	
	local iconPath = self:Item_Icon(item)
	local itemIcon = self:View_Icon_Create('Icon', frame, nil, nil, iconPath)
	itemIcon:ClearAllPoints()
	itemIcon:SetPoint('TOP', itemString, 'BOTTOM', 0, -10)
	
	itemIcon:SetScript('OnEnter', function(self)
		kLoot:View_ItemTooltip(item, frame, 
			tooltipFlip and 'TOPLEFT' or 'TOPRIGHT', 
			tooltipFlip and 'TOPRIGHT' or 'TOPLEFT')
	end)
	itemIcon:SetScript('OnLeave', function(self) GameTooltip:Hide() end)	
	
	local itemLevel = self:View_FontString_Create('Level', frame, self:Item_Level(item))
	itemLevel:ClearAllPoints()
	itemLevel:SetPoint('LEFT')
	itemLevel:SetPoint('RIGHT')
	itemLevel:SetPoint('TOP', itemIcon, 'BOTTOM', 0, -10)
	itemLevel.setFont(20)
	
	return frame
end

--[[ Retrieve the bid settings for this dialog
]]
function kLoot:View_BidDialog_GetBidSettings()
	local settings = {}
	-- Assign current bid
	local dialog = _G['kLootDialogBid']
	if not dialog then return end
	local currentBid = self:Bid_ByPlayer(dialog.auctionId)			
	settings.bidType = self:View_BidDialog_GetBidType()
	settings.specialization = currentBid and currentBid.specialization
	settings.items = currentBid and currentBid.items
	settings.flags = self:View_BidDialog_GetFlags()
	return settings
end

--[[ Retrieve the selected bidType if applicable
]]
function kLoot:View_BidDialog_GetBidType()
	if not _G['kLootDialogBid'] then return end
	local bidTypeFrame = self:View_FindObject(_G['kLootDialogBid'], 'BidType', 'Frame')
	if not bidTypeFrame then return end
	local children = {bidTypeFrame:GetChildren()}
	for i,v in pairs(children) do
		if self:View_GetFlag(v, 'selected') then
			if string.find(v.name, 'Bid%a+') then				
				return string.sub(v.name, 4)
			end
		end
	end	
end

--[[ Get the flag settings table
]]
function kLoot:View_BidDialog_GetFlags()
	return {
		BIS = self:View_BidDialog_HasFlag('BIS'),
		Set = self:View_BidDialog_HasFlag('Set'),
		Transmog = self:View_BidDialog_HasFlag('Transmog'),
	}
end

--[[ Determine if dialog window has flagType
]]
function kLoot:View_BidDialog_HasFlag(flagType)
	if not _G['kLootDialogBid'] then return end
	local flagsFrame = self:View_FindObject(_G['kLootDialogBid'], 'Flags', 'Frame')
	local children = {flagsFrame:GetChildren()}
	for i,v in pairs(children) do
		if string.find(v.name, 'Flag%a+') and string.sub(v.name, 5) == flagType and self:View_GetFlag(v, 'selected') then
			return true
		end
	end		
end