local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

function kLoot:View_BidDialog_Create(auction)
	auction = self:Auction_Get(auction)
	if not auction then return end
	local viewId = 'Bid'
	
	local dialog = self:View_Frame_Create('DialogBid', nil, 800, 600)	
	dialog:SetPoint('TOP', 0, -100)
	dialog:Show()	
	dialog.auctionId = auction.id
	dialog.bidTypes = {}
	
	-- CURRENT
	local currentItem = self:Item_GetCurrentItem(auction.itemId)
	
	local currentItemTitleString = self:View_FontString_Create('CurrentItemTitleString', dialog, 'CURRENT')
	currentItemTitleString:SetPoint('TOPLEFT', (dialog:GetWidth() / 3) * 1 - (currentItemTitleString:GetWidth() / 2), -15) -- Left third

	local currentItemFrame = self:View_Frame_Create('CurrentItem', dialog, 300, 35, {r = 1, g = 0, b = 0, a = 0.7})
	currentItemFrame:SetPoint('TOP', currentItemTitleString, 'BOTTOM') -- Left third	

	currentItemFrame:SetScript('OnEnter', function(self)
		kLoot:View_ItemTooltip(currentItem, self)
	end)
	currentItemFrame:SetScript('OnLeave', function(self) GameTooltip:Hide() end)	
	
	local currentItemString = self:View_FontString_Create('Text', currentItemFrame, self:Item_Name(currentItem), self:Color_Get(self:Item_ColorByRarity(self:Item_Rarity(currentItem))))
	currentItemString:SetAllPoints(currentItemFrame)	
	
	local iconPath = self:Item_Icon(currentItem)
	local currentItemIcon = self:View_Icon_Create('CurrentIcon', dialog, nil, nil, iconPath)
	currentItemIcon:ClearAllPoints()
	currentItemIcon:SetPoint('CENTER', 0, -100)
	
	-- AUCTION
	local auctionItemTitleString = self:View_FontString_Create('AuctionItemTitleString', dialog, 'AUCTION')
	auctionItemTitleString:SetPoint('TOPRIGHT', -1 * (dialog:GetWidth() / 3) * 1 + (auctionItemTitleString:GetWidth() / 2), -15) -- Right third	

	local auctionItemFrame = self:View_Frame_Create('AuctionItem', dialog, 300, 35, {r = 1, g = 1, b = 0, a = 0.5})
	auctionItemFrame:SetPoint('TOP', auctionItemTitleString, 'BOTTOM')

	auctionItemFrame:SetScript('OnEnter', function(self)
		kLoot:View_ItemTooltip(auction.itemId, self)
	end)
	auctionItemFrame:SetScript('OnLeave', function(self) GameTooltip:Hide() end)	
	
	local auctionItemString = self:View_FontString_Create('Text', auctionItemFrame, self:Item_Name(auction.itemId), self:Color_Get(self:Item_ColorByRarity(self:Item_Rarity(auction.itemId))))
	auctionItemString:SetAllPoints(auctionItemFrame)
	
	-- BID TYPE FRAME
	local bidTypeFrame = self:View_Frame_Create('BidType', dialog, self:View_Frame_GetWidth(dialog) * 0.7, 100,  {r = 1, g = 1, b = 0, a = 0.5})
	bidTypeFrame:SetPoint('CENTER')
	
	-- normal bid
	local mainspecBidSquareButton = self:View_SquareButton_Create('BidMainspec', bidTypeFrame, 'M', 'Mainspec', 'bidType')
	mainspecBidSquareButton:ClearAllPoints()
	mainspecBidSquareButton:SetPoint('TOPLEFT', mainspecBidSquareButton.margin, -mainspecBidSquareButton.margin)
	_G[('%sBottomText'):format(mainspecBidSquareButton:GetName())]:SetFont([[Interface\AddOns\kLoot\media\fonts\DORISPP.TTF]], 14)
	
	mainspecBidSquareButton.addEvent('OnMouseDown', function()
		self:Debug('MainspecBid', 'OnMouseDown', dialog.auctionId, 2)
	end)
	
	-- offspec bid
	local offspecBidSquareButton = self:View_SquareButton_Create('BidOffspec', bidTypeFrame, 'O', 'Offspec', 'bidType')
	offspecBidSquareButton:ClearAllPoints()
	offspecBidSquareButton:SetPoint('TOPLEFT', mainspecBidSquareButton, 'TOPRIGHT', offspecBidSquareButton.margin, 0)
	
	offspecBidSquareButton.addEvent('OnMouseDown', function()
		self:Debug('OffspecBid', 'OnMouseDown', dialog.auctionId, 2)
	end)
	
	-- rot bid
	local rotBidSquareButton = self:View_SquareButton_Create('BidRot', bidTypeFrame, 'R', 'Rot', 'bidType')
	rotBidSquareButton:ClearAllPoints()
	rotBidSquareButton:SetPoint('TOPLEFT', offspecBidSquareButton, 'TOPRIGHT', rotBidSquareButton.margin, 0)
	
	rotBidSquareButton.addEvent('OnMouseDown', function()
		self:Debug('RotBid', 'OnMouseDown', dialog.auctionId, 2)
	end)
	
	-- FLAGS FRAME
	local flagsFrame = self:View_Frame_Create('Flags', dialog, self:View_Frame_GetWidth(dialog) * 0.7, 100,  {r = 1, g = 1, b = 0, a = 0.5})
	flagsFrame:SetPoint('TOP', bidTypeFrame, 'BOTTOM')
	
	-- BIS
	local flagBISSquareButton = self:View_SquareButton_Create('FlagBIS', flagsFrame, 'B', 'BIS', 'bidFlags')
	flagBISSquareButton:ClearAllPoints()
	flagBISSquareButton:SetPoint('TOPLEFT', flagBISSquareButton.margin, -flagBISSquareButton.margin)
	
	flagBISSquareButton.addEvent('OnMouseDown', function()
		self:Debug('BISFlag', 'OnMouseDown', dialog.auctionId, 2)
	end)
	
	-- Set
	local flagSetSquareButton = self:View_SquareButton_Create('FlagSet', flagsFrame, 'S', 'Set', 'bidFlags')
	flagSetSquareButton:ClearAllPoints()
	flagSetSquareButton:SetPoint('TOPLEFT', flagBISSquareButton, 'TOPRIGHT', flagSetSquareButton.margin, 0)	
	
	flagSetSquareButton.addEvent('OnMouseDown', function()
		self:Debug('SetFlag', 'OnMouseDown', dialog.auctionId, 2)
	end)
	
	-- Transmog
	local flagTransmogSquareButton = self:View_SquareButton_Create('FlagTransmog', flagsFrame, 'T', 'Transmog', 'bidFlags')
	flagTransmogSquareButton:ClearAllPoints()
	flagTransmogSquareButton:SetPoint('TOPLEFT', flagSetSquareButton, 'TOPRIGHT', flagTransmogSquareButton.margin, 0)	
	_G[('%sBottomText'):format(flagTransmogSquareButton:GetName())]:SetFont([[Interface\AddOns\kLoot\media\fonts\DORISPP.TTF]], 12)	
	
	flagTransmogSquareButton.addEvent('OnMouseDown', function()
		self:Debug('TransmogFlag', 'OnMouseDown', dialog.auctionId, 2)
	end)
	
	return dialog
end