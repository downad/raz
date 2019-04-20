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

	local data_table = {}
	local owner = ""
	local guests = {}
	local is_protected = false
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

			-- do same checks
			-- e.g. if a garden is protected and parent and in there is an house. 
			-- The house keeper has invited a guest to build with, the invited guest can build 

			-- must thie be ckecked?
			-- if the region is protected (one of the region in an region) then all regions are protected
			if is_protected == true then
				protected = true
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

	-- if one of the region is protected - all are protected 
	-- if the region is not protected everyone can interact 
	if protected == true then
		can_interact = false
	else
		can_interact = true
	end
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
-- player is guest (pos, name)
--
--+++++++++++++++++++++++++++++++++++++++
-- Register punchplayer callback.
--	should return true to prevent the default damage mechanism
-- is hitter a player -> PvP 
--			a mob -> MvP
-- 	return false  - in PvP regions
--  return true   - if PvP is forbidden
--	return false  - in MvP regions from hitter:is_player == false
--  return true   - if MvP is forbidden
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	--local isPlayer = hitter:is_player()
	local pos = player:get_pos() 
	local name = player:get_player_name()
	local hitter_name = hitter:get_player_name()
	local msg = 14 -- "NO PvP in this zone!",
	-- get the PvP and MvP attribute of the region
	-- PvP can be true / false - if region is set
	-- PvP = nil if no region is set - wildernes - the rest off the world
	local PvP, MvP = raz:get_combat_attributs_for_pos(pos)

	-- if the damage-dealer is no player then 
	--  deal damage => MvP = true
	--	deal no damage if MvP = false
	if hitter:is_player() == false then
		if MvP == true then
			return false	-- MOB do Damage
		else
			raz:msg_handling(msg, name) --  message
			return true		-- MOB don't do Damge
		end
	end
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
			return true		-- No PvP no Damge
		end
	end

end)


