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

-- Register privilege and chat command.
minetest.register_privilege("region_admin", "Can modify and remove all regions.")
minetest.register_privilege("region_effect", "Can set or remove and effect for own regions.")
minetest.register_privilege("region_mvp", "Can allow/disallow MvP for own regions.")
minetest.register_privilege("region_pvp", "Can allow/disallow PvP for own regions.")
minetest.register_privilege("region_set", "Can invite/ban guests or change owner of own regions.") 
minetest.register_privilege("region_mark", "Can set, remove and rename own regions and protect and open them.")




-- commands for all player (must minimum have the interact privileg
-- if a higher privileg is needed the function command_XXXX checks the privileg 
--[[
command:
	/region help {command}	- to get some more infos about a command. [privileg: interact]
	/region status  		- to get some more infos about the region at your position. [privileg: interact]
 	/region border  		- to make your region visible. [privileg: interact]
    /region border {name}	- to make the region of player name visible. [privileg: region_admin]
    /region border {id}		- to make the regionwith the id visible. [privileg: region_admin]
	/region own				- show a list of all your regions. [privileg: region_mark]
 	/region pos1  			- to set your position, this is needed to '/region set' your region. Go to one edge and call the command \'region pos1\'
 	/region pos2  			- to set your position, this is needed to '/region set' your region. If not done, go to one edge and call the command \'region pos2\'
	/region mark			- to select positions by punching two nodes. [privileg: region_mark]
 	/region max_y 			- to set the y-values of your region to 90% of the raz.max_height. 1/3 down and 2/3 up.  [privileg: region_mark]
	/region set {region_name} - to mark a region with the name {region_name}. This regions is NOT protected! [privileg: region_mark]
	/region remove {id}	- to remove YOUR region with the ID = {id}! [privileg: region_mark]
	/region remove {id/all} -  to remove {ID orALL} regions! A backup of th regions will be created \'raz_backup_{DATE}\'. Rename the backup to reimport the regions. [privileg: region_admin]
 	/region protect {id}	- to protect your own region. [privileg: region_mark]
 	/region open {id}		- to open your region for ALL players. [privileg: region_mark]
	/region invite {id} {player_name} - to invite this player into your region. Now the players can interact in the region and 'dig'. [privileg: region_set]
	/region ban {id} {player_name} - to ban this player from interacting in your region. [privileg: region_set]
 	/region change_owner" {id} {player_name} - to transfet YOUR region to an new player. The player must invite you if you want to interact in his NEW region. [privileg: region_set]
 	/region pvp {id} {+ or -} - to enable (+) or disable (-) PvP in your region. [privileg: region_pvp]
	/region mvp {id} {+ or -} - to enable (+) or disable (-) MvP in your region. Disable MvP if mobs can not harm player! [privileg: region_mvp]
	/region effect {hot,bot,holy,dor,choke,evil} - to set an effect in his region. Effects are hot {heal ofer time}, bot {breath over time}, holy, dot, choke, evil! [privileg: region_effect]
	/region export  		- to export the AreaStore to an file! [privileg: region_admin]
 	/region import  		- to import a region-export-file! [privileg: region_admin]
 	/region convert_areas  	- to convert an area from ShadowNinja areas to an export-file for raz! [privileg: region_admin]
 	/region import_areas  	- to import areas-export-file! [privileg: region_admin]
 	/region plot {id} {+ or -} - to enable (+) or disable (-). If the plot-attribut is set, a player can mark regions 'in' there. So a city can be protected and named but players can place there own regions in there. [privileg: region_admin]
 	/region city {id} {+ or -} - to enable (+) or disable (-). If the city-attribut is set, the region_admin can mark regions 'in' there with the building plot-attribute. So a city can be protected and named (by region_admin) but players can place there own regions. [privileg: region_admin]
 	/region player {player_name} - to show a list of all regions of this player! [privileg: region_admin]
]]--
minetest.register_chatcommand("region", {
	description = "Call \'region help <command>\' to get more information about the chatcommand.",
	params = "<help> <status> <own> <pos1> <pos2> <max_y> <set> <remove> <protect> <open> <invite> <ban> <change_owner> "..
			"<PvP> <MvP> <show> <border> <export> <import> <convert_areas> <import_areas> <plot> <city> <player>",
	privs = "interact", -- no spezial privileg
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local pos = vector.round(player:getpos())
		if not player then
			return false, "Player not found"
		end
		local err
		if param:sub(1, 4) == "help" then			
			err = raz:command_help(param,name)
		elseif param == "status" then			-- 'end' if param == 
			err = raz:command_status(name,pos)
		elseif param == "own" then				-- 'end' if param == 
			err = raz:command_own(name)
		elseif param == "pos1" then				-- 'end' if param == 
			err = raz:command_pos(name,pos,1)
		elseif param == "pos2" then 			-- 'end' if param == 
			err = raz:command_pos(name,pos,2)
		elseif param == "max_y" then 			-- 'end' if param == 
			err = raz:command_max_y(name)
		elseif param:sub(1, 3) == "set" then 	-- 'end' if param == 
			err = raz:command_set(param, name)
		elseif param:sub(1, 6) == "remove" then -- 'end' if param == 
			err = raz:command_remove(param, name)
		elseif param:sub(1, 7) == "protect" then-- 'end' if param == 
			err = raz:command_protect(param, name)
		elseif param:sub(1, 4) == "open" then	-- 'end' if param == 
			err = raz:command_open(param, name)
		elseif param:sub(1, 6) == "invite" then	-- 'end' if param == 
			err = raz:command_invite(param, name)
		elseif param:sub(1, 3) == "ban" then	-- 'end' if param == 
			err = raz:command_ban(param, name)
		elseif param:sub(1, 12) == "change_owner" then	-- 'end' if param == 
			err = raz:command_change_owner(param, name)
		elseif param:sub(1, 3) == "pvp" then	-- 'end' if param == 
			err = raz:command_pvp(param, name)
		elseif param:sub(1, 3) == "mvp" then	-- 'end' if param == 
			err = raz:command_mvp(param, name)
		elseif param:sub(1, 6) == "effect" then	-- 'end' if param == 
			err = raz:command_effect(param, name)
		elseif param:sub(1, 4) == "show" then	-- 'end' if param == 
			local numbers = string.split(param:sub(6, -1), " ")
			local header = true
			if numbers[1] == nil then		
				err = raz:command_show(header,name,nil,nil)
			else
				-- if numbers only contains strings then tonumber become 0 - no error_handling
				err = raz:command_show(header,name,tonumber(numbers[1]),tonumber(numbers[2]))
			end
		elseif param:sub(1, 6) == "border" then		-- 'end' if param == 
			err = raz:command_border(param, name)
		elseif param == "export" then 			-- 'end' if param == 
			-- check privileg region_admin
			if not minetest.check_player_privs(name, { region_admin = true }) then 
				err = 30 -- "msg: You don't have the privileg 'region_admin'! ",		
			end
			err = raz:export(raz.export_file_name)
			if err == 0 then
				raz:msg_handling(32, name)  -- 32 success
			end
		elseif param == "import" then 			-- 'end' if param == 
						-- check privileg region_admin
			if not minetest.check_player_privs(name, { region_admin = true }) then 
				err = 30 -- "msg: You don't have the privileg 'region_admin'! ",		
			end
			raz:import(raz.export_file_name)
		elseif param == "convert_areas" then 	-- 'end' if param ==
			-- check privileg region_admin
			if not minetest.check_player_privs(name, { region_admin = true }) then 
				err = 30 -- "msg: You don't have the privileg 'region_admin'! ",		
			end	 
			raz:convert_areas()					-- the function convert_areas is in the file convert.lua
		elseif param == "import_areas" then 	-- 'end' if param == 
			-- check privileg region_admin
			if not minetest.check_player_privs(name, { region_admin = true }) then 
				err = 30 -- "msg: You don't have the privileg 'region_admin'! ",		
			end
			raz:import(raz.areas_raz_export)	
		elseif param:sub(1, 4) == "plot" then
			err = raz:command_plot(param, name)
		elseif param:sub(1, 4) == "city" then
			err = raz:command_city(param, name)
		elseif param:sub(1, 6) == "player" then
			local header = true
			err = raz:command_player_regions(header,param, name)
		elseif param:sub(1, 4) == "mark" then
			err = raz:command_mark(param, name)
			

		elseif param ~= "" then 				-- if no command is found 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region\" for more information.")
		else
			minetest.chat_send_player(name, "Region chatcommands: Type \"/help region\" for more information.")
		end -- 'end' if param == 

		raz:msg_handling(err, name) --  message and error handling
	end -- end function(name, param)
})



