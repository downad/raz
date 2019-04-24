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



--- chatcommand region list to show all region that i own or i am guest in

-- commands for all player (must minimum have the interact privileg
-- if a higher privileg is needed the function command_XXXX checks the privileg 
-- command: 'region status' lists details for the region the player is in.

minetest.register_chatcommand("region", {
	description = "Call \'region help <command>\' to get more information about the chatcommand.",
	params = "<help> <status> <own> <pos1> <pos2> <set_y> <set> <remove> <protect> <open> <invite> <ban> <change_owner> "..
			"<PvP> <MvP> <show> <export> <import> <convert_areas> <import_areas> <plot> <city> <player>",
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
		elseif param == "set_y" then 			-- 'end' if param == 
			err = raz:command_set_y(name)
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
		elseif param:sub(1, 3) == "PvP" then	-- 'end' if param == 
			err = raz:command_pvp(param, name)
		elseif param:sub(1, 3) == "MvP" then	-- 'end' if param == 
			err = raz:command_mvp(param, name)
		elseif param:sub(1, 6) == "effect" then
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
		elseif param:sub(1, 6) == "border" then
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
			

		elseif param ~= "" then 				-- if no command is found 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region\" for more information.")
		else
			minetest.chat_send_player(name, "Region chatcommands: Type \"/help region\" for more information.")
		end -- 'end' if param == 
		raz:msg_handling(err, name) --  message and error handling
	end -- end function(name, param)
})

--[[
minetest.register_chatcommand("showarea", {
	params = "",
	description = "highlights the boundaries of the current protected area",
	privs = {interact=true},
	func = function(name, param)
		minetest.log("action", "[" .. raz.modname .. "] chatcommand showarea name= "..tostring(name) )  

		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()		
		local pos1, pos2, center = raz:get_region_center_by_name_and_pos(name, pos)
		if pos1 ~= 34 then 
			minetest.log("action", "[" .. raz.modname .. "] chatcommand showarea pos = "..minetest.serialize(pos) )  
			minetest.log("action", "[" .. raz.modname .. "] chatcommand showarea entpos = "..minetest.serialize(center) )  
			center.y = (pos.y-1)
			local box = minetest.env:add_entity(center, "raz:showarea")	
			box:set_properties({
					visual_size={x=math.abs(pos1.x - pos2.x), y=math.abs(pos1.y - pos2.y)},
					collisionbox = {pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z},
				})
		end
	end,
})


]]--
