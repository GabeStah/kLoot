local _G, _ = _G, _
local table, tinsert, tremove, wipe, sort, date, time, random = table, table.insert, table.remove, wipe, sort, date, time, random
local math, tostring, string, strjoin, strlen, strlower, strsplit, strsub, strtrim, strupper, floor, tonumber = math, tostring, string, string.join, string.len, string.lower, string.split, string.sub, string.trim, string.upper, math.floor, tonumber
local select, pairs, print, next, type, unpack = select, pairs, print, next, type, unpack
local loadstring, assert, error = loadstring, assert, error
local kLoot = _G.kLoot
kLoot.minRequiredVersion = '0.0.100';
kLoot.version = '0.0.100';
kLoot.versions = {};
kLoot.autoLootZoneSelected = 1
kLoot.autoLootWhitelistItemSelected = 1
kLoot.auctions = {}

kLoot.defaults = {
	profile = {
		autoloot = {
			enabled = false,
			whitelist = {},
			zones = {},
		},
		debug = {
			enabled = false,
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
		cvars = {
			matureLanguageFilterEnabled = false,
		},
	},
};
kLoot.timers = {};
kLoot.threading = {};
kLoot.threading.timers = {};
kLoot.threading.timerPool = {};
-- Create Options Table
kLoot.options = {
    name = "kLoot",
    handler = kLoot,
    type = 'group',
    args = {
		auction = {
			type = 'execute',
			name = 'auction',
			desc = 'Create an auction',
			func = function(...) 
				kLoot:Manual_Auction(...)
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

