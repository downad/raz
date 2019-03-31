-- recreate the regions-table from AreaStore
-- this must done befor saving the file
function raz:update_regions()
	local counter = 0
	raz.regions = {}
	while raz.raz_store:get_area(counter) do
		table.insert(raz.regions, raz.raz_store:get_area(counter,true,true))
		counter = counter + 1
	end
end

-- load the AreaStore() from file
function raz:load_regions_from_file()
	raz.raz_store:from_file(raz.worlddir .."/".. raz.store_file_name) 
end

-- save AreaStore() to file
function raz:save_regions_to_file()
	raz.raz_store:to_file(raz.worlddir .."/".. raz.store_file_name) 
end



-- Export the AreaStore table to a file
-- the export-file has this format, 3 lines: [min/pos1], [max/pos2], [data]
-- 	return {["y"] = -15, ["x"] = -5, ["z"] = 154}
-- 	return {["y"] = 25, ["x"] = 2, ["z"] = 160}
--	return {["owner"] = "adownad", ["region_name"] = "dinad Weide", ["protected"] = false, ["guests"] = ",", ["PvP"] = false, ["MvP"] = true, ["effect"] = "dot", ["parent"] = false}
function raz:export()
	local counter = 0
	local file_name = raz.worlddir .."/".. raz.export_file_name
	local file
	local err
	-- if the file does not exist, create the file
	if raz:file_exists(file_name) == true then
		minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file_name) :"..tostring(raz:file_exists(file_name))) 
		minetest.log("error", "[" .. raz.modname .. "] raz:file_exists(file_name) :"..file_name.." does exist!") 
	else
		file, err = io.open(file_name, "w")
		if err then	
			minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file_name) :"..tostring(raz:file_exists(file_name))) 
			minetest.log("error", "[" .. raz.modname .. "] file, err = io.open(file_name, w) ERROR :"..err) 
			return err
		end
		io.close(file)
	end	
	
	-- open file for append
	file = io.open(file_name, "a")
	if err then	
		minetest.log("error", "[" .. raz.modname .. "] file, err = io.open(file_name, a) ERROR :"..tostring(err)) 
		return err
	else
		minetest.log("action", "[" .. raz.modname .. "] file, err = io.open(file_name, a) opend file :"..tostring(err)) 
	end
	-- loop AreaStore and write for every region 3 lines [min/pos1], [max/pos2], [data]
	while raz.raz_store:get_area(counter) do
		region_values = raz.raz_store:get_area(counter,true,true)
		pos1 = region_values.min
		pos2 = region_values.max
		data = region_values.data
		counter = counter + 1
		file:write(minetest.serialize(pos1).."\n")
		file:write(minetest.serialize(pos2).."\n")
		file:write(data.."\n")
	end
	file:close()
end


-- Load the exported AreaStore table from the save file
function raz:import()
	local counter = 1
	local pos1 
	local pos2
	local data

	-- does the file exist?
	local file = raz.worlddir .."/".. raz.export_file_name
	minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file) :"..tostring(raz:file_exists(file))) 
	if raz:file_exists(file) ~= true then
		minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file) :"..tostring(raz:file_exists(file))) 
		minetest.log("error", "[" .. raz.modname .. "] raz:file_exists(file) :"..file.." does not exist!") 
		return
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
	raz:update_regions()
	raz:save_regions_to_file()

end

-- see if the file exists
function raz:file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty 
-- list/table if the file does not exist
function raz:lines_from(file)
	if not file_exists(file) then return {} end
	local lines = {}
	for line in io.lines(file) do 
	lines[#lines + 1] = line
	end
	return lines
end



--[[
-- Populates the AreaStore after loading, if needed.
function raz:populateStore()
	minetest.log("action", "[" .. raz.modname .. "] raz:populateStore() ")

	if not rawget(_G, "AreaStore") then
		return
	end
	local store = AreaStore()
	local store_ids = {}
	for id, zone in pairs(raz.regions) do
		minetest.log("action", "[" .. raz.modname .. "] ID: "..id)
		minetest.log("action", "[" .. raz.modname .. "] region: "..tostring(zone))
		--local sid = store:insert_area(raz.regions.min,raz.regions.max, tostring(raz.regions.data))
		--if not self:checkAreaStoreId(sid) then
		--	return
		--end
		--store_ids[id] = sid
	end
	--self.store = store
	--self.store_ids = store_ids
end
]]--


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
function raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,parent)
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
	if not type(parent) == "boolean" or parent == nil then
		parent = raz.default.parent
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
	local data = "return {[\"owner\"] = \""..owner.."\", [\"region_name\"] = \""..region_name.."\", [\"protected\"] = "..tostring(protected)..", [\"guests\"] = \""..guests_string.."\", [\"PvP\"] = "..tostring(PvP)..", [\"MvP\"] = "..tostring(MvP)..", [\"effect\"] = \""..effect.."\", [\"parent\"] = "..tostring(parent).."}"  
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





