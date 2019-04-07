-- Register privilege and chat command.
minetest.register_privilege("region_admin", "Can set, remove and modify all regions.")
minetest.register_privilege("region_lv5", "Can set, remove and effect for own regions.")
minetest.register_privilege("region_lv4", "Can set, remove and allow MvP for own regions.")
minetest.register_privilege("region_lv3", "Can set, remove and allow PvP for own regions.")
minetest.register_privilege("region_lv2", "Can set, remove, protect own regions.")
minetest.register_privilege("region_lv1", "Can set, remove own regions.")


-- commands for all player
-- command: 'region status' lists detais for the region the player is in.
minetest.register_chatcommand("region", {
	description = "Show a list of this regions with all data.\n Call \'region status\' to get an detailed view of the region you are in.",
	params = "<status>",
	privs = "interact", -- no spezial priv
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local pos = vector.round(player:getpos())
		if not player then
			return false, "Player not found"
		end
		local counter = 1
		if param == "status" then
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
					local chat_string = "("..counter..") - "..region_name.." owned by "..owner..".\n"
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
					minetest.chat_send_player(name, chat_string)
					counter = counter + 1	
				else
					minetest.chat_send_player(name, raz.default.wilderness)
				end -- end if regions_id then
			end -- end for regions_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
		end -- end if param == "status" then
	end -- end function(name, param)
})


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
				minetest.chat_send_player(name, "Position 1 missing, use \"/mark_region pos1\" to set.")
			elseif not raz.command_players[name].pos2 then
				minetest.chat_send_player(name, "Position 2 missing, use \"/mark_region pos2\" to set.")
			elseif string.len(region_name) < 1 then
				minetest.chat_send_player(name, "please set a name behind set, use \"/mark_region set <name>\" to set.")
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
					if name == data_table.owner then
						raz:delete_region(id)
					else
						minetest.chat_send_player(name, "You are not the owner of the region with the ID: "..tostring(id).."!")
					end
				end
			else
				minetest.chat_send_player(name, "Region with the ID: "..tostring(id).." unknown!")
			end
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help mark_region\" for more information.")
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
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help mark_region\" for more information.")
		end -- 'end' if param == 
	end -- end func = function(name, param)

})



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
minetest.register_chatcommand("region_special", {
	description = "Some special commands for the region-admin!\n 'region_special show' lists all regions, 'region_special show 3' shows only the region with the id 3, \n'region_special show 3-5' shows all regions from id 3 to id 5.\nThe command 'region_special export' exports the AreaStore() to file, 'region_special import' imports it.\n'region_special convert_areas' conversts from ShadowNinja areas the area.dat file and exports it.\nWith 'region_special import_areas' the exported area.dat file imported.\n'region_special parent 3 +' marks the region id 3 with the parent attribute. 'region_special parent 3 -' removes it.",
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
				err = raz:region_show(name,0,0)
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
			local value = string.split(param:sub(7, -1), " ") --string.trim(param:sub(7, -1))
			if value[1] == nil then
				minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_special\" for more information.")
			elseif value[2] == "+" or value[2] == true then
				err = raz:region_set_attribute(name, value[1], "parent", true) -- _parent(value[1],true)
				raz:msg_handling(err, name) --  message and error handling
			elseif value[2] == "-" or value[2] == false then 
				err = raz:region_set_attribute(name, value[1], "parent", false) -- _parent(value[1],false)
				raz:msg_handling(err, name) --  message and error handling
			end
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_special\" for more information.")
		end -- end if param == 
	end -- end func = function(name, param)
})
	


