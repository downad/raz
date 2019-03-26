
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
	--	+	guest:	players who can 'dig' in the raz. thy can not modify the region		
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
	raz_store = AreaStore(),

	-- some defaults for the AreaStore data
	default = {
		protected = false,
		guests = ",",		--empty list finals with ','
		PvP = false,
		MvP = true,
		effect = "none",
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


}

-- load some other .luas
dofile(raz.modpath.."/logger.lua")
dofile(raz.modpath.."/globalstep.lua")
dofile(raz.modpath.."/raz_func.lua")
dofile(raz.modpath.."/effect_func.lua")
dofile(raz.modpath.."/hud.lua")
dofile(raz.modpath.."/minetest_func.lua")
dofile(raz.modpath.."/privs_command.lua")


minetest.log("action", "[" .. raz.modname .. "] successfully loaded .lua!")


-- load regions form file
raz:load_regions_from_file()
-- update raz.regions
raz:update_regions()


--for debuging an exercises :)

-- set some regions
local data = ""

-- test 1
-- vector(x,y,z) y -> up/down
local pos1 = vector.new(0, -15, 128)  	-- down
local pos2 = vector.new(-6, 25, 136)	-- up
local owner = "adownad"
local region_name = "Mein Haus"
local protected = true				-- default = false
local guest = ""					-- default = ""
local guest1 = "dinad"
local guest2 = "elrond"
local guests = {}
	table.insert(guests, guest1)
	table.insert(guests, guest2)
	local guests_string = raz:table_to_string(guests)	
local PvP = true					-- default = false		
local MvP = true					-- default = true
local effect = "none"				-- default = none
 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end

--test 2
-- vector(x,y,z) y -> up/down
pos1 = vector.new(2, -15, 160)  	-- down
pos2 = vector.new(-5, 25, 154)		-- up
owner = "dinad"
region_name = "dinad Weide"
protected = false				-- default = false
guest = ""						-- default = ""
guests = {}
	table.insert(guests, guest)
	guests_string = raz:table_to_string(guests)	
PvP = false						-- default = false		
MvP = true						-- default = true
effect = "dot"					-- default = none
 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end

--test 3
-- vector(x,y,z) y -> up/down
pos1 = vector.new(-10, -15, 141)  	-- down
pos2 = vector.new(11, 25, 116)		-- up
owner = "adownad"
region_name = "Meine Garten um das Haus"
protected = true					-- default = false
guest = "downad"					-- default = ""
guests = {}
	table.insert(guests, guest)
	 guests_string = raz:table_to_string(guests)	
PvP = false						-- default = false		
MvP = true						-- default = true
effect = "none"					-- default = none
 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end

--test 4
-- vector(x,y,z) y -> up/down
pos1 = vector.new(-15, -15, 148)  	-- down
pos2 = vector.new(-11, 25, 146)		-- up
owner = "adownad"
region_name = "Tempel"
protected = true					-- default = false
guest = ""							-- default = ""
guests = {}
	table.insert(guests, guest)
	 guests_string = raz:table_to_string(guests)	
PvP = false						-- default = false		
MvP = true						-- default = true
effect = "holy"					-- default = none
 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end


--test 5
-- vector(x,y,z) y -> up/down
pos1 = vector.new(13, -15, 148)  	-- down
pos2 = vector.new(15, 25, 150)		-- up
owner = "downad"
region_name = "Evil Tempel"
protected = true					-- default = false
guest = ""							-- default = ""
guests = {}
	table.insert(guests, guest)
	 guests_string = raz:table_to_string(guests)	
PvP = true						-- default = false		
MvP = true						-- default = true
effect = "evil"					-- default = none
 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end

-- print a list of all raz.regions
raz:print_regions()



-- only for debugging

minetest.log("action", "[" .. raz.modname .. "] some regions created!")

-- Regiontest 
local test_id = 0
local counter = 0
while raz.raz_store:get_area(counter) do
	raz:print_region_datatable_for_id(counter)
	counter = counter + 1
end











