--#---------------------------------------
--
-- load, save, insert, delete and update in AreaStore()
--
--#---------------------------------------
--
--
--+++++++++++++++++++++++++++++++++++++++
--
-- load the AreaStore() from file
--
--+++++++++++++++++++++++++++++++++++++++
-- input: nothing
-- msg/error handling: no
-- return 0 = no error
function raz:load_regions_from_file()
--	minetest.log("action", "[" .. raz.modname .. "] raz:load_regions_from_file()")
	raz.raz_store:from_file(raz.worlddir .."/".. raz.store_file_name) 
	-- No Error
	return 0 
end

--+++++++++++++++++++++++++++++++++++++++
--
-- save AreaStore() to file
--
--+++++++++++++++++++++++++++++++++++++++
-- input: nothing
-- msg/error handling: 
-- return 0 = no error
function raz:save_regions_to_file()
--	minetest.log("action", "[" .. raz.modname .. "] raz:save_regions_to_file()")	
	raz.raz_store:to_file(raz.worlddir .."/".. raz.store_file_name) 
	-- No Error
	return 0 
end

-----------------------------------------
--
-- insert region in AreaStore()
--
-----------------------------------------
-- insert a new region, update AreaStore, save AreaStore
-- pos1 and pos2 must be an vector
-- data must be an designed string like
-- because in the datafield could only stored a string
-- data = "return {[\"owner\"] = \"adownad\", [\"protected\"] = true, [\"PvP\"] = false, [\"MvP\"] = true, [\"effect\"] = \"none\", [\"region_name\"] = \"Meine Wiese mit Haus\"}"
-- msg/error handling: 
-- return id of new region
function raz:set_region(pos1,pos2,data)
	--minetest.log("action", "[" .. raz.modname .. "] raz:set_region(pos1,pos2,data)")	
	if type(data) ~= "string" then
		data = minetest.serialize(data)
	end
	local id = raz.raz_store:insert_area(pos1, pos2, data)
	raz.save_regions_to_file()
	return id
end

-----------------------------------------
--
-- delete region from AreaStore()
--
-----------------------------------------
-- delete id form AreaStore()
-- the get_areas return a pointer, so re-copie the areastore and 'forget' to copie the region with the id
-- check if id ~=0
-- msg/error handling:
-- return 0 - no error
-- return 1 -- "No region with this ID! func: raz:delete_region(id)", 
function raz:delete_region(id)
	minetest.log("action", "[" .. raz.modname .. "] raz:delete_region(id) ID: "..tostring(id)) 
	if raz.raz_store:get_area(id) == nil then
		-- Error
		return 1 -- "No region with this ID! func: raz:delete_region(id)",
	end 

	local counter = 0
	local temp_store = AreaStore() 
	local region_values = {}

	-- copy all regions to temp_store
	while raz.raz_store:get_area(counter) do
		if counter ~=id then
			-- no errorcheck - get_area / insert_area are build in
			region_values = raz.raz_store:get_area(counter,true,true)
			temp_store:insert_area(region_values.min, region_values.max, region_values.data)
		else
			-- no errorcheck - remove_area is build in
			raz.raz_store:remove_area(id)
		end
		counter = counter + 1
	end

	-- recreate raz.raz_store
	raz.raz_store = AreaStore()
	region_values = {}

	-- copy all value back
	counter = 0
	while temp_store:get_area(counter) do
			-- no errorcheck - get_area / insert_area are build in
			region_values = temp_store:get_area(counter,true,true)
			raz:set_region(region_values.min, region_values.max, region_values.data)
		counter = counter + 1
	end
	-- No Error
	return 0 
end

-----------------------------------------
--
-- update datafield  AreaStore()
--
-----------------------------------------
-- 
-- id, the ID to change
-- pos1, pos2 and data are the values to insert
-- msg/error handling:
-- return true 
function raz:update_regions_data(id,pos1,pos2,data_table)
	-- minetest.log("action", "[" .. raz.modname .. "] raz:update_regions_data(id,pos1,pos2,data) ID: "..tostring(id)) 
	local data_string = minetest.serialize(data_table)

	local counter = 0

	-- create an temporary AreaStore()
	local temp_store = AreaStore() 
	local region_values = {}

	-- copy all regions to temp_store
	while raz.raz_store:get_area(counter) do
		--minetest.log("action", "[" .. raz.modname .. "] 1. while - counter = "..tostring(counter)) 
		if counter ~=tonumber(id) then
			region_values = raz.raz_store:get_area(counter,true,true)
			temp_store:insert_area(region_values.min, region_values.max, region_values.data)
		else
			temp_store:insert_area(pos1, pos2, data_string)
		end
		
		counter = counter + 1
	end

	-- recreate raz.raz_store
	raz.raz_store = AreaStore()
	counter = 0

	-- copy all regions from temp_store to raz.raz_store
	while temp_store:get_area(counter) do
		region_values = temp_store:get_area(counter,true,true)
		raz.raz_store:insert_area(region_values.min, region_values.max, region_values.data)
		counter = counter + 1
	end
	temp_store = {}

	-- save changes
	raz:save_regions_to_file()

	return true
end


--#---------------------------------------
--
-- the functions for string and table manipulation 
--
--#---------------------------------------
--
--
--+++++++++++++++++++++++++++++++++++++++
--
-- convert a table to a list of strings, there is no key!
--
--+++++++++++++++++++++++++++++++++++++++
-- input: given_table
-- msg/error handling: no
-- return string as string
function raz:table_to_string(given_table)
	--minetest.log("action", "[" .. raz.modname .. "] raz:table_to_string(table)")
	local string = ""
	for k, v in pairs(given_table) do
		if k then
			string = string..v..","
		end
	end
	return string
end

--+++++++++++++++++++++++++++++++++++++++
--
-- check if a string is in an table
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		name as string
--		given_table as table
-- msg/error handling: no
-- return true if the name is in the table
-- return false if not
function raz:check_name_in_table(name, given_table)
  for i,v in ipairs(given_table) do

    if v == name then
      return true
    end

  end
  return false
end

--+++++++++++++++++++++++++++++++++++++++
--
-- remove a value from table
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		value as string
--		given_table as table
-- msg/error handling: no
-- return table with the removed element
function raz:remove_value_from_table(value, given_table)
	local return_table = {}
	for k, v in ipairs(given_table) do
		if k then
		    if v ~= value then
				table.insert(return_table, v)
		    end
		end
	end
	return return_table
end

--+++++++++++++++++++++++++++++++++++++++
--
-- split string into a table, default seperator is ","
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		string as string
--		seperator as string {default: seperator = ","}
-- msg/error handling: no
-- return value_tables with the elements
function raz:convert_string_to_table(string, seperator)
	if seperator == nil then
		seperator = ","
	end
	local value_table = {}

	value_table = string.split(string,seperator)

	return value_table
end








--+++++++++++++++++++++++++++++++++++++++
--
-- get area by pos1 and pos2
--
--+++++++++++++++++++++++++++++++++++++++
-- input: pos1, pos2 as vector (table) 
-- returns the first area found
-- msg/error handling: no
-- return nil 	if the is no area
-- return id of the first found area
function raz:get_area_by_pos1_pos2(pos1, pos2)
	local found = raz.raz_store:get_areas_in_area(pos1,pos2,true,true) --accept_overlap, include_borders, include_data):
	for region_id,v in pairs(found) do
		if region_id then
			return region_id -- id of the first found area
		end
	end
	return nil
end


--+++++++++++++++++++++++++++++++++++++++
--
-- check if the player can_add a region!
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		name			as string (playername)
--		region_name 	as string
-- msg/error handling: no
-- returns true - no error
-- return 22 -- "msg: Your region is too small (x)!",
-- return 23 -- "msg: Your region is too small (z)!",
-- return 24 -- "msg: Your region is too small (y)!",
-- return 25 -- "msg: Your region is too width (x)!",
-- return 26 -- "msg: Your region is too width (z)!",
-- return 27 -- "msg: Your region is too hight (y)!",
-- retunr 28 -- "msg: There are other region in. You can not mark this region",
function raz:player_can_mark_region(edge1, edge2, name)
	local can_add = true
	-- check if player is region_admin
	-- if yes, he can place everythere, return true
	if minetest.check_player_privs(name, { region_admin = true }) then 
		return true
	end
	minetest.log("action", "[" .. raz.modname .. "] raz:player_can_mark_region your are no region_admin!" )
	--local edge1 = raz.command_players[name].pos1
	--local edge2 = raz.command_players[name].pos2
	-- check minimum
	if math.abs(edge1.x - edge2.x) < raz.minimum_width then 
		return 22 -- "msg: Your region is too small (x)!",
	end
	if math.abs(edge1.z - edge2.z) < raz.minimum_width then 
		return 23 -- "msg: Your region is too small (z)!",
	end
	if math.abs(edge1.y - edge2.y) < raz.minimum_hight then 
		return 24 -- "msg: Your region is too small (y)!",
	end
	minetest.log("action", "[" .. raz.modname .. "] raz:player_can_mark_region minimum checked!" )
	-- check maximum
	if math.abs(edge1.x - edge2.x) >= raz.maximum_width then 
		return 25 -- "msg: Your region is too width (x)!",
	end
	if math.abs(edge1.z - edge2.z) >= raz.maximum_width then 
		return 26 -- "msg: Your region is too width (z)!",
	end
	if math.abs(edge1.y - edge2.y) >= raz.maximum_hight then 
		minetest.log("action", "[" .. raz.modname .. "] raz:player_can_mark_region z1 - z2 = "..tostring(math.abs(edge1.y - edge2.y)) )
		return 27 -- "msg: Your region is too hight (y)!",
	end	
	minetest.log("action", "[" .. raz.modname .. "] raz:player_can_mark_region maximum checked!" )
	
	-- is there a region in without parent-attribute?
	local found = raz.raz_store:get_areas_in_area(edge1,edge2,true,true) --accept_overlap, include_borders):
	minetest.log("action", "[" .. raz.modname .. "] raz:player_can_mark_region found regions: "..tostring(#found) )

	local is_parent = false
	for found_id,v in pairs(found) do
		if found_id then
			is_parent = raz:get_region_attribute(found_id, "parent")
			minetest.log("action", "[" .. raz.modname .. "] raz:player_can_mark_region region ID="..tostring(found_id).." is parent: "..tostring(is_parent) )

			if is_parent ~= true then
				can_add = 28 -- "msg: There are other region in. You can not mark this region",
			end
		end
	end
	return can_add	
end



--#---------------------------------------
--
-- the functions AreaStore() data field 
--
--#---------------------------------------
--
--
-----------------------------------------
--
-- create the designed data string for the AreaStore()
--
-----------------------------------------
-- create the designed data string for the AreaStore()
-- data must be an designed string like
-- because in the datafield could only stored a string
-- data = "return {[\"owner\"] = \"playername\", [\"region_name\"] = \"Meine Wiese mit Haus\" , [\"protected\"] = true, 
--			[\"guests\"] = \"none/table\", [\"PvP\"] = false, [\"MvP\"] = true, [\"effect\"] = \"none\"}"
-- owner and region_name are MUST
-- if the rest is missing default will set.
-- the flag -do_not_check_player = true allows to create regions for owners who are not player - maybe because you will convert an areas.dat for an other system.
-- msg/error handling:
-- return data_string for insert_area(edge1, edge2, DATA) as string
function raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,parent,do_not_check_player)
	minetest.log("action", "[" .. raz.modname .. "] raz:create_data(...)"	)
	-- check input-values
	local player = minetest.get_player_by_name(owner)
	if not player and do_not_check_player ~= true then
		owner = minetest.setting_get("name")
	end
	if not type(region_name) == "string" then
		return 1 -- there is an error
	end
	if not type(protected) == "boolean" or protected == nil then
		protected = raz.default.protected
	end
	if not type(guests_string) == "string" or guests_string == nil then
		guests_string = raz.default.guests
	end
	if not type(PvP) == "boolean" or PvP == nil then
		PvP = raz.default.PvP
	end
	if not type(MvP) == "boolean" or MvP == nil then
		MvP = raz.default.MvP
	end
	if not type(effect) == "string" or effect == nil then
		effect = raz.default.effect
	end
	if not type(parent) == "boolean" or parent == nil then
		parent = raz.default.parent
	end
	-- only for debugging
	if raz.debug == true then
		minetest.log("action", "[" .. raz.modname .. "] ***********************************************")
		minetest.log("action", "[" .. raz.modname .. "] region_name: "..tostring(region_name))
		minetest.log("action", "[" .. raz.modname .. "] owner: "..tostring(owner))
		minetest.log("action", "[" .. raz.modname .. "] protected: "..tostring(protected))
		minetest.log("action", "[" .. raz.modname .. "] guests: "..tostring(guests_string))
		minetest.log("action", "[" .. raz.modname .. "] PvP: "..tostring(PvP))
		minetest.log("action", "[" .. raz.modname .. "] MvP: "..tostring(MvP))
		minetest.log("action", "[" .. raz.modname .. "] effect: "..tostring(effect))
	end
	-- create the datastring
	local data_string = "return {[\"owner\"] = \""..owner.."\", [\"region_name\"] = \""..region_name.."\", [\"protected\"] = "..tostring(protected)..
		", [\"guests\"] = \""..guests_string.."\", [\"PvP\"] = "..tostring(PvP)..", [\"MvP\"] = "..tostring(MvP)..
		", [\"effect\"] = \""..effect.."\", [\"parent\"] = "..tostring(parent).."}" 
 
	return data_string
end

--+++++++++++++++++++++++++++++++++++++++
--
-- get pos1, pos2 and data of an region 
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		id 
--		no_deserialize as boolean {default: no_deserialize = nil}
--						no_deserialize = true then return data as string!
--						no_deserialize ~= true then return data as table!
-- msg/error handling:
-- return pos1,pos2 and data (as 3 tables)
-- return 3 - no region with this ID
function raz:get_region_data_by_id(id,no_deserialize)
	--minetest.log("action", "[" .. raz.modname .. "] raz:get_region_data_by_id(id) ID: "..tostring(id).." raz.raz_store:get_area(id) = "..tostring(raz.raz_store:get_area(id) )) 
	local region_values = ""
	local pos1 = ""
	local pos2 = ""
	local data --= {}
	if raz.raz_store:get_area(id) then 
		region_values = raz.raz_store:get_area(id,true,true)
		pos1 = region_values.min
		pos2 = region_values.max
		if no_deserialize ~= true then
			data = minetest.deserialize(region_values.data)
		else
			data = region_values.data
		end
		return pos1,pos2,data
	end
	-- Error
	return 3 -- [3] = "No region with this ID!"
end

--+++++++++++++++++++++++++++++++++++++++
--
-- get the data-field of a regions 
--
--+++++++++++++++++++++++++++++++++++++++
-- input: id
-- get the data field of a given region 
-- msg/error handling: no 
-- return data as table
function raz:get_region_datatable(id)
	--	no_deserialize == false
	local pos1,pos2,data = raz:get_region_data_by_id(id,false)
	return data
end

--+++++++++++++++++++++++++++++++++++++++
--
-- get_data_string_by_id 
--
--+++++++++++++++++++++++++++++++++++++++
-- input: id
-- get the data field of a given region
-- and compose a string 
-- msg/error handling: 
-- return data_string
-- return 29 -- "ERROR: No region with this ID! func: raz:get_region_datatable(id)",
function raz:get_data_string_by_id(id)
	--local pos1 = ""
	--local pos2 = ""
	--local data = ""
	--local data_string = ""
	-- check ID
	local region_values = raz.raz_store:get_area(id,true,true)
	if region_values ~= nil then
		local pos1 = "["..region_values.min.x..","..region_values.min.y..","..region_values.min.z.."]"
		local pos2 = "["..region_values.max.x..","..region_values.max.y..","..region_values.max.z.."]"
		local data = minetest.deserialize(region_values.data)
		local data_string = "\nID "..id..": "..data.region_name.." owned by "..data.owner.." \n( "..pos1.." / "..pos2.." )"
		if data.protected then
			data_string = data_string..", is protected"
		end
		if data.guests ~= (nil or ",") then 
			data_string = data_string..", Guests: "..data.guests
		end
		if data.PvP then
			data_string = data_string..", PvP enable"
		end
		if data.MvP == false then
			data_string = data_string..", Mobs do no damage"
		end
		if data.effect ~="none" then
			data_string = data_string..", effects: " ..tostring(data.effect)
		end
		if data.parent then
			data_string = data_string..", is parent"
		end
		return data_string
	end
	return 29 -- "ERROR: No region with this ID! func: raz:get_region_datatable(id)",
end

--+++++++++++++++++++++++++++++++++++++++
--
-- get one attribute from data-field of a regions 
--
--+++++++++++++++++++++++++++++++++++++++
-- input: id
-- get the data field of a given region 
-- and returns the value from one attribute 
-- msg/error handling: no 
-- return return_value
function raz:get_region_attribute(id, region_attribute)
	local data = raz:get_region_datatable(id)

	-- check if the attribute is allowed
	if not raz:check_name_in_table(region_attribute, raz.region_attribute) then
		return 8 -- "msg: The region_attribute did not fit!",
	end
    local return_value = ""

	if 	region_attribute == "protect" then
		return_value = data.protected 
	elseif 	region_attribute == "region_name" then
		return_value = data.region_name
	elseif 	region_attribute == "owner" then
		return_value = data.owner
	elseif 	region_attribute == "guest" then
		return_value = data.guests
	elseif 	region_attribute == "PvP" then
		return_value = data.PvP
	elseif 	region_attribute == "MvP" then
		return_value = data.MvP
	elseif 	region_attribute == "parent" then
		return_value = data.parent
	elseif 	region_attribute == "effect" then
		return_value = data.effect
	end 

	return return_value
end

--+++++++++++++++++++++++++++++++++++++++
--
-- get_combat_attributs_for_pos(pos)
--
--+++++++++++++++++++++++++++++++++++++++
-- input: pos
-- get the data field attributes PvP and MvP of a given posision 
-- msg/error handling: no 
-- return PvP, MvP as boolean or nil
function raz:get_combat_attributs_for_pos(pos)
	local PvP = nil
	local MvP = nil
	local data_table = {}
	-- get all region for this position
	for id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
		if id then
			data_table = raz:get_region_datatable(id)

			-- pvp_only_in_pvp_regions = true
			-- if there are more regions at the same position PvP = true in all
			-- pvp_only_in_pvp_regions = false
			-- if there are more regions at the same position PvP = false in all
			if raz.pvp_only_in_pvp_regions == true then
				if PvP == nil or PvP == false then
					PvP = data_table.PvP
				end
			else
				if PvP == nil or PvP == true then
					PvP = data_table.PvP
				end
			end

			-- pvp_only_in_pvp_regions = false
			-- if there are more regions at the same position PvP = false in all
			-- true an nil can be changed
			if MvP == nil or MvP == true then
				MvP = data_table.MvP
			end
		end
	end
	return PvP,MvP
end

-- function region_set_attribute(name, id, region_attribute, value, bool)
-- the default bool is 'nil' - this bool is used to add or remove guests 
-- this function checks id, region_attribut and value = bool or value = string (effects - hot, bot, holy, dot, choke, evil)
-- msg/error handling:
-- return info: text -- no error
-- return 2 -- "ERROR: No region with this ID! func: raz:region_set_attribute(name, id, region_attribute, value),
-- return 8 -- "ERROR: The region_attribute dit not fit! func: raz:region_set_attribute(name, id, region_attribute, value)",
-- return 9 -- "ERROR: There is no Player with this name! func: raz:region_set_attribute(name, id, region_attribute, value)",
-- return 10 -- "ERROR: Wrong effect! func: raz:region_set_attribute(name, id, region_attribute, value)",
-- return 11 -- "ERROR: You are not the owner of this region! func: raz:region_set_attribute(name, id, region_attribute, value)",
-- return 12 -- "ERROR: No Player with this name is in the guestlist! func: raz:region_set_attribute(name, id, region_attribute, value)",
function raz:region_set_attribute(name, id, region_attribute, value, bool)
	local region_values = ""
	local pos1 = ""
	local pos2 = ""
	local data = {}
	-- return message
	local err_msg = "info: Region with ID: "..id.." modified attribute "..tostring(region_attribute).." with value "..tostring(value)
	
	-- ckeck is this ID in AreaStore()?
	if raz.raz_store:get_area(id) then
		-- get region values 
		pos1,pos2,data = raz:get_region_data_by_id(id)
		-- check if player is owner of the regions
		if name ~= data.owner then
			if not minetest.check_player_privs(name, { region_admin = true }) then
				return 11 -- "ERROR: You are not the owner of this region! func: raz:region_set_attribute(name, id, region_attribute, value)",
			end
		end
		-- check if the attribute is allowed
		if not raz:check_name_in_table(region_attribute, raz.region_attribute) then
			return 8 -- "ERROR: The region_attribute dit not fit! func: raz:region_set_attribute(name, id, region_attribute, value)",
		end
		-- modify the attribute
		if 	region_attribute == "protect" then
			if type(value) == "boolean" then 
				data.protected = value 
			end 
		elseif 	region_attribute == "region_name" then
			if type(value) == "string" then 
				data.region_name = value
			end 
		elseif 	region_attribute == "owner" then
			if type(value) == "string" then 
				-- check player"
				if not minetest.player_exists(value) then --player then
					return 9 -- "ERROR: There is no Player with this name! func: raz:region_set_attribute(name, id, region_attribute, value)",
				end			
				data.owner = value
			end 
		elseif 	region_attribute == "guest" and bool == true then
			if type(value) == "string" then 
				-- check player"
				--local player = minetest.get_player_by_name(value)
				if not minetest.player_exists(value) then --player then
					return 9 -- "ERROR: There is no Player with this name! func: raz:region_set_attribute(name, id, region_attribute, value)",
				end			
				if data.guests == "," or data.guests == nil then
					data.guests = value
				else
					--check	if guest/value is in string guests
					local given_table = raz:convert_string_to_table(data.guests, ",")
					if not raz:check_name_in_table(value, given_table) then
						data.guests = data.guests..","..value 
					else
						return 15
					end
				end
				err_msg = err_msg.." guest added. "
			end 
		elseif 	region_attribute == "guest" and bool == false then
			if type(value) == "string" then 
				-- check guests
				local guests = raz:convert_string_to_table(data.guests, ",")
				if not raz:check_name_in_table(value, guests) then
					return 12 -- "ERROR: No Player with this name is in the guestlist! func: raz:region_set_attribute(name, id, region_attribute, value)",
				end
				-- remove value from guests
				guests = raz:remove_value_from_table(value, guests)
				-- data.guests must be an STRING!
				local new_guest_string = raz:table_to_string(guests)
				data.guests = new_guest_string
				err_msg = err_msg.." guest banned. "

			end 
		elseif 	region_attribute == "PvP" then
			if type(value) == "boolean" then 
				data.PvP = value 
			end 
		elseif 	region_attribute == "MvP" then
			if type(value) == "boolean" then 
				data.MvP = value 
			end 
		elseif 	region_attribute == "parent" then
			if type(value) == "boolean" then 
				data.parent = value 
			end 
		elseif 	region_attribute == "effect" then
			if type(value) == "string" then 
				-- check effects"
				if not raz:check_name_in_table(value, raz.region_attribute) then
					return 10 -- "ERROR: Wrong effect! func: raz:region_set_attribute(name, id, region_attribute, value)",
				end 
				data.effect = value 
			end 

		end
		-- update_regions_data(id,pos1,pos2,data)
		if not raz:update_regions_data(id,pos1,pos2,data) then
			return 7 -- "ERROR: in update_regions_data! func: raz:region_set_attribute(id, region_attribute, bool)", 
		end
		return err_msg
	else
		-- Error
		return 2 -- [2] = "No region with this ID!"
	end
end

--#---------------------------------------
--
-- the functions for import and export
--
--#---------------------------------------
--
--
--+++++++++++++++++++++++++++++++++++++++
--
-- file exist?
--
--+++++++++++++++++++++++++++++++++++++++
-- input: file
-- msg/error handling: no
-- return f
function raz:file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

--+++++++++++++++++++++++++++++++++++++++
--
-- get all lines from a file
--
--+++++++++++++++++++++++++++++++++++++++
-- input: file
-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
-- msg/error handling: no
-- return {} if file does not exist
-- return lines as table
function raz:lines_from(file)
	if not file_exists(file) then return {} end
	local lines = {}
	for line in io.lines(file) do 
	lines[#lines + 1] = line
	end
	return lines
end

 

--#---------------------------------------
--
-- Error handling
--
--#---------------------------------------
--
--
--+++++++++++++++++++++++++++++++++++++++
--
-- handle errors and messages
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		err as number or string
--		err 0 -> no error, no output
--		name as string {default: name = nil}
-- this function handles messages and errors
-- if name ~= nil check name and chat_send msg to name
-- if err == "", nil or 0 -> no Error: nothing happens
-- else minetest.log("error",
-- the raz.error_text[err] is defined in init.
-- msg/error handling:
-- return NOTHING - everything is ok
function raz:msg_handling(err, name)
	if err == "" or err == nil or err == 0 then
		return 
	end
	--minetest.log("action", "[" .. raz.modname .. "] ##########################################################")
	--minetest.log("action", "[" .. raz.modname .. "] msg_handling -err: " .. tostring(err))
	--minetest.log("action", "[" .. raz.modname .. "] type(err): " .. type(err))
	--minetest.log("action", "[" .. raz.modname .. "] name: " .. tostring(name))
	
	if type(err) == "string" then
		-- is err an info
		if err:sub(1, 5) == "info:" then
			minetest.log("action", "[" .. raz.modname .. "]".. err:sub(6, -1))	
		else 
			minetest.log("error", "[" .. raz.modname .. "] Error: ".. err)	
		end
	elseif type(err) == "number" then
		minetest.log("error", "[" .. raz.modname .. "] Error: ".. raz.error_text[err])	
	end
	if name == nil then 
		return
	end
	-- if name exists send chat
	if minetest.player_exists(name) then 
		if type(err) == "number" then
			minetest.chat_send_player(name, raz.error_text[err])
		else
			minetest.chat_send_player(name, err)
		end
	end
end



-- print a List of all regions to the minetest.log
-- for debug only
function raz:print_regions()
	if raz.debug == false then
		return
	end
	minetest.log("action", "[" .. raz.modname .. "] raz:print_regions")

	raz.regions = {}
	local counter = 0
	local region_values = ""
	local pos1 = ""
	local pos2 = ""
	local data = ""
	minetest.log("action", "[" .. raz.modname .. "] Print list of stored regions.")
	while raz.raz_store:get_area(counter) do
		region_values = raz.raz_store:get_area(counter,true,true)
		pos1 = region_values.min
		pos2 = region_values.max
		data = region_values.data

		minetest.log("action", "[" .. raz.modname .. "] ------------------")
		minetest.log("action", "[" .. raz.modname .. "] region (" .. counter .. ") ")
		minetest.log("action", "[" .. raz.modname .. "] pos1 (x,y,z) "..tostring(pos1["x"])..",".. tostring(pos1["y"])..","..tostring(pos1["z"]))
		minetest.log("action", "[" .. raz.modname .. "] pos2 (x,y,z) "..tostring(pos2["x"])..",".. tostring(pos2["y"])..","..tostring(pos2["z"]))
		minetest.log("action", "[" .. raz.modname .. "] data ".. tostring(data))

		counter = counter + 1
	end
end

-- a debug function for region_datatable
function raz:print_region_datatable_for_id(id)
	if raz.debug == false then
		return
	end
	minetest.log("action", "[" .. raz.modname .. "] raz:print_region_datatable_for_id(id)")
	if raz.raz_store:get_area(id) then
		local region_data = raz:get_region_datatable(id) 

		-- name of the region
		local region_name = region_data.region_name
		-- owner of the region
		local owner = region_data.owner
		-- is the region protected?
		-- true: only owner can 'dig' in the region
		local protected = region_data.protected
		-- guest
		local guests = region_data.guests --guests is a string
		-- is this an PvP region?
		local PvP = region_data.PvP
		-- can Mobs damage the Player?
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
		-- is the parent-flag set?
		local parent = region_data.parent
		minetest.log("action", "[" .. raz.modname .. "] Values of the region ("..id..")")
		minetest.log("action", "[" .. raz.modname .. "] region_name: "..tostring(region_name))
		minetest.log("action", "[" .. raz.modname .. "] owner: "..tostring(owner))
		minetest.log("action", "[" .. raz.modname .. "] protected: "..tostring(protected))
		minetest.log("action", "[" .. raz.modname .. "] guests: "..tostring(guests))
		minetest.log("action", "[" .. raz.modname .. "] PvP: "..tostring(PvP))
		minetest.log("action", "[" .. raz.modname .. "] MvP: "..tostring(MvP))
		minetest.log("action", "[" .. raz.modname .. "] effect: "..tostring(effect))
		minetest.log("action", "[" .. raz.modname .. "] parent: "..tostring(parent))
	else
		minetest.log("action", "[" .. raz.modname .. "] No Values for the Region with the ID: "..id)
	end
end



