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

--#---------------------------------------
--
-- functions to handle chat commands
--
--#---------------------------------------




-----------------------------------------
--
-- command help
-- privileg: interact
--
-----------------------------------------
-- called: 'region help {command}'
-- sends the player a list with details of the regions chat commands
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling: 
-- return 20 --"msg: You don't have the privileg 'interact'! ",
-- return 0	-- no error
function raz:command_help(param, name)
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 20 -- "msg: You don't have the privileg 'interact'! ",
	end
	-- value[1] == 'help'
	local value = string.split(param, " ") 
	local command = value[2]
	if command == nil then command = "" end
	minetest.log("action", "[" .. raz.modname .. "] raz:command_help param: "..tostring(param)) 
	minetest.log("action", "[" .. raz.modname .. "] raz:command_help command: "..tostring(command)) 
	local chat_start = "Call command 'region "..command  
	if command == "help" then
		chat_end = chat_start.." {command}' to get some more infos about this command. [privileg: interact]"
	elseif command == "status" then
		chat_end = chat_start.."' to get some more infos about the region at your position. [privileg: interact]"
	elseif command == "border" then
		chat_end = chat_start.."' to make your region visible. [privileg: interact]"..
			"The region_admin can call \'region border {name}\' to make the region of player name visible. [privileg: region_admin]"
	elseif command == "own" then
		chat_end = chat_start.."' show a list of all your regions. [privileg: region_mark]"
	elseif command == "pos1" then
		chat_end = chat_start.."' to set your position, this is needed to mark/set your region. Go to one edge and call the command \'region pos1\', "..
			"go to the second edge and use the command \'region pos2\'. With \'region set {region_name}\' can zu mark your region. [privileg: region_mark]"
	elseif command == "pos2" then
		chat_end = chat_start.."' to set your position, this is needed to mark/set your region. Go to one edge and call the command \'region pos1\',"..
			" go to the second edge and use the command \'region pos2\'. With \'region set {region_name}\' can zu mark your region.  [privileg: region_mark]"
	elseif command == "set_y" then
		chat_end = chat_start.."' to set the y-values of your region to 90% of the max_height. 1/3 down and 2/3 up.  [privileg: region_mark]"
	elseif command == "set"	then
		chat_end = chat_start.." {region_name}' to mark a region with the name {region_name}. This regions is NOT protected! Go to one edge and call "..
			"the command \'region pos1\', go to the second edge and use the command \'region pos2\'. With \'region set {region_name}\' can zu mark your region.  [privileg: region_mark]"
	elseif command == "remove" then
		chat_end = chat_start.." {id}' to remove YOUR region with the ID = {id}! [privileg: region_mark]"..
			"The region_admin can call \'region remove all\' to remove ALL regions! A backup of th regions will be created \'raz_backup_{DATE}\'."..
			"Rename the backup to reimport the regions. [privileg: region_admin]"
	elseif command == "protect" then
		chat_end = chat_start.." {id}' to protect your own region. [privileg: region_mark]"
	elseif command == "open" then
		chat_end = chat_start.." {id}' to open your region for ALL players. [privileg: region_mark]"
	elseif command == "invite" then
		chat_end = chat_start.." {id} {player_name}' to invite this player into your region. Now the players can interact in the region and 'dig'. [privileg: region_set]"
	elseif command == "ban" then
		chat_end = chat_start.." {id} {player_name}' to ban this player from interacting in your region. [privileg: region_set]"
	elseif command == "change_owner" then
		chat_end = chat_start.." {id} {player_name}' to transfet YOUR region to an new player. The player must invite you if you want to interact in his NEW region. [privileg: region_set]"
	elseif command == "pvp" then
		chat_end = chat_start.." {id} {+ or -}' to enable (+) or disable (-) PvP in your region. [privileg: region_pvp]"
	elseif command == "mvp" then
		chat_end = chat_start.." {id} {+ or -}' to enable (+) or disable (-) MvP in your region. Disable MvP if mobs can not harm player! [privileg: region_mvp]"
	elseif command == "effect" then
		chat_end = chat_start.." {hot,bot,holy,dor,choke,evil}' set an effect in his region. Effects are hot {heal ofer time}, bot {breath over time}, "..
			"holy, dot, choke, evil! [privileg: region_effect]"
	elseif command == "export" then
		chat_end = chat_start.."' to export the AreaStore to an file! [privileg: region_admin]"
	elseif command == "import" then
		chat_end = chat_start.."' to import a region-export-file! [privileg: region_admin]"
	elseif command == "convert_areas" then
		chat_end = chat_start.."' to convert an area from ShadowNinja areas to an export-file for raz! [privileg: region_admin]"
	elseif command == "import_areas" then
		chat_end = chat_start.."' to import areas-export-file! [privileg: region_admin]"
	elseif command == "plot" then
		chat_end = chat_start.." {id} {+ or -}' to enable (+) or disable (-). If the plot-attribut is set, a player can mark regions 'in' there. "..
			"So a city can be protected and name but players can place there own regions. [privileg: region_admin]"
	elseif command == "city" then
		chat_end = chat_start.." {id} {+ or -}' to enable (+) or disable (-). If the city-attribut is set, the region_admin can mark regions 'in' there with the building plot-attribute."..
			"So a city can be protected and named (by region_admin) but players can place there own regions. [privileg: region_admin]"
	elseif command == "player" then
		chat_end = chat_start.." {player_name}' show a list of all regions of this player! [privileg: region_admin]"
	



	else
		chat_end = "The command is unknown!"
	end
	minetest.chat_send_player(name, chat_end)
	return 0
 end

-----------------------------------------
--
-- command status
-- privileg: interact
--
-----------------------------------------
-- called: 'region status'
-- sends the player a list with details of the regions
-- input:
--		name 	(string) 	of the player
--		pos 	(table)		of the player
-- msg/error handling: 
-- return 20 --"msg: You don't have the privileg 'interact'! ",
-- return 0	-- no error
function raz:command_status(name,pos)
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 20 --"msg: You don't have the privileg 'interact'! ",		
	end
	for region_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
		local counter = 1
		if region_id then
			local header = "status" 
			-- call command_show (without header!)
			raz:msg_handling( raz:command_show(header, name,region_id,nil) ) --  message and error handling
			counter = counter + 1	
		else
			minetest.chat_send_player(name, raz.default.wilderness)
		end -- end if regions_id then
	end -- end for regions_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
	return 0
end
 
-----------------------------------------
--
-- command pos1 or pos2
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region pos1' or 'region pos2'
-- sends the player a list with details of the regions
-- input:
--		name 	(string) 	of the player
--		pos 	(table)		of the player
-- 		edge	(number)	1, 2 for the edges
-- msg/error handling:
-- return err if privileg is missing
-- return 0 - no error
function raz:command_pos(name,pos,edge)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	if edge == 1 then	
		if not raz.command_players[name] then
			raz.command_players[name] = {pos1 = pos}
		else
			raz.command_players[name].pos1 = pos
		end
		minetest.chat_send_player(name, "Position 1: " .. minetest.pos_to_string(pos))
		raz.markPos1(name)
	elseif edge == 2 then
		if not raz.command_players[name] then
			raz.command_players[name] = {pos2 = pos}
		else
			raz.command_players[name].pos2 = pos
		end
		minetest.chat_send_player(name, "Position 2: " .. minetest.pos_to_string(pos))
		raz.markPos2(name)
	end
	return 0
end

-----------------------------------------
--
-- command pos1 or pos2
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region mark' 
-- Select positions by punching two nodes.
-- input:
-- 		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return 36 - no error: "msg: Select positions by punching two nodes."
function raz:command_mark(param, name)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	-- set set_command for the registered punchnode to
	-- pos1
	raz.set_command[name] = "pos1"
	return 36
end

-----------------------------------------
--
-- command set_y
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region set_y'
-- modifies y1 and y2 to 90% of max_height
-- input:
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return 0 - no error
function raz:command_set_y(name)

	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	if not raz.command_players[name] or not raz.command_players[name].pos1 then
		minetest.chat_send_player(name, "Position 1 missing, use \"/region pos1\" to set.")
	elseif not raz.command_players[name].pos2 then
		minetest.chat_send_player(name, "Position 2 missing, use \"/region pos2\" to set.")
	else
		local pos1 = raz.command_players[name].pos1
		local pos2 = raz.command_players[name].pos2
		minetest.chat_send_player(name, "Position 1 = "..minetest.serialize(pos1))
		minetest.chat_send_player(name, "Position 2 = "..minetest.serialize(pos2))
		-- find the down and upper edge		
		-- what is missing to 90% of maximum_height?
		local y_diff =  math.abs(raz.maximum_height * 0.9) - math.abs(pos1.y - pos2.y) 
		-- 1/3 to the down
		local y_min = math.abs(y_diff / 3)
		-- 2/3 into the sky
		local y_max = y_diff - y_min
		minetest.chat_send_player(name, "y_diff = "..minetest.serialize(y_diff))
		-- a max_height check is not necessary. if the region is to height the min and max will be reduced
		if pos1.y < pos2.y then
			pos1.y = pos1.y - y_min
			pos2.y = pos2.y + y_max
		else
			pos1.y = pos1.y + y_max
			pos2.y = pos2.y - y_min
		end
		raz.command_players[name] = { pos1 = pos1, pos2 = pos2 }
		minetest.chat_send_player(name, "after maximum: Position 1 = "..minetest.serialize(pos1))
		minetest.chat_send_player(name, "after maximum: Position 2 = "..minetest.serialize(pos2))

		minetest.chat_send_player(name, "The height of pos1/pos2 is modified!")
	end
	return 0
end


-----------------------------------------
--
-- command own
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region own'
-- sends the player a list with all his regions
-- input:
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err - no error / raz:command_player_regions(header,name)
function raz:command_own(name)
	local header = "own"
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	err = raz:command_player_regions(header,"player "..name, name)
	return err
end

-----------------------------------------
--
-- command set
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region set {region_name} 
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return 0 - no error
function raz:command_set(param, name) 
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	local region_name = param:sub(5, -1)
	if not raz.command_players[name] or not raz.command_players[name].pos1 then
		minetest.chat_send_player(name, "Position 1 missing, use \"/region pos1\" to set.")
	elseif not raz.command_players[name].pos2 then
		minetest.chat_send_player(name, "Position 2 missing, use \"/region pos2\" to set.")
	elseif string.len(region_name) < 1 then
		minetest.chat_send_player(name, "please set a name behind set, use \"/region set {region_name}\" to set.")
	else
		-- check if the player canAdd this!
		err = raz:player_can_mark_region(raz.command_players[name].pos1,raz.command_players[name].pos2, name)
		if err ~= true then
			return err
		end
		
		local data = raz:create_data(name,region_name) 
		if data == 1 then
			minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
		else
			raz:set_region(raz.command_players[name].pos1,raz.command_players[name].pos2,data)
			minetest.chat_send_player(name, "Region with the name >"..region_name.."< set!")
		end
		raz.command_players[name] = nil
	end
	return 0
end


-----------------------------------------
--
-- command remove
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region remove {id} 
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return 0 - no error
function raz:command_remove(param, name)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	local id = tonumber(param:sub(8, -1))
	if id ~= nil then
		if raz.raz_store:get_area(id) then
			local data_table = raz:get_region_datatable(id)
			if name == data_table.owner or minetest.check_player_privs(name, { region_admin = true }) then
				-- make a backup of all region, use date
				local backup = raz.backup_file_name..(os.date("%y%m%d_%H%M%S")..".dat" )
				err = raz:export(backup)
				if err then
					raz:delete_region(id)
					minetest.chat_send_player(name, "The region with ID: "..tostring(id).." was removed!")	
				end
			else
				minetest.chat_send_player(name, "You are not the owner of the region with the ID: "..tostring(id).."!")
			end
		else
			minetest.chat_send_player(name, "There is no region with ID: "..tostring(id).."!")					
		end
	elseif param:sub(8, -1) == "all" and minetest.check_player_privs(name, { region_admin = true }) then
		-- make a backup of all region, use date
		local backup = raz.backup_file_name..(os.date("%y%m%d_%H%M%S")..".dat" )
		err = raz:export(backup)
		minetest.log("action", "[" .. raz.modname .. "] remove all - backupfile = "..backup)
		if err then
			minetest.log("action", "[" .. raz.modname .. "] remove all - backup done!")
			while raz.raz_store:get_area(1) do
				raz:delete_region(1)
			end
			raz.raz_store = AreaStore()
		else
			raz:msg_handling( err, name ) --  message and error handling
		end
	else
		minetest.chat_send_player(name, "Region with the ID: "..tostring(id).." is unknown!")
	end
	return 0
end


-----------------------------------------
--
-- command protect
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region protect {id} 
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function raz:command_protect(param, name)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	-- get the args after protect
	-- it must be an id of an region that is owned by name
	local value = string.split(param:sub(8, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help protect\" for more information.")
		return 21 --"Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		err = raz:region_set_attribute(name, value[1], "protect", true)
		--raz:msg_handling(err, name) --  message and error handling
	end
	return err
end

-----------------------------------------
--
-- command open
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region open {id} 
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function raz:command_open(param, name)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	-- get the args after open
	-- it must be an id of an region that is owned by name
	local value = string.split(param:sub(5, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help open\" for more information.")
		return 21 --"Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		err = raz:region_set_attribute(name, value[1], "protect", false)
		--raz:msg_handling(err, name) --  message and error handling
	end
	return err
end


-----------------------------------------
--
-- command invite player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region invite {id} {playername}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function raz:command_invite(param, name)
	-- check privileg
	local err = raz:has_region_set(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(8, -1), " ") 
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help invite\" for more information.")
		return 21 -- invalie useage
	else
		local invite = true
		err = raz:region_set_attribute(name, value[1], "guest", value[2], invite)
		--raz:msg_handling(err, name) --  message and error handling
	end
	return err
end

-----------------------------------------
--
-- command ban player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region ban {id} {playername}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function raz:command_ban(param, name)
	-- check privileg
	local err = raz:has_region_set(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after ban
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help ban\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		local invite = false
		err = raz:region_set_attribute(name, value[1], "guest", value[2], invite)
		--raz:msg_handling(err, name) --  message and error handling
	end
	return err
end


-----------------------------------------
--
-- command change_owner id player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region change_owner {id} {playername}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function raz:command_change_owner(param, name)
	-- check privileg
	local err = raz:has_region_set(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after change_owner
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(13, -1), " ") --string.trim(param:sub(7, -1))
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help change_owner for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	else
		err = raz:region_set_attribute(name, value[1], "owner", value[2]) 
		--raz:msg_handling(err, name) --  message and error handling
	end
	return err
end


-----------------------------------------
--
-- command pvp +/-
-- privileg: region_pvp
--
-----------------------------------------
-- called: 'region pvp {id} {+/-}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function raz:command_pvp(param, name)
	-- check privileg
	local err = raz:has_region_pvp(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help pvp\" for more information.")
	elseif value[2] == "+" or value[2] == true then
		err = raz:region_set_attribute(name, value[1], "PvP", true) 
		--raz:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false then 
		err = raz:region_set_attribute(name, value[1], "PvP", false) 
		--raz:msg_handling(err, name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help pvp\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	end
	return err
end


-----------------------------------------
--
-- command mvp +/-
-- privileg: region_mvp
--
-----------------------------------------
-- called: 'region mvp {id} {+/-}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function raz:command_mvp(param, name)
	-- check privileg
	local err = raz:has_region_mvp(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end	
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help mvp\" for more information.")
	elseif value[2] == "+" or value[2] == true then
		err = raz:region_set_attribute(name, value[1], "MvP", true) 
		--raz:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false then 
		err = raz:region_set_attribute(name, value[1], "MvP", false) 
		--raz:msg_handling(err, name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help mvp\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	end
	return err
end


-----------------------------------------
--
-- command show 
-- privileg: region_admin *or call by command_status
--
-----------------------------------------
-- called: 'region show' <id1> <id2>  		<optional>
-- sends the player a list of regions
-- msg/error handling:
-- return 0 - no error
function raz:command_show(header, name,list_start,list_end)
--	local region_values = {}
--	local pos1 = ""
--	local pos2 = ""
--	local data = ""
	local chat_string = ""
	local chat_string_start = "### List of Regions ###"
	if header == false or header == "status" then
		chat_string_start = ""
	end
	-- no privileg chek: header == status then command_show is called by command_status 
	-- else privileg region_admin 
	local err = minetest.check_player_privs(name, { region_admin = true })
	if header ~= "status" then
		if not err then 
			return 30 -- "msg: You don't have the privileg 'region_admin'! ",		
		end	 
	end

	-- if list_start is not set
	-- list_end is also not set
	-- list all, from 0 to end (-1)
	if list_start == nil then
		list_start = 0
		list_end = -1
	elseif list_end == nil then
		-- list_start is set an list_end not 
		-- show regions with id = list_start
		list_end = list_start
	end

	-- end < start then change start and end
	if list_end < list_start and list_end ~= -1 then
		local changer = list_end
		list_end = list_start 
		list_start = changer
	end
	
	local stop_list = list_end
	local counter = list_start

	-- get all regions in AreaStore()
	while raz.raz_store:get_area(counter) do
		if counter <= stop_list or stop_list < 0 then
			err = raz:get_data_string_by_id(counter)
			if type(err) ~= "string" then
				return err
			else
				chat_string = chat_string..err
			end 
		end -- if counter <= stop_list or stop_list < 0 then
		counter = counter + 1
	end --while raz.raz_store:get_area(counter) do
	minetest.chat_send_player(name, chat_string_start..chat_string..".")
	return 0
end



-----------------------------------------
--
-- command player 
-- privileg: region_admin *or call by command_status
--
-----------------------------------------
-- called: 'region player <player_name>'
-- sends the player a list of all regions from player_name
-- msg/error handling:
-- return 0 - no error
function raz:command_player_regions(header,param, name)
	local player_name = param:sub(8, -1)
	minetest.log("action", "[" .. raz.modname .. "] command_player_regions param: {" .. tostring(param).."}")
	minetest.log("action", "[" .. raz.modname .. "] command_player_regions param:sub(8,-1): >" .. tostring(player_name).."<")
	local chat_string = ""
	local chat_string_start = "### List of "..player_name.." Regions ###"
	if header == false or header == "own" then
		chat_string_start = ""
	end
	-- no privileg chek: header == own then command_player_regions is called by command_own 
	-- else privileg region_admin 
	local err = minetest.check_player_privs(name, { region_admin = true })
	if header ~= "own" then
		if not err then 
			return 30 -- "msg: You don't have the privileg 'region_admin'! ",		
		end	 
	end
	-- check if player_name exists
	if not minetest.player_exists(player_name) then --player then
		return 9 -- "ERROR: There is no Player with this name! func: raz:region_set_attribute(name, id, region_attribute, value)",
	end	
		
	local counter = 1

	-- get all regions in AreaStore()
	while raz.raz_store:get_area(counter) do
		-- only look for player_name as owner
		if raz:get_region_attribute(counter, "owner") == player_name then
			err = raz:get_data_string_by_id(counter)
			if type(err) ~= "string" then
				return err
			else
				chat_string = chat_string..err
			end 
		end -- if counter <= stop_list or stop_list < 0 then
		counter = counter + 1
	end --while raz.raz_store:get_area(counter) do
	minetest.chat_send_player(name, chat_string_start..chat_string..".")
	return 0
end
--+++++++++++++++++++++++++++++++++++++++
--
-- Export the AreaStore() to a file 
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		export_file_name as string-file-path
-- Export the AreaStore table to a file
-- the export-file has this format, 3 lines: [min/pos1], [max/pos2], [data]
-- 		return {["y"] = -15, ["x"] = -5, ["z"] = 154}
-- 		return {["y"] = 25, ["x"] = 2, ["z"] = 160}
--		return {["owner"] = "adownad", ["region_name"] = "dinad Weide", ["protected"] = false, ["guests"] = ",", ["PvP"] = false, ["MvP"] = true, ["effect"] = "dot", ["plot"] = false}
-- msg/error handling:
-- return 0 - no error
-- return err from io.open
-- return 13 -- "ERROR: No Table returned func: raz:export(export_file_name)", 
function raz:export(export_file_name)
	local file_name = raz.worlddir .."/".. export_file_name --raz.export_file_name
	local file, err

	-- open/create a new file for the export
	file, err = io.open(file_name, "w")
	if err then	
		--minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file_name) :"..tostring(raz:file_exists(file_name))) 
		minetest.log("error", "[" .. raz.modname .. "] file, err = io.open(file_name, w) ERROR :"..err) 
		return err
	end
	io.close(file)
	
	-- open file for append
	file = io.open(file_name, "a")

	--local region_values = {} 
	local pos1 = ""
	local pos2 = ""
	local data = ""
	local counter = 0
	-- loop AreaStore and write for every region 3 lines [min/pos1], [max/pos2], [data]
	while raz.raz_store:get_area(counter) do

		--region_values = raz.raz_store:get_area(counter,true,true)
		--pos1 = region_values.min
		--pos2 = region_values.max
		--data = region_values.data
		pos1,pos2,data = raz:get_region_data_by_id(counter,true)
		if type(pos1) ~= "table" then
			return 13 -- "ERROR: No table returned func: raz:export(export_file_name)", 
		end
		counter = counter + 1
		file:write(minetest.serialize(pos1).."\n")
		file:write(minetest.serialize(pos2).."\n")
		file:write(data.."\n")
	end
	file:close()
	-- No Error
	return 0
end

--+++++++++++++++++++++++++++++++++++++++
--
-- Load the exported AreaStore() from file
--
--+++++++++++++++++++++++++++++++++++++++
-- input: import_file_name as string-file-path
-- msg/error handling:
-- return 0 - no error
-- return 6 -- "ERROR: File does not exist!  func: func: raz:import(import_file_name) - File: "..minetest.get_worldpath() .."/raz_store.dat (if not changed)",
function raz:import(import_file_name)
	local counter = 1
	local pos1 
	local pos2
	local data
 
	-- does the file exist?
	local file = raz.worlddir .."/"..import_file_name 
	--minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file) :"..tostring(raz:file_exists(file))) 
	if raz:file_exists(file) ~= true then
		--minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file) :"..tostring(raz:file_exists(file))) 
		minetest.log("error", "[" .. raz.modname .. "] raz:file_exists(file) :"..file.." does not exist!") 
		return 6 -- "ERROR: File does not exist!  func: func: raz:import(import_file_name) - File: "..minetest.get_worldpath() .."/raz_store.dat (if not changed)",
	end		
	-- load every line of the file 
	local lines = raz:lines_from(file)

	-- loop all lines, step 3 
	-- set pos1, pos2 and data and raz:set_region
	while lines[counter] do
		-- deserialize to become a vector
		pos1 = minetest.deserialize(lines[counter])
		pos2 = minetest.deserialize(lines[counter+1])
		-- is an string
	 	data = lines[counter+2]

		raz:set_region(pos1,pos2,data)
	 	counter = counter + 3
	end
	-- Save AreaStore()
	raz:save_regions_to_file()
	-- No Error
	return 0
end


-----------------------------------------
--
-- command border
-- privileg: interact
--
-----------------------------------------
-- called: 'region border {name}' id you are region_admin
-- shows a box over the region
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling: 
-- return 20 --"msg: You don't have the privileg 'interact'! ",
-- return 0	-- no error
function raz:command_border(param, name)
	-- check privs
	if not minetest.check_player_privs(name, { interact = true }) then 
		return 20 --"msg: You don't have the privileg 'interact'! ",		
	end
	local is_region_admin = minetest.check_player_privs(name, { region_admin = true })
	-- get values of param
	local value = string.split(param:sub(7, -1), " ") 
	-- region ID = nil -> no region
	local region_id  = nil	
	local pos1, pos2, data 
	local center
	minetest.log("action", "[" .. raz.modname .. "] chatcommand command_border value[1] = {"..tostring(value[1]).."}" )  
	--local player = minetest.get_player_by_name(owner)
	local player = minetest.env:get_player_by_name(name)
	local pos = player:getpos()		
	local owner = name
	if is_region_admin and value[1] ~= nil then
		if minetest.player_exists(value[1]) == true then
			owner = value[1]
		end
		-- maybe a region ID is committed
		if raz.raz_store:get_area(tonumber(value[1])) then 
			region_id = tonumber(value[1])
		end
	end 
	
	-- two cases:
	-- case 1 region_id == nil 
	-- 		get pos1, pos2, center by name and pos
	if region_id == nil then 
		minetest.log("action", "[" .. raz.modname .. "] chatcommand command_border owner = "..owner )  
		pos1, pos2, center = raz:get_region_center_by_name_and_pos(owner, pos)
	else
	-- case2 - region id is set
		pos1,pos2,data = raz:get_region_data_by_id(region_id)	
		minetest.log("action", "[" .. raz.modname .. "] chatcommand command_border region_id = "..tostring(region_id) )  
		center = raz:get_center_of_box(pos1, pos2)
	end
	minetest.log("action", "[" .. raz.modname .. "] chatcommand command_border pos1 = "..minetest.serialize(pos1) ) 
	minetest.log("action", "[" .. raz.modname .. "] chatcommand command_border pos2 = "..minetest.serialize(pos2) ) 
	minetest.log("action", "[" .. raz.modname .. "] chatcommand command_border center = "..tostring(center) ) 
 
	if type(center) == "table" then 
		minetest.log("action", "[" .. raz.modname .. "] chatcommand command_border pos = "..minetest.serialize(pos) )  
		minetest.log("action", "[" .. raz.modname .. "] chatcommand command_border center = "..minetest.serialize(center) )  
		center.y = (center.y-1)
		local box = minetest.env:add_entity(center, "raz:showarea")	
		box:set_properties({
				visual_size={x=math.abs(pos1.x - pos2.x), y=math.abs(pos1.y - pos2.y), z=math.abs(pos1.z - pos2.z)},
				collisionbox = {pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z},
			})
	else 
		minetest.chat_send_player(name, "No region found!")
	end
end
-----------------------------------------
--
-- command plot +/-
-- privileg: region_mvp
--
-----------------------------------------
-- called: 'region plot {id} {+/-}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
-- return err form minetest.check_player_privs(name, { region_admin = true })
function raz:command_plot(param, name)
	-- check privileg
	local err = minetest.check_player_privs(name, { region_admin = true })
	if not err then 
		return 30 -- "msg: You don't have the privileg 'region_admin'! ",		
	end	 
		
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(5, -1), " ") 
	minetest.log("action", "[" .. raz.modname .. "] command_plot! inputvalue param = "..tostring(param).." name = "..name )  
	minetest.log("action", "[" .. raz.modname .. "] command_plot! value = "..tostring(value) )  
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region plot\" for more information.")
	elseif value[2] == "+" or value[2] == true then
		err = raz:region_set_attribute(name, value[1], "plot", true) 
		--raz:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false then 
		err = raz:region_set_attribute(name, value[1], "plot", false) 
		--raz:msg_handling(err, name) --  message and error handling
	else	
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help plot\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	end
	return err
end

-----------------------------------------
--
-- command city ID +/-
-- privileg: region_mvp
--
-----------------------------------------
-- called: 'region city {id} {+/-}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
-- return err form minetest.check_player_privs(name, { region_admin = true })
function raz:command_city(param, name)
	-- check privileg
	local err = minetest.check_player_privs(name, { region_admin = true })
	if not err then 
		return 30 -- "msg: You don't have the privileg 'region_admin'! ",		
	end	 
		
	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(5, -1), " ") 
	minetest.log("action", "[" .. raz.modname .. "] command_city! inputvalue param = "..tostring(param).." name = "..name )  
	minetest.log("action", "[" .. raz.modname .. "] command_city! value = "..tostring(value) )  
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region city\" for more information.")
	elseif value[2] == "+" or value[2] == true then
		err = raz:region_set_attribute(name, value[1], "city", true) 
		--raz:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false then 
		err = raz:region_set_attribute(name, value[1], "city", false) 
		--raz:msg_handling(err, name) --  message and error handling
	else	
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help city\" for more information.")
		return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
	end
	return err
end


-----------------------------------------
--
-- command effect
-- privileg: region_admin
--
-----------------------------------------
-- called: 'region effect {id} {effect}
-- input:
--		param 	(string)
--		name 	(string) 	of the player
-- msg/error handling:
-- return err if privileg is missing
-- return err = return from region_set_attribute
-- return 21 -- "Invalid usage.  Type \"/region help {command}\" for more information.",
function raz:command_effect(param, name)
	-- check privileg
	local err = raz:has_region_effect(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return err
	end
	-- get the args after effect
	-- value[1]: it must be an id of an region 
	-- value[2]: must be the effect
	local value = string.split(param:sub(7, -1), " ") 
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help effect\" for more information.")
		return 21 -- invalie useage
	else
		-- check effect is in raz.region_effects
		if not raz:string_in_table(value[2], raz.region_effects) then
			return 31 -- "ERROR: The effect dit not fit! ",
		end
		err = raz:region_set_attribute(name, value[1], "effect", value[2])
	end
	return err
end


-----------------------------------------
--
-- Check Privilegs
--
-----------------------------------------
--
--
-----------------------------------------
--
-- player has_region_mark
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string
-- msg/error handling: 
-- return true
-- return 16 - for error
function raz:has_region_mark(name)
	if minetest.check_player_privs(name, { region_mark = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 16 -- "You dont have the privileg 'region_mark' "
end
-----------------------------------------
--
-- player has_region_set
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string
-- msg/error handling: 
-- return true
-- return 17 - for error
function raz:has_region_set(name)
	if minetest.check_player_privs(name, { region_set = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 17 -- "You dont have the privileg 'region_set' "
end
-----------------------------------------
--
-- player has_region_pvp
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string
-- msg/error handling: 
-- return true
-- return 18 - for error
function raz:has_region_pvp(name)
	if minetest.check_player_privs(name, { region_pvp = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 18 -- "You dont have the privileg 'region_pvp' "
end
-----------------------------------------
--
-- player has_region_mvp
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string-- msg/error handling: 
-- return true
-- return 19 - for error
function raz:has_region_mvp(name)
	if minetest.check_player_privs(name, { region_mvp = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 19 -- "You dont have the privileg 'region_mvp' "
end
-----------------------------------------
--
-- player has_region_mvp
--
-----------------------------------------
-- check if name has the privileg or is admin
-- input:
--		name 		as string-- msg/error handling: 
-- return true
-- return 19 - for error
function raz:has_region_effect(name)
	if minetest.check_player_privs(name, { region_effect = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 33 -- "You dont have the privileg 'region_effect' "
end
