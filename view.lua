local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Get the color option for a view object
]]
function kLoot:View_GetColor(object, colorType)
	if not object or not object.objectType then return end
	colorType = colorType or 'default'
	if object.color then return object.color[colorType] end
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

--[[ Prompt to resume active raid
]]
function kLoot:View_PromptResumeRaid()
	local raid = self:Raid_Get()
	if not raid then return end
	local dialog = self:View_Dialog_Create('ResumeRaid',
		'Do you wish to resume the currently active raid?')
	self:View_DialogButton_Create('resume', 'Resume', dialog, function() 
		self:Raid_Resume()
		dialog.Close()
	end)
	self:View_DialogButton_Create('new', 'New Raid', dialog, function()
		self:Raid_End()
		self:Raid_Start()
		dialog.Close()
	end)
end

--[[ Set the color option for a view object
]]
function kLoot:View_SetColor(object, colorType, color)
	if not object or not object.objectType then return end
	colorType = colorType or 'default'
	color = self:Color_Get(color)
	object.color = object.color or {}	
	if color then
		object.color[colorType] = color
	else
		-- Check if objectType is found in defaults
		object.color[colorType] = self:Color_Default(object.objectType, colorType)
	end
end

--[[ Update color for SquareButton
]]
function kLoot:View_UpdateColor(object, event)
	if not object or not object.objectType then return end
	local colorType = 'default'
	if event == 'OnMouseDown' or event == 'OnLeave' then
		if object.selected then
			colorType = 'selected'
		end	
	elseif event == 'OnEnter' then
		colorType = 'hover'
	end
	if object.objectType == 'Frame' then
		self:View_Texture_Update(object, self:View_GetColor(object, colorType))
	elseif object.objectType == 'SquareButton' then	
		self:View_Texture_Update(object, self:View_GetColor(object, colorType))
	end
end