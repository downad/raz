-- recreate the regions-table from AreaStore
-- this must done befor saving the file
-- WHY?
-- return 0 - no error.
function raz:update_regions()
	minetest.log("action", "[" .. raz.modname .. "] raz:update_regions() ")
	local counter = 0
	raz.regions = {}
	while raz.raz_store:get_area(counter) do
		table.insert(raz.regions, raz.raz_store:get_area(counter,true,true))
		counter = counter + 1
		minetest.log("action", "[" .. raz.modname .. "] raz:update_regions() counter :"..tostring(counter).."!!!!!") 
		--raz:print_region_datatable_for_id(counter)
	end
	-- save
	raz:save_regions_to_file()
	-- No Error
	return 0 
end

-- load the AreaStore() from file
-- return 0 - no error.
function raz:load_regions_from_file()
	minetest.log("action", "[" .. raz.modname .. "] raz:load_regions_from_file()")
	raz.raz_store:from_file(raz.worlddir .."/".. raz.store_file_name) 
	-- No Error
	return 0 
end

-- save AreaStore() to file
-- return 0 - no error.
function raz:save_regions_to_file()
	minetest.log("action", "[" .. raz.modname .. "] raz:save_regions_to_file()")	
	raz.raz_store:to_file(raz.worlddir .."/".. raz.store_file_name) 
	-- No Error
	return 0 
end

-- delete id form AreaStore()
-- the get_areas return a pointer, so re-copie the areastore and 'forget' to copie the region with the id
-- check if id ~=0
-- return 0 - no error
-- return 1 
function raz:delete_region(id)
	minetest.log("action", "[" .. raz.modname .. "] raz:delete_region(id) ID: "..tostring(id)) 
	if raz.raz_store:get_area(id) == nil then
		-- Error
		return 1
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



-- Export the AreaStore table to a file
-- the export-file has this format, 3 lines: [min/pos1], [max/pos2], [data]
-- 	return {["y"] = -15, ["x"] = -5, ["z"] = 154}
-- 	return {["y"] = 25, ["x"] = 2, ["z"] = 160}
--	return {["owner"] = "adownad", ["region_name"] = "dinad Weide", ["protected"] = false, ["guests"] = ",", ["PvP"] = false, ["MvP"] = true, ["effect"] = "dot", ["parent"] = false}
-- return 0 - no error
-- return err from io.open
function raz:export(export_file_name)
	local file_name = raz.worlddir .."/".. export_file_name --raz.export_file_name
	local file
	local err

	-- open/create a new file for the export
	file, err = io.open(file_name, "w")
	if err then	
		minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file_name) :"..tostring(raz:file_exists(file_name))) 
		minetest.log("error", "[" .. raz.modname .. "] file, err = io.open(file_name, w) ERROR :"..err) 
		return err
	end
	io.close(file)
	
	-- open file for append
	file = io.open(file_name, "a")

	--local region_values = {} 
	local pos1 = ""
	local pos2 = ""
	local data = ""
	local counter = 0
	-- loop AreaStore and write for every region 3 lines [min/pos1], [max/pos2], [data]
	while raz.raz_store:get_area(counter) do

		--region_values = raz.raz_store:get_area(counter,true,true)
		--pos1 = region_values.min
		--pos2 = region_values.max
		--data = region_values.data
		pos1,pos2,data = raz:get_region_data_by_id(counter,true)
		if type(pos1) ~= "table" then
			return pos1
		end
		counter = counter + 1
		file:write(minetest.serialize(pos1).."\n")
		file:write(minetest.serialize(pos2).."\n")
		file:write(data.."\n")
	end
	file:close()
	-- No Error
	return 0
end


-- Load the exported AreaStore table from the save file
function raz:import(import_file_name)
	local counter = 1
	local pos1 
	local pos2
	local data

	-- does the file exist?
	local file = raz.worlddir .."/"..import_file_name 
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
	-- No Error
	return 0

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

-- insert a new region, update AreaStore, save AreaStore
-- pos1 and pos2 must be an vector
-- data must be an designed string like
-- because in the datafield could only stored a string
-- data = "return {[\"owner\"] = \"adownad\", [\"protected\"] = true, [\"PvP\"] = false, [\"MvP\"] = true, [\"effect\"] = \"none\", [\"region_name\"] = \"Meine Wiese mit Haus\"}"
function raz:set_region(pos1,pos2,data)
	minetest.log("action", "[" .. raz.modname .. "] raz:set_region(pos1,pos2,data)")	
	if type(data) ~= "string" then
		data = minetest.serialize(data)
	end
	local id = raz.raz_store:insert_area(pos1, pos2, data)
	minetest.log("action", "[" .. raz.modname .. "] set_region id ".. tostring(id))
	raz.update_regions()
	raz.save_regions_to_file()
	return id
end

-- create the designed data string for the AreaStore()
-- data must be an designed string like
-- because in the datafield could only stored a string
-- data = "return {[\"owner\"] = \"adownad\", [\"protected\"] = true, [\"PvP\"] = false, [\"MvP\"] = true, [\"effect\"] = \"none\", [\"region_name\"] = \"Meine Wiese mit Haus\"}
-- owner and region_name are MUST
-- if the rest is missing default will set.
-- the flag -do_not_check_player = true allows to create regions for owners who are not player - maybe because you will convert an areas.dat for an other system.
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
	local data = "return {[\"owner\"] = \""..owner.."\", [\"region_name\"] = \""..region_name.."\", [\"protected\"] = "..tostring(protected)..", [\"guests\"] = \""..guests_string.."\", [\"PvP\"] = "..tostring(PvP)..", [\"MvP\"] = "..tostring(MvP)..", [\"effect\"] = \""..effect.."\", [\"parent\"] = "..tostring(parent).."}"  
	return data
end 


-- get the data field of a given region 
-- and returns a table with the data
function raz:get_region_datatable(id)
	--minetest.log("action", "[" .. raz.modname .. "] raz:get_region_datatable(id)")
	local region_values = raz.raz_store:get_area(id,true,true)
	-- the datafield is an designed string that must deserialised to table
	local data = minetest.deserialize(region_values.data)
	--table.insert(data,region_values.min)
	--table.insert(data,region_values.max)
	return data
end

-- convert a table do a list of strings, there is no key!
function raz:table_to_string(table)
	minetest.log("action", "[" .. raz.modname .. "] raz:table_to_string(table)")
	local string = ""
	for k, v in pairs(table) do
		if k then
			string = string..v..","
		end
	end
	return string
end

-- command region_special show
function raz:region_show(name,list_start,list_end)
	minetest.log("action", "[" .. raz.modname .. "] raz:region_show(name,list_start,list_end)")
	local region_values = {}
	local pos1 = ""
	local pos2 = ""
	local data = ""
	local chat_string = ""
	if list_start == nil then
		list_start = 0
	end
	local counter = list_start
	if list_end == nil or list_end < list_start then
		list_end = list_start 
	end
	local stop_list = list_end
	if list_start == list_end then
		stop_list = -1
	end
	-- get all regions in AreaStore()
	while raz.raz_store:get_area(counter) do
		if counter <= stop_list or stop_list < 0 then
			region_values = raz.raz_store:get_area(counter,true,true)
			pos1 = "["..region_values.min.x..","..region_values.min.y..","..region_values.min.z.."]"
			pos2 = "["..region_values.max.x..","..region_values.max.y..","..region_values.max.z.."]"
			data = minetest.deserialize(region_values.data)
			chat_string = chat_string.."\n"..counter.." - "..data.region_name.." {"..data.owner.."} "..pos1.." / "..pos2
			chat_string = chat_string.." protected: "..tostring(data.protected).." Guests: "..data.guests.."\n"
			if data.PvP then
				chat_string = chat_string.." PvP "
			end
			if data.MvP then
				chat_string = chat_string.." MvP "
			end
			if data.effect ~="none" then
				chat_string = chat_string.." - " ..tostring(data.effect).." - "
			end
			if data.parent then
				chat_string = chat_string.." is parent "
			end
		end -- if counter <= stop_list or stop_list < 0 then
		counter = counter + 1
	end --while raz.raz_store:get_area(counter) do
	minetest.chat_send_player(name, chat_string)
end


-- command set_parent
-- return String - no error
-- return err [2] = "No region with this ID!",
function raz:region_set_parent(id,bool)
	minetest.log("action", "[" .. raz.modname .. "] raz:region_set_parent(id,bool)")
	local region_values = ""
	local pos1 = ""
	local pos2 = ""
	local data = {}
	-- ckeck ID
	if raz.raz_store:get_area(id) then
	-- set bool 
	--	region_values = raz.raz_store:get_area(id,true,true)
	--	pos1 = region_values.min
	--	pos2 = region_values.max
	--	data = minetest.deserialize(region_values.data)
		pos1,pos2,data = raz:get_region_data_by_id(id)
		data.parent = bool
		-- remove from AreaStore ID
--		local region_deleted = raz:delete_region(id)
--		raz:update_regions()

		-- insert in AreaStoren 
--		local new_id = raz:set_region(pos1,pos2,data)
		raz:update_regions_data(id,pos1,pos2,data)
		raz:print_region_datatable_for_id(id)


		-- update
		raz:update_regions()
		return "Region with ID: "..id.." set parent = "..tostring(bool)
	else
		-- Error
		return 2 -- [2] = "No region with this ID!"
	end
end
-- get all values of a region by id
-- return pos1,pos2 and data (as table)
function raz:get_region_data_by_id(id,no_deserialize)
	minetest.log("action", "[" .. raz.modname .. "] raz:get_region_data_by_id(id) ID: "..tostring(id).." raz.raz_store:get_area(id) = "..tostring(raz.raz_store:get_area(id) )) 
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
--	end
end

-- update datafield  AreaStore()
-- id, the ID to change
-- pos1, pos2 and data are the values to insert
function raz:update_regions_data(id,pos1,pos2,data_table)
	minetest.log("action", "[" .. raz.modname .. "] raz:update_regions_data(id,pos1,pos2,data) ID: "..tostring(id)) 
	minetest.log("action", "[" .. raz.modname .. "] pos1 = "..minetest.serialize(pos1)) 
	minetest.log("action", "[" .. raz.modname .. "] pos2 = "..minetest.serialize(pos2)) 
	local data_string = minetest.serialize(data_table)
	minetest.log("action", "[" .. raz.modname .. "] data_string = "..data_string) 
	minetest.log("action", "[" .. raz.modname .. "] type(id) = "..type(id)) 

	local counter = 0
	-- create an temporary AreaStore()
	local temp_store = AreaStore() 
	local region_values = {}
	-- copy all regions to temp_store
	while raz.raz_store:get_area(counter) do
		minetest.log("action", "[" .. raz.modname .. "] 1. while - counter = "..tostring(counter)) 
		if counter ~=tonumber(id) then
			region_values = raz.raz_store:get_area(counter,true,true)
			temp_store:insert_area(region_values.min, region_values.max, region_values.data)
		else
			minetest.log("action", "[" .. raz.modname .. "] -else- counter = "..tostring(counter)) 
			minetest.log("action", "[" .. raz.modname .. "] pos1 = "..minetest.serialize(pos1)) 
			minetest.log("action", "[" .. raz.modname .. "] pos2 = "..minetest.serialize(pos2)) 
			minetest.log("action", "[" .. raz.modname .. "] data = "..data_string) 
			temp_store:insert_area(pos1, pos2, data_string)
		end
		
		counter = counter + 1
	end
	-- recreate raz.raz_store
	raz.raz_store = AreaStore()
	--raz.raz_store = {}
	counter = 0
	-- copy all regions from temp_store to raz.raz_store
	while temp_store:get_area(counter) do
		minetest.log("action", "[" .. raz.modname .. "] 2. while - counter = "..tostring(counter)) 
		region_values = temp_store:get_area(counter,true,true)
		minetest.log("action", "[" .. raz.modname .. "] pos1 = "..tostring(minetest.serialize(region_values.min)))
		minetest.log("action", "[" .. raz.modname .. "] pos2 = "..tostring(minetest.serialize(region_values.max))) 
		minetest.log("action", "[" .. raz.modname .. "] data = "..tostring(region_values.data)) 
	
		raz.raz_store:insert_area(region_values.min, region_values.max, region_values.data)
		counter = counter + 1
	end
	temp_store = {}
	return true
end


-- print a List of all regions to the minetest.log
function raz:print_regions()
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

-- this function tries to handle errors
-- input err
-- if err == "", nil or 0 -> no Error: nothing happens
-- else minetest.log("error",
-- the raz.error_text[err] is defined in init.
function raz:error_handling(err)
	if err == "" or err == nil or err == 0 then
		return 
	end
	minetest.log("action", "[" .. raz.modname .. "] ##########################################################")
	minetest.log("action", "[" .. raz.modname .. "] error_handling -err: " .. tostring(err))
	minetest.log("action", "[" .. raz.modname .. "] type(err): " .. type(err))
	
	
--	if type(err) == "string" then
--		minetest.log("error", "[" .. raz.modname .. "] Error: ".. err)	
--	elseif type(err) == "number" then
--		minetest.log("error", "[" .. raz.modname .. "] Error: ".. raz.error_text[err])	
--	end
end




