--[[
Region Areas and Zones
	an areas (or region or zone) mod that allows player (depending on privilegs)
	- to mark your (region / areas / zones) with name
	- to protect (region / areas / zones)
	- to invite / ban other players to interact in protected (region / areas / zones)
	- to allow / disallow PvP in (region / areas / zones)
	- to allow / disable Mobdamage [MvP] in (region / areas / zones)
	- to set (region / areas / zones) with an effect like hot, dot, holy, evil
	
	an (region / areas / zones) mod that allows the region_admin (privileg)
	- to create an named city (maybe portected)
	- set some building plots for the playes, so player can protect ther own (region / areas / zones) in the city

	
Copyright (c) 2019 
	ralf Weinert <downad@freenet.de>
Source Code: 	
	https://github.com/downad/raz
License: 
	GPLv3
]]--

-- set some regions
local data = ""
local do_not_check_player = false 	-- default: check player

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
local plot = true					-- default = false
 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,plot,do_not_check_player)
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
plot = false					-- default = false	
city = false					-- fefault = false

data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,plot,do_not_check_player)
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
plot = false					-- default = false	
city = false					-- fefault = false


 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,plot,do_not_check_player)
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
plot = false					-- default = false	
city = false					-- fefault = false


 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,plot,do_not_check_player)
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
plot = false					-- default = false	
city = false					-- fefault = false



data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,plot,do_not_check_player)
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


