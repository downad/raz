-- Register privilege and chat command.
minetest.register_privilege("region_admin", "Can modify and remove all regions.")
--minetest.register_privilege("region_lv5", "Can set or remove and effect for own regions.")
--minetest.register_privilege("region_lv4", "Can allow/disallow MvP for own regions.")
--minetest.register_privilege("region_lv3", "Can allow/disallow PvP for own regions.")
--minetest.register_privilege("region_lv2", "Can protect and open own regions.")
--minetest.register_privilege("region_lv1", "Can set and remove own regions and protect and open them.")
-- new privilegs?
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
	params = "<help> <status> <pos1><pos2><set><remove><protect><open>",
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
		elseif param == "pos1" then				-- 'end' if param == 
			err = raz:command_pos(name,pos,1)
		elseif param == "pos2" then 			-- 'end' if param == 
			err = raz:command_pos(name,pos,2)
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

		elseif param:sub(1, 4) == "show" then	-- 'end' if param == 
			local numbers = string.split(param:sub(6, -1), "-")
			if numbers[1] == nil then		
				err = raz:region_show(name,nil,nil)
			else
				-- if numbers only contains strings then tonumber become 0 - no error_handling
				err = raz:region_show(name,tonumber(numbers[1]),tonumber(numbers[2]))
			end
			raz:msg_handling(err) --  message and error handling
		elseif param == "export" then -- 'end' if param == 
			err = raz:export(raz.export_file_name)
			raz:msg_handling(err) --  message and error handling
		elseif param == "import" then -- 'end' if param == 
			raz:import(raz.export_file_name)
			raz:msg_handling(err) --  message and error handling
		elseif param == "convert_areas" then -- 'end' if param == 
			raz:convert_areas()		
			raz:error_handling(err) -- error handling
		elseif param == "import_areas" then -- 'end' if param == 
			raz:import(raz.areas_raz_export)	
			raz:error_handling(err) -- error handling
		elseif param:sub(1, 6) == "parent" then
			local value = string.split(param:sub(7, -1), " ") 
			if value[1] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_special\" for more information.")
			elseif value[2] == "+" or value[2] == true then
				err = raz:region_set_attribute(name, value[1], "parent", true) 
				raz:msg_handling(err, name) --  message and error handling
			elseif value[2] == "-" or value[2] == false then 
				err = raz:region_set_attribute(name, value[1], "parent", false) 
				raz:msg_handling(err, name) --  message and error handling
			end	




		elseif param ~= "" then 				-- if no command is found 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region\" for more information.")
		else
			minetest.chat_send_player(name, "Region chatcommands: Type \"/help region\" for more information.")
		end -- 'end' if param == 
		raz:msg_handling(err, name) --  message and error handling
	end -- end function(name, param)
})


--[[

-- command for player with privileg region_lv1
--"region_lv1" ==> Can set and remove own regions.
-- this command allows to set an area.
-- go to one edge and call the command 'region_mark pos1'
-- go to the second edge and call the command 'region_mark pos2'
-- call 'region_mark set' with the name for the region
-- player can also remove his regions
minetest.register_chatcommand("region_mark", {
	description = "Mark, set and remove regions. \nGo to one edge and call the command \'region_mark pos1\', \ngo to the second edge and use the command \'region_mark pos2\'. \nWith \'region_mark set <region_name>\' can zu mark your region. \n\'region_mark remove <id>\' removes your region.",
	params = "<pos1> <pos2> <set> <remove>",
	privs = "region_lv1",
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		if param == "pos1" then
			if not raz.command_players[name] then
				raz.command_players[name] = {pos1 = pos}
			else
				raz.command_players[name].pos1 = pos
			end
			minetest.chat_send_player(name, "Position 1: " .. minetest.pos_to_string(pos))
		elseif param == "pos2" then -- 'end' if param == 
			if not raz.command_players[name] then
				raz.command_players[name] = {pos2 = pos}
			else
				raz.command_players[name].pos2 = pos
			end
			minetest.chat_send_player(name, "Position 2: " .. minetest.pos_to_string(pos))
		elseif param:sub(1, 3) == "set" then -- 'end' if param == 
			local region_name = param:sub(5, -1)
			if not raz.command_players[name] or not raz.command_players[name].pos1 then
				minetest.chat_send_player(name, "Position 1 missing, use \"/region_mark pos1\" to set.")
			elseif not raz.command_players[name].pos2 then
				minetest.chat_send_player(name, "Position 2 missing, use \"/region_mark pos2\" to set.")
			elseif string.len(region_name) < 1 then
				minetest.chat_send_player(name, "please set a name behind set, use \"/region_mark set <name>\" to set.")
			else
				local data = raz:create_data(name,region_name) --,raz.default.protected, raz.default.guests,raz.default.PvP,raz.default.MvP,raz.default.effect)
				if data == 1 then
					minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
				else
					raz:set_region(raz.command_players[name].pos1,raz.command_players[name].pos2,data)
					minetest.chat_send_player(name, "Region with the name >"..region_name.."< set!")
				end
				raz.command_players[name] = nil
			end
		elseif param:sub(1, 6) == "remove" then -- 'end' if param == 
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
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_mark\" for more information.")
		end -- 'end' if param == 
	end -- end func = function(name, param)
})

-- command for player with privileg region_lv2
--"region_lv2" ==> Can enable/disable protection and invite/ban guests on own regions.
minetest.register_chatcommand("region_set", {
	description = "Player can protect or open his region, invite or ban guests.\n Call \'region_set protect <id>\' to protect your region, with \'region_set open <id>\' you remove the protection.\n \'region_set invite <name>\' the player with <name> can 'dig' in the protected region, \'region_set ban <name>\' disallow the player to 'dig' there.",
	params = "<protect> <open> <invite> <ban>",
	privs = "region_lv2",
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		local err
		if param:sub(1, 7) == "protect" then
			-- get the args after protect
			-- it must be an id of an region that is owned by name
			local value = string.split(param:sub(8, -1), " ") 
			if value[1] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_set\" for more information.")
			else
				err = raz:region_set_attribute(name, value[1], "protect", true)
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param:sub(1, 4) == "open" then
			-- get the args after open
			-- it must be an id of an region that is owned by name
			local value = string.split(param:sub(5, -1), " ") 
			if value[1] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_set\" for more information.")
			else
				err = raz:region_set_attribute(name, value[1], "protect", false)
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param:sub(1, 6) == "invite" then
			-- get the args after protect
			-- it must be an id of an region that is owned by name
			local value = string.split(param:sub(8, -1), " ") 
			if value[1] == nil or value[2] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_set\" for more information.")
			else
				local invite = true
				err = raz:region_set_attribute(name, value[1], "guest", value[2], invite)
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param:sub(1, 3) == "ban" then
			-- get the args after open
			-- it must be an id of an region that is owned by name
			local value = string.split(param:sub(4, -1), " ") 
			if value[1] == nil or value[2] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_set\" for more information.")
			else
				local invite = false
				err = raz:region_set_attribute(name, value[1], "guest", value[2], invite)
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_set\" for more information.")
		end -- 'end' if param == 
	end -- end func = function(name, param)

})

-- command for player with privileg region_lv3
--"region_lv3" ==> Can enable/disable PvP on own regions.
minetest.register_chatcommand("region_pvp", {
	description = "Playerenable/disable PvP.\n Call \'region_pvp PvP <+/->\'.",
	params = "<PvP>",
	privs = "region_lv3",
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		local err
		if param:sub(1, 3) == "PvP" then
			-- get the args after protect
			-- it must be an id of an region that is owned by name
			local value = string.split(param:sub(4, -1), " ") 
			if value[1] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_pvp\" for more information.")
			elseif value[2] == "+" or value[2] == true then
				err = raz:region_set_attribute(name, value[1], "PvP", true) 
				raz:msg_handling(err, name) --  message and error handling
			elseif value[2] == "-" or value[2] == false then 
				err = raz:region_set_attribute(name, value[1], "PvP", false) 
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_pvp\" for more information.")
		end -- 'end' if param == 
	end -- end func = function(name, param)
})


-- command for player with privileg region_lv4
--"region_lv4" ==> Can enable/disable PvP on own regions.
minetest.register_chatcommand("region_mvp", {
	description = "Playerenable/disable MvP.\n Call \'region_mvp MvP <+/->\'.",
	params = "<MvP>",
	privs = "region_lv4",
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		local err
		if param:sub(1, 3) == "MvP" then
			-- get the args after protect
			-- it must be an id of an region that is owned by name
			local value = string.split(param:sub(4, -1), " ") 
			if value[1] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_mvp\" for more information.")
			elseif value[2] == "+" or value[2] == true then
				err = raz:region_set_attribute(name, value[1], "MvP", true) 
				raz:msg_handling(err, name) --  message and error handling
			elseif value[2] == "-" or value[2] == false then 
				err = raz:region_set_attribute(name, value[1], "MvP", false) 
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_mvp\" for more information.")
		end -- 'end' if param == 
	end -- end func = function(name, param)
})


]]--
-- commands for the region_admin
-- command: 'region_special show' lists all region 
--			'region_special show 3' shows only the region with the id 3
--			'region_special show 3-5' shows all regions from id 3 to id 5
-- command: 'region_special export' exports the AreaStore() to file
-- command: 'region_special import' imports a exported file
-- command: 'region_special convert_areas' conversts an area.dat file and exports it 
-- command: 'region_special import_areas' imports the exported area.dat file
-- command: 'region_special parent 3 +' marks the region id 3 with the parent attribute
-- 			'region_special parent 3 -' removes the parent attribute	
-- command: 'region_special change_owner <id> <new owner>' 
minetest.register_chatcommand("region_special", {
	description = "Some special commands for the region-admin!\n 'region_special show' lists all regions, 'region_special show 3' shows only the region with the id 3, \n'region_special show 3-5' shows all regions from id 3 to id 5.\nThe command 'region_special export' exports the AreaStore() to file, 'region_special import' imports it.\n'region_special convert_areas' conversts from ShadowNinja areas the area.dat file and exports it.\nWith 'region_special import_areas' the exported area.dat file imported.\n'region_special parent 3 +' marks the region id 3 with the parent attribute. 'region_special parent 3 -' removes it.\n To change an owner of an region: 'region_special change_owner <id> <new owner>' ",
	params = "<show> <import> <export> <convert_areas> <import_areas> <parent>",
	privs = "region_admin",
	func = function(name, param)
		--local pos = vector.round(minetest.get_player_by_name(name):getpos())
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		local err = ""
		if param:sub(1, 4) == "show" then
			local numbers = string.split(param:sub(6, -1), "-")
			if numbers[1] == nil then		
				err = raz:region_show(name,nil,nil)
			else
				-- if numbers only contains strings then tonumber become 0 - no error_handling
				err = raz:region_show(name,tonumber(numbers[1]),tonumber(numbers[2]))
			end
			raz:msg_handling(err) --  message and error handling
		elseif param == "export" then -- 'end' if param == 
			err = raz:export(raz.export_file_name)
			raz:msg_handling(err) --  message and error handling
		elseif param == "import" then -- 'end' if param == 
			raz:import(raz.export_file_name)
			raz:msg_handling(err) --  message and error handling
		elseif param == "convert_areas" then -- 'end' if param == 
			raz:convert_areas()		
			raz:error_handling(err) -- error handling
		elseif param == "import_areas" then -- 'end' if param == 
			raz:import(raz.areas_raz_export)	
			raz:error_handling(err) -- error handling
		elseif param:sub(1, 6) == "parent" then
			local value = string.split(param:sub(7, -1), " ") 
			if value[1] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_special\" for more information.")
			elseif value[2] == "+" or value[2] == true then
				err = raz:region_set_attribute(name, value[1], "parent", true) 
				raz:msg_handling(err, name) --  message and error handling
			elseif value[2] == "-" or value[2] == false then 
				err = raz:region_set_attribute(name, value[1], "parent", false) 
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param:sub(1, 12) == "change_owner" then
			local value = string.split(param:sub(13, -1), " ") --string.trim(param:sub(7, -1))
			if value[1] == nil or value[2] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_special\" for more information.")
			else
				err = raz:region_set_attribute(name, value[1], "owner", value[2]) 
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_special\" for more information.")
		end -- end if param == 
	end -- end func = function(name, param)
})
	


