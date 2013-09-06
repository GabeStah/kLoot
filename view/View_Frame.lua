local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

--[[ Create a basic frame
]]
function kLoot:View_Frame_Create(name, parent, width, height, colorOrTexture)
	name = self:View_Name(name, parent)
	self:Debug('View_Frame_Create', 'name: ', name, 'parent: ', parent, 2)
	local frame = _G[name] or CreateFrame('Frame', name, parent or UIParent)
	frame.objectType = 'Frame'	
	local width = width or 500
	local height = height or 350
	self:View_SetColor(frame, 'default', colorOrTexture)
	frame.margin = 4
	frame.validEventTypes = {
		'OnMouseDown',
		'OnEnter',
		'OnLeave',
	}

	-- Generate interaction events to react to
	frame.addEvent = function(eventType, event, index)
		if not eventType or not event or not type(event) == 'function' then return end
		frame.events = frame.events or {}		
		if tContains(frame.validEventTypes, eventType) then
			frame.events[eventType] = frame.events[eventType] or {}
			if index then
				tinsert(frame.events[eventType], index, event)
			else
				tinsert(frame.events[eventType], event)
			end
		end
	end
	
	-- Process previously added events
	frame.processEvent = function(eventType)
		if eventType and tContains(frame.validEventTypes, eventType) then
			if not frame.events or not frame.events[eventType] then return end
			for i,v in ipairs(frame.events[eventType]) do
				if type(v) == 'function' then
					v() -- run event
				end
			end
		end		
	end
	
	-- Destroy events
	frame.events = nil
	
	-- Setup script functions to process events
	for i,v in pairs(frame.validEventTypes) do
		frame:SetScript(v, function() frame.processEvent(v) end)
	end
	
	-- Generate dimensions
	frame:SetWidth(width)
	frame:SetHeight(height)	
	
	-- Create background texture
	self:View_Texture_Create(frame, colorOrTexture)
	
	frame:Show()
	return frame
end

--[[ Retrieve the height of a frame
]]
function kLoot:View_Frame_GetHeight(frame)
	if not frame then return end
	return frame:GetHeight()
end

--[[ Retrieve the width of a frame
]]
function kLoot:View_Frame_GetWidth(frame)
	if not frame then return end
	return frame:GetWidth()
end