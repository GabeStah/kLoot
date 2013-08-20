local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot
function kLoot:PLAYER_ENTERING_WORLD()
	RegisterAddonMessagePrefix("kLoot")
end

--[[ Process when addons load to trigger set creation
]]
function kLoot:Event_AddOnLoaded(event, addon)
	self:Debug('Event_AddOnLoaded', 'Loaded addon: ', addon, 2)
	for i,v in pairs(self.setAddons) do
		if v.addon == addon and v.loaded == false then
			self:Debug('Event_AddOnLoaded', 'Loaded addon: ', addon, 2)
			v.loaded = true
			if self:Set_AddonsLoaded() then
				-- Fire set creation
				self:Debug('Event_AddOnLoaded', 'All set addons loaded.', 2)
				self:Set_Generate()
			end
		end
	end
end

--[[ On equipment set change for Blizzard default
]]
function kLoot:Event_EquipmentSetsChanged()
	self:Debug('Event_EquipmentSetsChanged', 3)
	-- Regenerate sets
	self:Set_Generate()
end

function kLoot:Event_OnZoneChanged()
	self:Debug('Event_OnZoneChanged', GetRealZoneText(), 1)
end