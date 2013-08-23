local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot

kLoot.defaults = {
	profile = {
		auction = {
			duration = 25,
		},
		autoloot = {
			enabled = false,
			whitelist = {},
			zones = {},
		},
		bidding = {
			sets = {},		
		},
		cvars = {
			matureLanguageFilterEnabled = false,
		},		
		debug = {
			enabled = false,
			enableTimers = true,
			threshold = 1,
		},
		editors = {
			Dougallxin = {player = 'Dougallxin', selected = false},
			Kulldar = {player = 'Kulldar', selected = false},
			Kulltest = {player = 'Kulltest', selected = false},
			Kainhighwind = {player = 'Kainhighwind', selected = false},
			Takaoni = {player = 'Takaoni', selected = false},
			Tree = {player = 'Tree', selected = false},
		},
		macros = {
			enabled = false,
			list = {
				
			},
			temp = {},
		},
		raids = {},
		settings = {
			update = {
				auction = {
					interval = 1,
				},
				core = {
					interval = 1,
				},
			},
			raid = {
				active = nil,
			},
		},
		vcp = {
			raiders = {
				"Blastphemus",
				"Deaf",
				"Dougallxin",
				"Gartzarnn",
				"Guddz",
				"Kainhighwind",
				"Kulldar",
				"Rorke",
				"Shaylana",
				"Takaoni",
				"Tree",
			},
		},
		zones = {
			validZones = {
				"Baradin Hold",
				"Blackrock Mountain: Blackwing Descent",
				"Firelands",
				"The Bastion of Twilight",
				"Throne of the Four Winds",
				"Dragon Soul",
				"Throne of Thunder",
			},
			zoneSelected = 1,
		},
	},
};
kLoot.timers = {}
kLoot.threading = {}
kLoot.threading.timers = {}
kLoot.threading.timerPool = {}
-- Create Options Table
kLoot.options = {
    name = "kLoot",
    handler = kLoot,
    type = 'group',
    args = {
		auction = {
			type = 'execute',
			name = 'auction',
			desc = 'Create an auction.',
			func = function(...) 
				kLoot:Manual_Auction(...)
			end,
			guiHidden = true,			
		},
		bid = {
			type = 'execute',
			name = 'bid',
			desc = 'Create a bid.',
			func = function(...) 
				kLoot:Manual_Bid(...)
			end,
			guiHidden = true,			
		},
		description = {
			name = '',
			type = 'description',
			order = 0,
			hidden = true,
		},	
		debug = {
			name = 'Debug',
			type = 'group',
			args = {
				enabled = {
					name = 'Enabled',
					type = 'toggle',
					desc = 'Toggle Debug mode',
					set = function(info,value) kLoot.db.profile.debug.enabled = value end,
					get = function(info) return kLoot.db.profile.debug.enabled end,
				},
				enableTimers = {
					name = 'Enable Timers',
					type = 'toggle',
					desc = 'Toggle timer enabling',
					set = function(info,value) kLoot.db.profile.debug.enableTimers = value end,
					get = function(info) return kLoot.db.profile.debug.enableTimers end,
				},
				threshold = {
					name = 'Threshold',
					desc = 'Description for Debug Threshold',
					type = 'select',
					values = {
						[1] = 'Low',
						[2] = 'Normal',
						[3] = 'High',
					},
					style = 'dropdown',
					set = function(info,value) kLoot.db.profile.debug.threshold = value end,
					get = function(info) return kLoot.db.profile.debug.threshold end,
				},
			},
			cmdHidden = true,
		},
		auctionGroup = {
			name = 'Auction',
			type = 'group',
			args = {
				duration = {
					name = 'Auction Duration',
					desc = 'Default auction timeout length.',
					type = 'range',
					min = 5,
					max = 120,
					step = 1,
					set = function(info,value)
						kLoot.db.profile.auction.duration = value
					end,
					get = function(info) return kLoot.db.profile.auction.duration end,
					order = 2,
				},	
			},
		},
		autoloot = {
			name = 'Auto-Loot',
			type = 'group',
			args = {
				enabled = {
					name = 'Enabled',
					type = 'toggle',
					desc = 'Toggle Autoloot mode',
					set = function(info,value) kLoot.db.profile.autoloot.enabled = value end,
					get = function(info) return kLoot.db.profile.autoloot.enabled end,
				},
				whitelistInline = {
					name = 'Items Whitelist',
					type = 'group',
					cmdHidden = true,
					order = 7,
					args = {
						description = {
							name = 'Items to auto-loot.',
							type = 'description',
							order = 0,
						},
						add = {
							name = 'Add',
							type = 'input',
							desc = 'Add item to list.',
							get = function(info) return nil end,
							set = function(info,value)
								tinsert(kLoot.db.profile.autoloot.whitelist, value);
								table.sort(kLoot.db.profile.autoloot.whitelist);
							end,
							order = 1,
							width = 'full',
						},
						items = {
							name = 'Items',
							type = 'select',
							desc = 'Current list of valid Items.',
							style = 'dropdown',
							values = function() return kLoot.db.profile.autoloot.whitelist end,
							get = function(info) return kLoot.autoLootWhitelistItemSelected end,
							set = function(info,value) kLoot.autoLootWhitelistItemSelected = value end,
							order = 2,
						},
						delete = {
							name = 'Delete',
							type = 'execute',
							desc = 'Delete selected Zone from list.',
							func = function()
								tremove(kLoot.db.profile.autoloot.whitelist, kLoot.autoLootWhitelistItemSelected);
								kLoot.autoLootWhitelistItemSelected = 1;
							end,
							order = 3,
						},					
					},
				},
				zonesInline = {
					name = 'Zones',
					type = 'group',
					cmdHidden = true,
					order = 7,
					args = {
						description = {
							name = 'Zones where AutoLoot is enabled.',
							type = 'description',
							order = 0,
						},
						add = {
							name = 'Add',
							type = 'input',
							desc = 'Add Zone to list.',
							get = function(info) return nil end,
							set = function(info,value)
								tinsert(kLoot.db.profile.autoloot.zones, value);
								table.sort(kLoot.db.profile.autoloot.zones);
							end,
							order = 1,
							width = 'full',
						},
						zones = {
							name = 'Zones',
							type = 'select',
							desc = 'Current list of valid Zones.',
							style = 'dropdown',
							values = function() return kLoot.db.profile.autoloot.zones end,
							get = function(info) return kLoot.autoLootZoneSelected end,
							set = function(info,value) kLoot.autoLootZoneSelected = value end,
							order = 2,
						},
						delete = {
							name = 'Delete',
							type = 'execute',
							desc = 'Delete selected Zone from list.',
							func = function()
								tremove(kLoot.db.profile.autoloot.zones, kLoot.autoLootZoneSelected);
								kLoot.autoLootZoneSelected = 1;
							end,
							order = 3,
						},					
					},
				},
			},
		},
		bidding = {
			name = 'Bidding',
			type = 'group',
			args = {
				sets = {
					name = 'Sets',
					type = 'group',
					args = {
						bidTypes = {
							name = 'Bid Types',
							type = 'select',
							desc = 'Select the Bid Type to edit.',
							style = 'dropdown',
							values = function() return kLoot.bidTypes end,
							get = function(info)
								-- Regenerate sets
								kLoot:Set_Generate()
								return kLoot:Options_GetSelected(kLoot.db.profile.bidding.sets, 'key')
							end,
							set = function(info,value)
								kLoot:Options_SetSelected(kLoot.db.profile.bidding.sets, value)
							end,
							order = 1,
						},
						addon = {
							name = 'Addon',
							type = 'select',
							desc = 'Select the addon where your set exists.',
							style = 'dropdown',
							values = function() return kLoot:Set_AddonList() end,
							get = function(info)
								local data = kLoot:Options_GetSelected(kLoot.db.profile.bidding.sets, 'value')
								return data.addon
							end,
							set = function(info,value)
								local data = kLoot:Options_GetSelected(kLoot.db.profile.bidding.sets, 'value')
								data.addon = value
								-- Unset the set
								data.set = nil
							end,
							order = 2,
						},
						set = {
							name = 'Set',
							type = 'select',
							desc = 'Select the set to associate with this Bid Type.',
							style = 'dropdown',
							values = function()
								-- Get sets for selected addon
								local data = kLoot:Options_GetSelected(kLoot.db.profile.bidding.sets, 'value')
								return kLoot:Set_ListByAddon(data.addon) or {}
							end,
							get = function(info)
								local data = kLoot:Options_GetSelected(kLoot.db.profile.bidding.sets, 'value')
								return data.set
							end,
							set = function(info,value)
								local data = kLoot:Options_GetSelected(kLoot.db.profile.bidding.sets, 'value')
								data.set = value
							end,
							order = 3,
						},
					},
				},	
			},
		},		
		cvars = {
			name = 'Cvars',
			type = 'group',
			args = {
				matureLanguageFilterEnabled = {
					name = 'Mature Language Filter',
					type = 'toggle',
					desc = 'Toggle Mature Language Filter.',
					set = function(info,value)
						kLoot.db.profile.cvars.matureLanguageFilterEnabled = value
						BNSetMatureLanguageFilter(kLoot.db.profile.cvars.matureLanguageFilterEnabled)
					end,
					get = function(info) return kLoot.db.profile.cvars.matureLanguageFilterEnabled end,
				},					
			},
		},		
        config = {
			type = 'execute',
			name = 'Config',
			desc = 'Open the Configuration Interface',
			func = function() 
				kLoot.dialog:Open("kLoot") 
			end,
			guiHidden = true,
        },    
        raid = {
			type = 'execute',
			name = 'raid',
			desc = 'Start or stop a raid - /kl raid [keyword] - start, begin, stop, end',
			func = function(...) 
				kLoot:Manual_Raid(...)
			end,
			guiHidden = true,			
		},
		role = {
			name = 'Role',
			type = 'group',
			args = {
				addEditor = {
					name = 'Add Editor',
					type = 'input',
					desc = 'Add a new player as an Editor.',
					get = function(info) return end,
					set = function(info,value)
						-- Verify admin status
						if kLoot:Role_IsAdmin() then
							kLoot:Role_Add('editor', value)
						end
					end,
					order = 1,		
				},
				editors = {
					name = 'Editors',
					type = 'select',
					desc = 'Select an Editor to edit.',
					style = 'dropdown',
					values = function() return kLoot:Options_GetValueList(kLoot.db.profile.editors, 'player') end,
					get = function(info)
						return kLoot:Options_GetSelected(kLoot.db.profile.editors, 'key')
					end,
					set = function(info,value)
						kLoot:Options_SetSelected(kLoot.db.profile.editors, value)
					end,
					order = 2,
				},
				deleteEditor = {
					name = 'Delete',
					type = 'execute',
					desc = function()
						-- If selection, show
						local selected = kLoot:Options_GetSelected(kLoot.db.profile.editors, 'player')
						if selected then
							return ('Delete [%s] from the Editor list.'):format(selected)
						else
							return 'Select an Editor from the list to delete.'
						end
					end,
					func = function()
						-- Verify admin status
						if kLoot:Role_IsAdmin() then
							kLoot:Role_Delete('editor', kLoot:Options_GetSelected(kLoot.db.profile.editors, 'player'))
							kLoot:Options_ResetSelected(kLoot.db.profile.editors)
						end
					end,
					order = 3,
				},
			},
		},
        version = {
			type = 'execute',
			name = 'Version',
			desc = 'Check your kLoot version',
			func = function() 
				kLoot:Print("Version: |cFF"..kLoot:Utility_RGBToHex(0,255,0)..kLoot.version.."|r");
			end,
			guiHidden = true,
        },
	},
};

--[[ Implement default settings
]]
function kLoot:Options_Default()
	self:Options_DefaultBidding()
	--self:Options_DefaultRole()
end

--[[ Implement bidding default settings
]]
function kLoot:Options_DefaultBidding()
	-- bidTypes
	for i,v in pairs(self.bidTypes) do
		if not self.db.profile.bidding.sets[i] then
			self.db.profile.bidding.sets[i] = {
				bidType = i,
				selected = false,
			}
		end
	end
	self:Options_ResetSelected(self.db.profile.bidding.sets)
end

--[[ Implement Role default settings
]]
function kLoot:Options_DefaultRole()
	local data
	-- bidTypes
	for i,v in pairs(self.db.profile.editors) do
		-- Check if string type
		if type(v) == 'string' then
			data = data or {}
			tinsert(data, {
				player = v,
				selected = false,
			})
		end
	end
	if data then
		self.db.profile.editors = data
		self:Options_ResetSelected(self.db.profile.editors)
	end
end

--[[ Generate all custom options tables
]]
function kLoot:Options_Generate()
	
end

--[[ Retrieve the selected key in the data table
]]
function kLoot:Options_GetSelected(data, selectionType)
	if not data or not type(data) == 'table' then return end
	selectionType = selectionType or 'key'
	for i,v in pairs(data) do
		if type(v) == 'table' then
			if v.selected and v.selected == true then
				if selectionType == 'key' then
					return i
				elseif selectionType == 'value' then
					return v
				elseif v[selectionType] then
					return v[selectionType]
				end
			end
		end
	end
end

--[[ Retrieve the value list for dropdown selection use from table/key
]]
function kLoot:Options_GetValueList(data, key)
	if not data or not key or not type(data) == 'table' then return end
	local output
	for i,v in pairs(data) do
		if v[key] then
			output = output or {}
			output[i] = v[key]
		end
	end
	return output
end

--[[ Resets the selected for the data table if necessary
]]
function kLoot:Options_ResetSelected(data)
	if not data or not type(data) == 'table' then return end
	local selectedCount = 0
	for i,v in pairs(data) do
		if type(v) == 'table' then
			if v.selected and v.selected == true then
				selectedCount = selectedCount + 1
			end
		end
	end
	-- If non-one value if selections then select first
	if selectedCount ~= 1 then
		self:Options_SetSelectedFirst(data)
	end
end

--[[ Properly edit specified table to ensure selected key is only selected option
]]
function kLoot:Options_SetSelected(data, key)
	if not data or not key or not type(data) == 'table' or not data[key] then return end
	for i,v in pairs(data) do
		v.selected = false
	end
	data[key].selected = true
end

--[[ Select the first key option in data table
]]
function kLoot:Options_SetSelectedFirst(data)
	if not data or not type(data) == 'table' then return end
	for i,v in pairs(data) do
		self:Options_SetSelected(data, i)
		break
	end
end