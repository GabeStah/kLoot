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
			'Dougallxin',
			'Kulldar',
			'Kainhighwind',
			'Takaoni',
			'Tree',
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
        version = {
			type = 'execute',
			name = 'Version',
			desc = 'Check your kLoot version',
			func = function() 
				kLoot:Print("Version: |cFF"..kLoot:RGBToHex(0,255,0)..kLoot.version.."|r");
			end,
			guiHidden = true,
        },
	},
};

--[[ Implement default settings
]]
function kLoot:Options_Default()
	self:Options_DefaultBidding()
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

--[[ Generate all custom options tables
]]
function kLoot:Options_Generate()
	-- Bidding
	self:Options_GenerateBiddingOptions()
end

--[[ Create the custom bidding sets options
]]
function kLoot:Options_GenerateBiddingOptions()
	self.options.args.bidding.args.sets.args = {}
	-- Loop through bidTypes, create that dropdown
	self.options.args.bidding.args.sets.args.bidTypes = {
		name = 'Bid Types',
		type = 'select',
		desc = 'Select the Bid Type to edit.',
		style = 'dropdown',
		values = function() return self.bidTypes end,
		get = function(info)
			-- Regenerate sets
			self:Set_Generate()
			return self:Options_GetSelected(self.db.profile.bidding.sets, 'key')
		end,
		set = function(info,value)
			self:Options_SetSelected(self.db.profile.bidding.sets, value)
		end,
		order = 1,
	}	
	self.options.args.bidding.args.sets.args.addon = {
		name = 'Addon',
		type = 'select',
		desc = 'Select the addon where your set exists.',
		style = 'dropdown',
		values = function() return self:Set_AddonList() end,
		get = function(info)
			local data = self:Options_GetSelected(self.db.profile.bidding.sets, 'value')
			return data.addon
		end,
		set = function(info,value)
			local data = self:Options_GetSelected(self.db.profile.bidding.sets, 'value')
			data.addon = value
			-- Unset the set
			data.set = nil
		end,
		order = 2,
	}
	self.options.args.bidding.args.sets.args.set = {
		name = 'Set',
		type = 'select',
		desc = 'Select the set to associate with this Bid Type.',
		style = 'dropdown',
		values = function()
			-- Get sets for selected addon
			local data = self:Options_GetSelected(self.db.profile.bidding.sets, 'value')
			return self:Set_ListByAddon(data.addon) or {}
		end,
		get = function(info)
			local data = self:Options_GetSelected(self.db.profile.bidding.sets, 'value')
			return data.set
		end,
		set = function(info,value)
			local data = self:Options_GetSelected(self.db.profile.bidding.sets, 'value')
			data.set = value
		end,
		order = 3,
	}
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
				end
			end
		end
	end
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