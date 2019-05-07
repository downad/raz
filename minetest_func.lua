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
--+++++++++++++++++++++++++++++++++++++++
--
-- register_on_protection_violation - send message
--
--+++++++++++++++++++++++++++++++++++++++
-- Show a message to protection violators
minetest.register_on_protection_violation(function(pos, name)
	-- who can interact?
	-- function can_interact returns true or false
	-- send message to player if that position is protected.
	local can_interact, owner_string = raz:can_interact(pos, name) 
	if not raz:can_interact(pos, name) then
		local pos_string = minetest.pos_to_string(pos)
		minetest.chat_send_player(name, pos_string.." is protected by "..owner_string)
	end
end)
 
--+++++++++++++++++++++++++++++++++++++++
--
-- register_on_protection_violation - do damage
--
--+++++++++++++++++++++++++++++++++++++++
--Damage protection violators
minetest.register_on_protection_violation(function(pos, name)
	local player = minetest.get_player_by_name(name)
	if not player then return end
	if raz.default.do_damage_for_violation then 
		player:set_hp(math.max(player:get_hp() - raz.default.damage_on_protection_violation, 0))
		minetest.chat_send_player(name, "The protection deals you " ..raz.default.damage_on_protection_violation.." damage.")
	else
		minetest.chat_send_player(name, "This block is protected!")
	end
end)


--+++++++++++++++++++++++++++++++++++++++
--
-- override minetest.is_protected(pos, name)
--
--+++++++++++++++++++++++++++++++++++++++
-- the function can_interact returns true or false
-- return true: yes this region is protected
-- return false: no this region is not protecred
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	-- check if pos is in a protected area
	-- and name can interact with the nodes
	if not raz:can_interact(pos, name) then
		return true
	end
	return old_is_protected(pos, name)
end




--+++++++++++++++++++++++++++++++++++++++
--
-- can_interact(pos, name)
--
--+++++++++++++++++++++++++++++++++++++++
-- this function is called by 
--		minetest.is_protected(pos, name)
--		minetest.register_on_protection_violation(function(pos, name)
-- 
-- Checks if the position is unprotected or owned by player/name
-- if an player/name is guest in an region he can interact.
-- return true - if *name* can interact at this *position*
-- return fales if not
function raz:can_interact(pos, name)
	-- no one can interact
	local can_interact = false

	-- the region is not protected
	local protected = false
	-- in the region there is no city-attribute
	local city = false
	-- in the region there is no plot-attribute
	local plot = false

	local data_table = {}
	local owner = ""
	local guests = {}
	local is_protected = false
	local is_city = false
	local is_plot = false
	local owners = {}

	-- loop all regions
	local counter = 0
	for regions_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
		if regions_id then
			counter = counter + 1
			-- get region_data as table
			data_table = raz:get_region_datatable(regions_id)
			owner = data_table.owner
			guests = data_table.guests --<- this is a string!
			is_protected = data_table.protected
			is_city = data_table.city
			is_plot = data_table.plot

			--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - region_id = "..tostring(regions_id) )
			--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - is_protected = "..tostring(is_protected) )
			--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - is_city = "..tostring(is_city) )
			--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - is_plot = "..tostring(is_plot) )

			-- must this be ckecked?
			-- if the region is protected (one of the region in an region) then all regions are protected
			if is_protected == true then
				protected = true
			end
			if is_city == true then
				city = true
			end
			if is_plot == true then
				plot = true
			end
			-- create a table of all owners
			-- insert(owners, owner) in table - if the owner is unknown to the table 	
			if raz:string_in_table(owner, owners) == false then
				table.insert(owners, owner)	
			end	

			-- if name == owner and is_protected == true 
			-- if the player/name is owner of the region he can interact.
			if name == owner then -- and is_protected == true then
				can_interact = true
				return can_interact
			end
			-- if the player/name is guest he can interact
			if raz:player_is_guest(name, guests) then --and is_protected == true then
				can_interact = true
				return can_interact
			end	
		end -- if regions_id then
	end -- for regions_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do 

	--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - counter = "..tostring(counter) )
	--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - protected = "..tostring(protected) )
	--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - city = "..tostring(city) )
	--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - plot = "..tostring(plot) )
	
	-- no region ID - no counter - no protection
	if counter == 0 then
		can_interact = true
		return can_interact		
	end
	-- if one of the region is protected - all are protected 
	-- if the region is not protected everyone can interact 
	-- if there is only 1 regtion than protected means protected
	if counter == 1 then
		if protected == true then
			can_interact = false
		else
			can_interact = true
		end
	elseif counter == 2 then
		-- more than 2 regions
		-- has one region the city attribute 
		-- has one region the (building) plot-attibute 
		if city == true and plot == true then
			can_interact = true
		else
			can_interact = false
		end
	else
		can_interact = false
	end
	--minetest.log("action", "[" .. raz.modname .. "] raz:can_interact(pos, name) - return = "..tostring(can_interact) )
	return can_interact, raz:table_to_string(owners)
		
end

--+++++++++++++++++++++++++++++++++++++++
--
-- player is guest (pos, name)
--
--+++++++++++++++++++++++++++++++++++++++
-- this function is called by 
--		can_interact(pos, name)
-- check if name is in the string guests
-- return true if the name is
-- return false if not
function raz:player_is_guest(name,guests_string)
	-- convert guest_sting in guest_table
	--local guests_table = string.split(guests_string, ",")
	local guests_table = raz:convert_string_to_table(guests_string, ",")
	local is_guest = raz:string_in_table(name, guests_table)
	return is_guest
end





--+++++++++++++++++++++++++++++++++++++++
--
-- Register punchplayer callback.
--
--+++++++++++++++++++++++++++++++++++++++
-- punchplayer callback
-- should return true to prevent the default damage mechanism
-- is hitter a player -> PvP 
-- 	return false  - (do damage) in PvP regions			
--  return true   - (no damage) if PvP is forbidden
-- 	if no region is set: 
-- 	return true	  - (do damage) if pvp_only_in_pvp_regions = false
-- 	return true	  - (no damage) if pvp_only_in_pvp_regions = true
--
-- is hitter a mob -> MvP
--	return false  - (do damage) if MvP is set true in a region
--  return false  - (do damage) if no region is set -> MvP == nil
--  return true   - (no damage) if MvP is set false (forbidden) in an region
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	local pos = player:get_pos() 
	local name = player:get_player_name()
	local hitter_name = hitter:get_player_name()
	local msg = 35 --  "Mob do no damage in this zone!",
	-- get the PvP and MvP attribute of the region
	-- PvP can be true / false - if region is set
	-- PvP = nil if no region is set - wildernes - the rest off the world
	local PvP, MvP = raz:get_combat_attributs_for_pos(pos)

	-- if the damage-dealer is no player then 
	--  deal damage => MvP = true or in wilderness MvP = nil
	--	deal no damage if MvP = false
	if hitter:is_player() == false then
		if MvP == true or MvP == nil then
			return false	-- MOB do Damage
		else
			raz:msg_handling(msg, name) --  message
			return true		-- MOB don't do Damge
		end
	end

	msg = 14 -- "NO PvP in this zone!",
	-- if pvp_only_in_pvp_regions == true
	-- PvP only in PvP regions!
	if raz.pvp_only_in_pvp_regions == true then
		if PvP == true then
			return false	-- Player do Damage
		else
			raz:msg_handling(msg, name) --  message
			raz:msg_handling(msg, hitter_name) --  message
			return true		-- No PvP no Damge
		end
	else
		-- all in the world is PvP allowed
		if PvP == true or PvP == nil then  
			return false	-- Player do Damage
		else
			raz:msg_handling(msg, name) --  message
			raz:msg_handling(msg, hitter_name) --  message
			return true		-- No MPvP no Damge
		end
	end

end)



--+++++++++++++++++++++++++++++++++++++++
--
-- Register register_on_punchnode callback.
--
--+++++++++++++++++++++++++++++++++++++++
-- punchnode callback
-- is user for the command '/region mark'
-- to punch a node an set pos1 and pos2 of an region
-- if pos1 and pos2 are set 
-- raz.set_command[name] = nil clears the function
minetest.register_on_punchnode(function(pos, node, puncher)
	local name = puncher:get_player_name()
	-- Currently setting position
	if name ~= "" and raz.set_command[name] then
		if raz.set_command[name] == "pos1" then
			if not raz.command_players[name] then
				raz.command_players[name] = {pos1 = pos}
			else
				raz.command_players[name].pos1 = pos
			end
			-- set marker pos1
			raz.markPos1(name)
			-- be ready for pos2
			raz.set_command[name] = "pos2"
			minetest.chat_send_player(name,
					"Position 1 set to "
					..minetest.pos_to_string(pos))
		elseif raz.set_command[name] == "pos2" then
			if not raz.command_players[name] then
				raz.command_players[name] = {pos2 = pos}
			else
				raz.command_players[name].pos2 = pos
			end
			-- set marker pos2
			raz.markPos2(name)
			-- clear set_command
			raz.set_command[name] = nil
			minetest.chat_send_player(name,
					"Position 2 set to "
					..minetest.pos_to_string(pos))
		end
	end
end)



