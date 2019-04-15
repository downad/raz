--#---------------------------------------
--
-- functions to handle commands
--
--#---------------------------------------




-----------------------------------------
--
-- command help
-- privileg: interact
--
-----------------------------------------
-- called: 'region help {command}'
-- sends the player a list with details of the regions
-- input:
--		name 	(string) 	of the player
-- msg/error handling:
-- return false - on error
function raz:command_help(param, name)
	if not minetest.check_player_privs(name, { interact = true }) then 
		return false		
	end
	-- value[1] == 'help'
	local value = string.split(param, " ") 
	local command = value[2]
	minetest.log("action", "[" .. raz.modname .. "] raz:command_help param: "..tostring(param)) 
	minetest.log("action", "[" .. raz.modname .. "] raz:command_help command: "..tostring(command)) 
	local chat_start = "Call command 'region "..command  
	if command == "help" then
	elseif command == "status" then
		chat_end = chat_start.."' to get some more infos about the region at your position. [privileg: interact]"
	elseif command == "pos1" then
		chat_end = chat_start.."' to set your position, this is needed to mark/set your region. Go to one edge and call the command \'region pos1\', "..
			"go to the second edge and use the command \'region pos2\'. With \'region set {region_name}\' can zu mark your region. [privileg: region_mark]"
	elseif command == "pos2" then
		chat_end = chat_start.."' to set your position, this is needed to mark/set your region. Go to one edge and call the command \'region pos1\',"..
			" go to the second edge and use the command \'region pos2\'. With \'region set {region_name}\' can zu mark your region.  [privileg: region_mark]"
	elseif command == "set"	then
		chat_end = chat_start.." {region_name}' to mark a region with the name {region_name}. This regions is NOT protected! Go to one edge and call "..
			"the command \'region pos1\', go to the second edge and use the command \'region pos2\'. With \'region set {region_name}\' can zu mark your region.  [privileg: region_mark]"
	elseif command == "remove" then
		chat_end = chat_start.." {id}' to remove YOUR region with the ID = {id}! [privileg: region_mark]"
	elseif command == "protect" then
		chat_end = chat_start.." {id}' to protect your own region. [privileg: region_mark]"
	elseif command == "open" then
		chat_end = chat_start.." {id}' to open your region for ALL players. [privileg: region_mark]"
	elseif command == "invite" then
		chat_end = chat_start.." {id} {player_name}' to invite this player into your region. Now the players can interact in the region and 'dig'. [privileg: region_set]"
	elseif command == "ban" then
		chat_end = chat_start.." {id} {player_name}' to ban this player from interacting in your region. [privileg: region_set]"
	elseif command == "cange_owner" then
		chat_end = chat_start.." {id} {player_name}' to transfet YOUR region to an new player. The player must invite you if you want to interact in his NEW region. [privileg: region_set]"
	elseif command == "pvp" then
		chat_end = chat_start.." {id} {+ or -}' to enable (+) or disable (-) PvP in your region. [privileg: region_pvp]"
	elseif command == "mvp" then
		chat_end = chat_start.." {id} {+ or -}' to enable (+) or disable (-) MvP in your region. Disable MvP if mobs can not harm player! [privileg: region_mvp]"
	




	else
		chat_end = "The command is unknown!"
	end
	minetest.chat_send_player(name, chat_end)
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
-- return false - on error
function raz:command_status(name,pos)
	if not minetest.check_player_privs(name, { interact = true }) then 
		return false		
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
-- return 0 - no error
function raz:command_pos(name,pos,edge)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end
	if edge == 1 then	
		if not raz.command_players[name] then
			raz.command_players[name] = {pos1 = pos}
		else
			raz.command_players[name].pos1 = pos
		end
		minetest.chat_send_player(name, "Position 1: " .. minetest.pos_to_string(pos))
	elseif edge == 2 then
		if not raz.command_players[name] then
			raz.command_players[name] = {pos2 = pos}
		else
			raz.command_players[name].pos2 = pos
		end
		minetest.chat_send_player(name, "Position 2: " .. minetest.pos_to_string(pos))
	end
end


-----------------------------------------
--
-- command set
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region set {region_name} 
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_set(param, name) 
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
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
		local data = raz:create_data(name,region_name) 
		if data == 1 then
			minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
		else
			raz:set_region(raz.command_players[name].pos1,raz.command_players[name].pos2,data)
			minetest.chat_send_player(name, "Region with the name >"..region_name.."< set!")
		end
		raz.command_players[name] = nil
	end
end


-----------------------------------------
--
-- command remove
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region remove {id} 
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_remove(param, name)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end
	local id = tonumber(param:sub(8, -1))
	if id ~= nil then
		if raz.raz_store:get_area(id) then
			local data_table = raz:get_region_datatable(id)
			if name == data_table.owner or minetest.check_player_privs(name, { region_admin = true }) then
				raz:delete_region(id)
				minetest.chat_send_player(name, "The region with ID: "..tostring(id).." was removed!")	
			else
				minetest.chat_send_player(name, "You are not the owner of the region with the ID: "..tostring(id).."!")
			end
		else
			minetest.chat_send_player(name, "There is no region with ID: "..tostring(id).."!")					
		end
	else
		minetest.chat_send_player(name, "Region with the ID: "..tostring(id).." is unknown!")
	end
end


-----------------------------------------
--
-- command protect
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region protect {id} 
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_protect(param, name)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end
	-- get the args after protect
	-- it must be an id of an region that is owned by name
	local value = string.split(param:sub(8, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help protect\" for more information.")
	else
		err = raz:region_set_attribute(name, value[1], "protect", true)
		raz:msg_handling(err, name) --  message and error handling
	end
end

-----------------------------------------
--
-- command open
-- privileg: region_mark
--
-----------------------------------------
-- called: 'region open {id} 
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_open(param, name)
	-- check privileg
	local err = raz:has_region_mark(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end
	-- get the args after open
	-- it must be an id of an region that is owned by name
	local value = string.split(param:sub(5, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help open\" for more information.")
	else
		err = raz:region_set_attribute(name, value[1], "protect", false)
		raz:msg_handling(err, name) --  message and error handling
	end
end


-----------------------------------------
--
-- command invite player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region invite {id} {playername}
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_invite(param, name)
	-- check privileg
	local err = raz:has_region_set(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(8, -1), " ") 
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help invite\" for more information.")
	else
		local invite = true
		err = raz:region_set_attribute(name, value[1], "guest", value[2], invite)
		raz:msg_handling(err, name) --  message and error handling
	end
end

-----------------------------------------
--
-- command ban player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region ban {id} {playername}
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_ban(param, name)
	-- check privileg
	local err = raz:has_region_set(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end	-- get the args after ban
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help ban\" for more information.")
	else
		local invite = false
		err = raz:region_set_attribute(name, value[1], "guest", value[2], invite)
		raz:msg_handling(err, name) --  message and error handling
	end
end


-----------------------------------------
--
-- command change_owner id player
-- privileg: region_set
--
-----------------------------------------
-- called: 'region change_owner {id} {playername}
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_change_owner(param, name)
	-- check privileg
	local err = raz:has_region_set(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end	-- get the args after change_owner
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be a name of a player
	local value = string.split(param:sub(13, -1), " ") --string.trim(param:sub(7, -1))
	if value[1] == nil or value[2] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help change_owner" for more information.")
	else
		err = raz:region_set_attribute(name, value[1], "owner", value[2]) 
		raz:msg_handling(err, name) --  message and error handling
	end
end


-----------------------------------------
--
-- command pvp +/-
-- privileg: region_pvp
--
-----------------------------------------
-- called: 'region pvp {id} {+/-}
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_pvp(param, name)
	-- check privileg
	local err = raz:has_region_pvp(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help pvp\" for more information.")
	elseif value[2] == "+" or value[2] == true then
		err = raz:region_set_attribute(name, value[1], "PvP", true) 
		raz:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false then 
		err = raz:region_set_attribute(name, value[1], "PvP", false) 
		raz:msg_handling(err, name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help pvp\" for more information.")
	end
end


-----------------------------------------
--
-- command mvp +/-
-- privileg: region_mvp
--
-----------------------------------------
-- called: 'region mvp {id} {+/-}
-- input:
--		name 	(string) 	of the player
--		param 	(string)	
-- msg/error handling: self
function raz:command_mvp(param, name)
	-- check privileg
	local err = raz:has_region_mvp(name)
	if err ~= true then
		raz:msg_handling( err, name ) --  message and error handling
		return false
	end	-- get the args after invite
	-- value[1]: it must be an id of an region that is owned by name
	-- value[2]: must be + or -
	local value = string.split(param:sub(4, -1), " ") 
	if value[1] == nil then
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help mvp\" for more information.")
	elseif value[2] == "+" or value[2] == true then
		err = raz:region_set_attribute(name, value[1], "MvP", true) 
		raz:msg_handling(err, name) --  message and error handling
	elseif value[2] == "-" or value[2] == false then 
		err = raz:region_set_attribute(name, value[1], "MvP", false) 
		raz:msg_handling(err, name) --  message and error handling
	else
		minetest.chat_send_player(name, "Invalid usage.  Type \"/region help mvp\" for more information.")
	end
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
	local region_values = {}
	local pos1 = ""
	local pos2 = ""
	local data = ""
	local chat_string = "### List of Regions ###\n"
	if header == false or header == "status" then
		chat_string = ""
	end
	-- no privileg chek: header == status then command_show is called by command_status 
	-- else privileg region_admin 
	if header ~= "status" then
		if not minetest.check_player_privs(name, { region_admin = true }) then 
			return false		
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
			region_values = raz.raz_store:get_area(counter,true,true)
			pos1 = "["..region_values.min.x..","..region_values.min.y..","..region_values.min.z.."]"
			pos2 = "["..region_values.max.x..","..region_values.max.y..","..region_values.max.z.."]"
			data = minetest.deserialize(region_values.data)
			chat_string = chat_string..data.region_name.."(ID "..counter..") owned by "..data.owner.." \n( "..pos1.." / "..pos2.." )"
			if data.protected then
				chat_string = chat_string..", is protected"
			end
			if data.guests ~= (nil or ",") then 
				chat_string = chat_string..", Guests: "..data.guests--.."\n"
			end
			if data.PvP then
				chat_string = chat_string..", PvP enable"
			end
			if data.MvP == false then
				chat_string = chat_string..", Mobs do no damage"
			end
			if data.effect ~="none" then
				chat_string = chat_string..", effects: " ..tostring(data.effect)
			end
			if data.parent then
				chat_string = chat_string..", is parent"
			end
		end -- if counter <= stop_list or stop_list < 0 then
		counter = counter + 1
	end --while raz.raz_store:get_area(counter) do
	minetest.chat_send_player(name, chat_string..".")
	return 0
end






--[[
function raz:get_region_status(pos)
	local chat_string = ""
	for regions_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
		if regions_id then
			--if raz.raz_store:get_area(regions_id) then
			local region_data = raz:get_region_datatable(regions_id) 
			-- name of the region
			local region_name = region_data.region_name
			-- owner of the region
			local owner = region_data.owner
			-- is it protected?
			-- true: only owner can 'dig' there
			local protected = region_data.protected
			-- guests
			local guests = region_data.guests
			-- is this an PvP region?
			-- true: PvP is allowed in there - player can damage other player
			local PvP = region_data.PvP
			-- can Mobs damage the Player?
			-- false: in this region mobs do not harm Player
			local MvP = region_data.MvP
			-- has the region a special effect?
			-- hot: heal over time 
			-- fot: feed over time
			-- bot:	breath ober time
			-- holy: heal, feed an breath over time
			-- dot: damage over time
			-- starve: reduce food over time
			-- choke: reduce breath over time
			-- evil: steals food, blood, breath over time
			local effect = region_data.effect
			chat_string = chat_string.."\n("..counter..") - "..region_name.." owned by "..owner..".\n"
			if protected then
				chat_string = chat_string.." The region is protected!" 
			else
				chat_string = chat_string.." There is no protection." 
			end
			if string.len(guests) > 1 then
				chat_string = chat_string.." Guests: "..guests..".\n"
			end 
			if PvP then
				chat_string = chat_string.." PvP is allowed." 
			end
			if MvP then
				chat_string = chat_string.." Mobs can damage you." 
			end
			if effect ~= "none" then
				chat_string = chat_string.."\n This region has the effect: "..effect 
			end
			counter = counter + 1	
		end -- end if regions_id then
	end -- end for regions_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
	if chat_string == "" then
		return raz.default.wilderness
	end
	return chat_string
end

]]--


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
-- check ich name has the privileg or is admin
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
-- check ich name has the privileg or is admin
-- msg/error handling: 
-- return true
-- return 16 - for error
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
-- check ich name has the privileg or is admin
-- msg/error handling: 
-- return true
-- return 16 - for error
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
-- check ich name has the privileg or is admin
-- msg/error handling: 
-- return true
-- return 16 - for error
function raz:has_region_mvp(name)
	if minetest.check_player_privs(name, { region_mvp = true }) then 
		return true		
	end
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true		
	end
	return 19 -- "You dont have the privileg 'region_mvp' "
end


