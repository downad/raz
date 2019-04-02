-- Show a message to protection violators
minetest.register_on_protection_violation(function(pos, name)
	-- only owners can interact
	if not raz:can_interact(pos, name) then
		local pos_string = minetest.pos_to_string(pos)
		local owners = raz:get_node_owners(pos)
		local owner_string = ""
		for k,v in pairs(owners) do
			owner_string = owner_string..v..","
		end
		minetest.chat_send_player(name, pos_string.." is protected by "..owner_string)
	end
end)
 
--Damage protection violators
minetest.register_on_protection_violation(function(pos, name)
	local player = minetest.get_player_by_name(name)
	if not player then return end
	player:set_hp(math.max(player:get_hp() - raz.default.damage_on_protection_violation, 0))
	minetest.chat_send_player(name, "This area is protected! -"..raz.default.damage_on_protection_violation.." HP")
end)


-- Returns a table (list) of all players that own an area
function raz:get_node_owners(pos)
	local owners = {}
	--local pos_has_regions = false
		-- loop all regions
		for regions_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
			if regions_id then
				-- get area_data as table
				local data_table = raz:get_region_datatable(regions_id)
				local owner = data_table.owner
				--table.insert(owners, owner)	
				if raz:check_name_in_table(owner, owners) == false then
					minetest.log("action", "[" .. raz.modname .. "] raz:check_name_in_table(owner, owners) == false" )
					table.insert(owners, owner)	
				else
					minetest.log("action", "[" .. raz.modname .. "] raz:check_name_in_table(owner, owners) == true" )
		
				end	
			end
		end
	return owners
end

-- Return true if the region is protected
-- false if name == owner of protected region
-- false if name is guest of protected region
function raz:protected_for_name(pos, name)
	local owners = {}
	-- the region is not protected
	local protected = false

	-- loop all regions
	for regions_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
		if regions_id then
			-- get area_data as table
			local data_table = raz:get_region_datatable(regions_id)
			local owner = data_table.owner
			local is_protected = data_table.protected
			local guests = data_table.guests

			-- if the region is protected (one of the region in an region) then the hole region is protected
			if is_protected == true then
				protected = true
			end

			-- if name == owner and set the protected 
			if name == owner and is_protected == true then
				return false
			end
			if raz:name_is_guest(name, guests) and is_protected == true then
				return false
			end

		end
	end
	return protected
end

-- is this region protected
-- the function can_interact must return true or false
-- return true: yes this region is protected
-- return false: no this region is not protecred
-- the function is_guest must return true
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	-- check if pos is in a protected area
	-- and name can interact with the nodes
	if not raz:can_interact(pos, name) then
		return true
	end
	return old_is_protected(pos, name)
end


-- Checks if the position is unprotected or owned by you
-- return true - if *name* can interact at this *position*
function raz:can_interact(pos, name)
	local owners = raz:get_node_owners(pos)
	-- no one can interact
	local can_interact = false

	-- the owners-table is empty
	-- this means no owner, 
	-- can_interact = true
	if type(next(owners)) == "nil" then
		can_interact = true
		minetest.log("action", "[" .. raz.modname .. "] type(next(owners)): "..tostring(can_interact))
	end

	-- the name is in the table of owners
	-- can_interact = true
	if raz:check_name_in_table(name, owners) then
		can_interact = true
		minetest.log("action", "[" .. raz.modname .. "] raz:check_name_in_table(name, owners): "..tostring(can_interact))	
	end

	-- multi area, area in an area if protected by name - name is enought
	-- in protected by an othe owner the area is protected
	-- check status protected - can_interact = false
	-- if name = protected-owner can_interact = true

	-- has the area the protected flag
	-- can_interact = true
	if not raz:protected_for_name(pos, name) then
		can_interact = true
		minetest.log("action", "[" .. raz.modname .. "] raz:protected_for_name(pos, name): "..tostring(can_interact))
	end

	minetest.log("action", "[" .. raz.modname .. "] can_interact: "..tostring(can_interact))

	return can_interact	
end


-- check if name is in the string guests
-- return true if the name is
-- return false if not
function raz:name_is_guest(name,guests_string)
	local guests = string.split(guests_string, ",")
	for k,v in ipairs(guests) do
		minetest.log("action", "[" .. raz.modname .. "] name_is_guest: k: "..tostring(k).." v: "..tostring(v))
	end
	local is_guest = raz:check_name_in_table(name, guests)
	return is_guest
end





-- check if a name is in an table
-- return true if the name is in the table
-- return false if not
function raz:check_name_in_table(name, table)
  for i,v in ipairs(table) do

    if v == name then
      return true
    end

  end
  return false
end
