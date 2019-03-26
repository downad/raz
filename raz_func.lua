-- recreate the regions-table from AreaStore
function raz:update_regions()
	local counter = 0
	raz.regions = {}
	while raz.raz_store:get_area(counter) do
		table.insert(raz.regions, raz.raz_store:get_area(counter))
		counter = counter + 1
	end
end

-- load the AreaStore from file
function raz:load_regions_from_file()
	raz.raz_store:from_file(raz.worlddir .."/".. raz.store_file_name) -- "/raz_store.dat")
end

-- save AreaStore to file
function raz:save_regions_to_file()
	raz.raz_store:to_file(raz.worlddir .."/".. raz.store_file_name) --.. "/raz_store.dat")
end



-- insert a new region, update AreaStore, save AreaStore
-- pos1 and pos2 must be an vector
-- data must be an designed string like
-- because in the datafield could only stored a string
-- data = "return {[\"owner\"] = \"adownad\", [\"protected\"] = true, [\"PvP\"] = false, [\"MvP\"] = true, [\"effect\"] = \"none\", [\"region_name\"] = \"Meine Wiese mit Haus\"}"
function raz:set_region(pos1,pos2,data)
	local id = raz.raz_store:insert_area(pos1, pos2, data)
	minetest.log("action", "[" .. raz.modname .. "] set_region id ".. tostring(id))
	raz.update_regions()
	--raz.save_regions_to_file()
	if raz.debug == false then
		raz.save_regions_to_file()
	end
end

-- create the designed data string for the AreaStore()
-- data must be an designed string like
-- because in the datafield could only stored a string
-- data = "return {[\"owner\"] = \"adownad\", [\"protected\"] = true, [\"PvP\"] = false, [\"MvP\"] = true, [\"effect\"] = \"none\", [\"region_name\"] = \"Meine Wiese mit Haus\"}
-- owner and region_name are MUST
-- if the rest is missing default will set.
function raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect)
	-- check input-values
	local player = minetest.get_player_by_name(owner)
	if not player then
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
	local data = "return {[\"owner\"] = \""..owner.."\", [\"region_name\"] = \""..region_name.."\", [\"protected\"] = "..tostring(protected)..", [\"guests\"] = \""..guests_string.."\", [\"PvP\"] = "..tostring(PvP)..", [\"MvP\"] = "..tostring(MvP)..", [\"effect\"] = \""..effect.."\"}"  
	return data
end 


-- get the data field of a given region 
-- and returns a table with the data
function raz:get_region_datatable(id)
	local region_values = raz.raz_store:get_area(id,true,true)
	-- the datafield it an designed string that must deserialised to table
	local data = minetest.deserialize(region_values.data)
	return data
end

-- convert a table do a list of strings, there are no key!
function raz:table_to_string(table)
	local string = ""
	for k, v in pairs(table) do
		if k then
			string = string..v..","
		end
	end
	return string
end




-- print a List of all regions to the minetest.log
function raz:print_regions()
	raz.regions = {}
	local counter = 0
	local region_values = ""
	local min = ""
	local max = ""
	local data = ""
	minetest.log("action", "[" .. raz.modname .. "] Print list of stored regions.")
	while raz.raz_store:get_area(counter) do
		region_values = raz.raz_store:get_area(counter,true,true)
		min = region_values.min
		max = region_values.max
		data = region_values.data

		minetest.log("action", "[" .. raz.modname .. "] ------------------")
		minetest.log("action", "[" .. raz.modname .. "] region (" .. counter .. ") ")
		minetest.log("action", "[" .. raz.modname .. "] min (x,y,z) "..tostring(min["x"])..",".. tostring(min["y"])..","..tostring(min["z"]))
		minetest.log("action", "[" .. raz.modname .. "] max (x,y,z) "..tostring(max["x"])..",".. tostring(max["y"])..","..tostring(max["z"]))
		minetest.log("action", "[" .. raz.modname .. "] data ".. tostring(data))

		counter = counter + 1
	end
end

-- a debug function for region_datatable
function raz:print_region_datatable_for_id(id)
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
		minetest.log("action", "[" .. raz.modname .. "] Values of the region ("..id..")")
		minetest.log("action", "[" .. raz.modname .. "] region_name: "..tostring(region_name))
		minetest.log("action", "[" .. raz.modname .. "] owner: "..tostring(owner))
		minetest.log("action", "[" .. raz.modname .. "] protected: "..tostring(protected))
		minetest.log("action", "[" .. raz.modname .. "] guests: "..tostring(guests))
		minetest.log("action", "[" .. raz.modname .. "] PvP: "..tostring(PvP))
		minetest.log("action", "[" .. raz.modname .. "] MvP: "..tostring(MvP))
		minetest.log("action", "[" .. raz.modname .. "] effect: "..tostring(effect))
	else
		minetest.log("action", "[" .. raz.modname .. "] No Values for the Region with the ID: "..id)
	end
end





