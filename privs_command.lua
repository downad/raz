-- Register privilege and chat command.
minetest.register_privilege("region_admin", "Can set, remove and modify all regions.")
minetest.register_privilege("region_lv5", "Can set, remove and effect for own regions.")
minetest.register_privilege("region_lv4", "Can set, remove and allow MvP for own regions.")
minetest.register_privilege("region_lv3", "Can set, remove and allow PvP for own regions.")
minetest.register_privilege("region_lv2", "Can set, remove, protect own regions.")
minetest.register_privilege("region_lv1", "Can set, remove own regions.")


minetest.register_chatcommand("region", {
	description = "Show a list of this regions with all data.",
	params = "<status>",
	--privs = "", -- no spezial parov
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


-- use max size, kontrolliere, dss region nicht mit anderen regionen überlappt, nun eigen regionen in regionen 
minetest.register_chatcommand("region_mark", {
	description = "Mark, set and remove regions.",
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
			local n = tonumber(param:sub(8, -1))
--[[
			if n and pvp_raz_store:get_area(n) then
				pvp_raz_store:remove_area(n)
				if pvp_raz_store:get_area(n + 1) then
					-- Insert last entry in new empty (removed) slot.
					local a = pvp_raz_store:get_area(#pvp_areas - 1)
					pvp_raz_store:remove_area(#pvp_areas - 1)
					pvp_raz_store:insert_area(a.min, a.max, "pvp_areas", n)
				end
				update_pvp_areas()
				save_pvp_areas()
				minetest.chat_send_player(name, "Removed " .. tostring(n))
			else
				minetest.chat_send_player(name, "Invalid argument.  You must enter a valid area identifier.")
			end
]]--
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help mark_region\" for more information.")
--[[		else
			for k, v in pairs(pvp_areas) do
				minetest.chat_send_player(name, k - 1 .. ": " ..
						minetest.pos_to_string(v.min) .. " " ..
						minetest.pos_to_string(v.max))
			end
]]--
		end -- 'end' if param == 
	end -- end func = function(name, param)
})


minetest.register_chatcommand("region_special", {
	description = "some specials for the region-mod",
	params = "<parent> <import> <export>",
	privs = "region_admin",
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		if param == "parent" then
		elseif param == "import" then -- 'end' if param == 
			raz:import()
		elseif param == "export" then -- 'end' if param == 
			raz:export()	
		elseif param ~= "" then -- 'end' if param == 
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help region_special\" for more information.")
		end -- end if param == 
	end -- end func = function(name, param)
})
	


