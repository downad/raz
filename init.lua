
-- namespace
-- raz = region, areas and zones
raz = {

	-- Paths and infos to the mod
	worlddir = minetest.get_worldpath(),
	modname = minetest.get_current_modname(),
	modpath = minetest.get_modpath(minetest.get_current_modname()),

	-- init AreaStore
	-- here is stored the edge1, edge2 and data field of an region. The data-field is an designed string that can be derialized to a table
	-- example:
	-- data = "return {[\"owner\"] = \"playername\", [\"region_name\"] = \"Meine Wiese mit Haus\" , [\"protected\"] = true, 
	--	[\"guests\"] = \"none/table\", [\"PvP\"] = false, [\"MvP\"] = true, [\"effect\"] = \"none\",  [\"parent\"] = true}"
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
	--			pvp_only_in_pvp_regions = true
	--				if there are more regions at the same position PvP = true in all
	--			pvp_only_in_pvp_regions = false
	--				if there are more regions at the same position PvP = false in all				 
	-- 	+	MvP: can Mobs damage the Player? e.g. in an city 
	--			default: true 
	--			false: in this region mobs do not harm Player
	--				if there are more regions at the same position MvP = false in all				 
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
	-- these attributes are set in the data-field
	region_attribute = {
		"owner", "region_name", "protect", "guest", "PvP", "MvP", "effect", "parent", 
	},
	-- these effects can be set
	region_effects = {
		"hot", "bot", "fot", "holy", "dot", "starve", "choke", "evil", 
	},

	-- some defaults for the AreaStore data
	default = {
		protected = false,
		guests = ",",		--empty list finals with ','
		PvP = false,
		MvP = true,
		effect = "none",
		parent = false,
		-- if 'digging in an protected region damage the player
		-- default: true
		do_damage_for_violation = true ,
 		-- the damage a player get for 'digging' in a protected region
		damage_on_protection_violation = 4,
		-- this is shown in hud if you are in an unmarked region
		wilderness = "You are in the wilderness!",
		hud_stringtext = "wilderness",
		hud_stringtext_pvp = "wilderness (PvP)",
	},

	-- some minimum values for the regions
	minimum_width = 2,			-- the smalest region for player is a square of 3 x 3
	minimum_height = 4,			-- the minimum high is 4 
	maximum_width = 100,		-- for player
	maximum_height = 60,			-- for player
	default_width = 3,			-- if a landrush module wille be created
	default_height = 3,			-- if a landrush module wille be created

	-- some values for the region effects
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

	-- init saved huds 
	player_huds = {},
	-- some color for the hud
	color = {
		red = "0xFF0000",
		orange = "0xFF8C00",
		purple = "0x800080", 
		yellow = "0xFFFF00",
		blue = "0x0000FF",
 		white = "0xFFFFFF",
		black = "0x000000",
	},

	-- init command_players for chatcommands
	command_players = {},


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
	--pvp_only_in_pvp_regions = false,


	-- defined Errortextes
	-- the functions 
	-- return = or an value -> NO ERROR
	-- return err or an number > 1 to show the error_text[number]
	error_text = { 
		[1] = "ERROR: No region with this ID! func: raz:delete_region(id)",
		[2] = "ERROR: No region with this ID! func: raz:region_set_attribute(id,bool)",
		[3] = "ERROR: No region with this ID! func: raz:get_region_data_by_id(id,no_deserialize)",
		[4] = "ERROR: File does not exist! func: raz:convert_areas() - File: "..minetest.get_worldpath() .."/areas.dat (if not changed)",
		[5] = "Success: areas.dat successfully exported! func: raz:convert_areas()",
		[6] = "ERROR: File does not exist! func: raz:import(import_file_name) - File: "..minetest.get_worldpath() .."/raz_store.dat (if not changed)",
		[7] = "ERROR: in update_regions_data! func: raz:region_set_attribute(id, region_attribute, bool)", 
		[8] = "msg: The region_attribute did not fit!",
		[9] = "msg: There is no Player with this name!",
		[10] = "msg: Wrong effect!",
		[11] = "msg: You are not the owner of this region!",
		[12] = "msg: No Player with this name is in the guestlist!",
		[13] = "ERROR: No Table returned func: raz:export(export_file_name)", 
		[14] = "NO PvP in this zone!",
		[15] = "msg: A Player with this name is already in your guestlist!",
		[16] = "msg: You don't have the privileg 'region_mark'! ",
		[17] = "msg: You don't have the privileg 'region_set'! ",
		[18] = "msg: You don't have the privileg 'region_pvp'! ",
		[19] = "msg: You don't have the privileg 'region_mvp'! ",
		[20] = "msg: You don't have the privileg 'interact'! ",
		[21] = "msg: Invalid usage.  Type \"/region help {command}\" for more information.",
		[22] = "msg: Your region is too small (x)! You can not mark this region",
		[23] = "msg: Your region is too small (z)! You can not mark this region",
		[24] = "msg: Your region is too small (y)! You can not mark this region",
		[25] = "msg: Your region is too width (x)! You can not mark this region",
		[26] = "msg: Your region is too width (z)! You can not mark this region",
		[27] = "msg: Your region is too hight (y)! You can not mark this region",
 		[28] = "msg: There are other region in. You can not mark this region",
 		[29] = "ERROR: No region with this ID! func: raz:get_region_datatable(id)",
		[30] = "msg: You don't have the privileg 'region_admin'! ",
		[31] = "ERROR: The effect dit not fit!",
		[32] = "msg: Success - regions exported!",
	},

}

-----------------------------------
-- load some .luas
-----------------------------------
--
-- the functions for this mod
dofile(raz.modpath.."/raz_lib.lua")			-- errorhandling: done
dofile(raz.modpath.."/command_func.lua")	-- errorhandling: done

-- load converter for ShadowNinja areas
dofile(raz.modpath.."/convert.lua")			-- errorhandling: done

-- init globalstep for the hud
dofile(raz.modpath.."/globalstep.lua") 		-- errorhandling: done

-- do effects 
dofile(raz.modpath.."/effect_func.lua")		-- errorhandling: done

-- create an hud
dofile(raz.modpath.."/hud.lua")				-- errorhandling: done

-- modify mintest-functions
dofile(raz.modpath.."/minetest_func.lua")	-- errorhandling: done


-- set priviles and commands
dofile(raz.modpath.."/privs_command.lua")	-- errorhandling: done	



-- load regions from file
-- fill AreaStore()
local err = raz:load_regions_from_file()
raz:msg_handling(err)

-- all done then ....
minetest.log("action", "[" .. raz.modname .. "] successfully loaded .lua!")












