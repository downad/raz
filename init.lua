
-- namespace
-- raz = region, areas and zones
raz = {

	-- Paths and infos to the mod
	worlddir = minetest.get_worldpath(),
	modname = minetest.get_current_modname(),
	modpath = minetest.get_modpath(minetest.get_current_modname()),

	-- init AreaStore
	-- here is stored the min, max and data field of an raz. The data-field is an designed string that can be derialized to a table
	-- example:
	-- data = "return {[\"owner\"] = \"playername\", [\"region_name\"] = \"Meine Wiese mit Haus\" , [\"protected\"] = true, 
	--	[\"guest\"] = \"none/table\", [\"PvP\"] = false, [\"MvP\"] = true, [\"effect\"] = \"none\"}"
	-- 	design:
	-- 	+	owner: the owner of the region, he can modify the region-flags
	--	+	region_name: the name of the region, shown e.g. in the hud
	--	+	protected: is region protected?
	--			default: false	
	-- 			true: only owner and guest can 'dig' in the region
	--			true: if the parent region is protected, then owners region must be procted
	--	+	guest:	players who can 'dig' in the raz. thy can not modify the region		
	--			default: ""
	--			someone is guest in an region if he is guest in that region or he is guest in the parent region
	-- 	+	PvP: is PvP allowed in this region? (global PvP must be enable)
	--			default: false
	-- 			true: PvP is allowed in the region - players can damage other players
	-- 	+	MvP: can Mobs damage the Player? e.g. in an city 
	--			default: true 
	--			false: in this region mobs do not harm Player
	--	+	effect:	this region do something to all players, also the owner!  
	--			default: none
	-- 			hot: heal over time 
	-- 			fot: feed over time 						-- will implement later
	-- 			bot: breath ober time
	-- 			holy: heal, breath (and feed)  over time
	-- 			dot: damage over time
	-- 			starve: reduce food over time 				-- will implement later
	-- 			choke: reduce breath over time
	-- 			evil: steals blood, breath (and food) over time
	--	+ 	parent: if the region is marked as parent, other can set a region in that region.
	--			default: false
	--			e.g. the admin marks a city, the player can build houses in the city.
	--			special flags:
	--			protected: 	protected by admin, the player can mark a region, that region is protected for the player owner, he can not remove protected
	--						only marked by the admin, the player can mark a region, that region is protected for the player but he can(!) remove protected
	--			PvP:	if the region is marked as PvP - zone the player can not remove PvP
	--			MvP:	if the region is marked as MvP - zone the player can not remove MvP
	--			effects: a zone with an effect can not become parent, no player can mark a region there
	raz_store = AreaStore(),

	-- some defaults for the AreaStore data
	default = {
		protected = false,
		guests = ",",		--empty list finals with ','
		PvP = false,
		MvP = true,
		effect = "none",
		parent = false,
 		-- the damage a player get for 'digging' in a protected region
		damage_on_protection_violation = 4,
		-- this is shown in hud if you are in an unmarked region
		wilderness = "You are in the wilderness!",
	},

	-- soem values for the region effects
	effect = {
		-- the interval of dealing effects
		time = 1,
		-- life gaining 1 HP per effect_time seconds 	
		hot = 1,
		-- food gaining 1 per effect_time seconds 	
		--effect_fot = 1,
		-- breath gaining 1 per effect_time seconds 	
		bot = 1,
		-- loosing life 1 HP per effect_time seconds 	
		dot = 1,
		-- loosing food 1  per effect_time seconds 	
		--effect_starve = 1,
		-- loosing breath 5 per effect_time seconds 	
		choke = 5,
	},
	-- the filename for AreaStore
	store_file_name = "raz_store.dat",
	export_file_name ="raz_export.dat",
	areas_file = "areas.dat",
	areas_raz_export = "areas_raz_export.dat",

	regions = {},

	-- init saved huds 
	player_huds = {},
	-- som color for the hud
	color = {
		red = "0xFF0000",
		orange = "0xFF8C00",
		purple = "0x800080", 
		yellow = "0xFFFF00",
		blue = "0x0000FF",
 		white = "0xFFFFFF",
		black = "0x000000",
	},
	-- init region_player for chatcommands
	command_players = {},

	-- a debug bool
--	debug = false,
	debug = true,

	-- some defaults
	-- global PvP in minetest.conf
	enable_pvp = minetest.settings:get_bool("enable_pvp"),

	-- from settingtypes.txt
	-- PvP in PvP-regions
	-- is pvp_only_in_pvp_regions = true
	-- 		then PvP is only allowed in region with PvP = true. 
	-- 		that means: is PvP allowed in one area at this position PvP is allowed in all! 
	-- is pvp_only_in_pvp_regions = false
	-- 		then PvP is allowed everythere. 
	-- 		has one region at the position PvP = false then PvP is forbidden in all! 
	-- true: only PvP in region with the PvP-Flag true
	-- false: PvP all over the world, but regions with PvP = false are safe.
	-- default: true 
	pvp_only_in_pvp_regions = minetest.settings:get_bool('pvp_only_in_pvp_regions', true),

	error_text = { 
		[1] = "No region with this ID! func: raz:delete_region(id)",
		[2] = "No region with this ID! func: raz:region_set_parent(id,bool)",
		[3] = "No region with this ID! func: raz:get_region_data_by_id(id,no_deserialize)",
		[4] = "No region with this ID! func: ",
		[5] = "No region with this ID! func: ",
		[6] = "No region with this ID! func: ",
		[7] = "No region with this ID! func: ",
		[8] = "No region with this ID! func: ",
		[9] = "No region with this ID! func: ",
		[10] = "No region with this ID! func: ",
		[11] = "No region with this ID! func: ",
		[12] = "No region with this ID! func: ",
	},

}

-- load some other .luas
dofile(raz.modpath.."/logger.lua")
dofile(raz.modpath.."/globalstep.lua")
dofile(raz.modpath.."/raz_func.lua")
dofile(raz.modpath.."/effect_func.lua")
dofile(raz.modpath.."/hud.lua")
dofile(raz.modpath.."/minetest_func.lua")
dofile(raz.modpath.."/convert.lua")
dofile(raz.modpath.."/privs_command.lua")



minetest.log("action", "[" .. raz.modname .. "] successfully loaded .lua!")


-- load regions form file
raz:load_regions_from_file()
-- update raz.regions
raz:update_regions()


--for debuging an exercises :)
--dofile(raz.modpath.."/debug.lua")










