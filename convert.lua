-- convert areas to raz
-- Load the areas table from the save file
-- convert them to the converted_areas table
-- call the function: raz:areas_export(raz.areas_raz_export,converted_areas) to export the table
-- return 4 - file did not exist
-- return err - from io.open
-- return the returnvalue from raz:areas_export(raz.areas_raz_export,converted_areas)
function raz:convert_areas()
	local areas = {}

	local file = raz.worlddir .."/".. raz.areas_file
	-- does the file exist?
	if raz:file_exists(file) ~= true then
		-- minetest.log("error", "[" .. raz.modname .. "] raz:file_exists(file) :"..file.." does not exist!") 
		return 4
	end

	local areas_file, err = io.open(file, "r")
	if err then
		areas = {}
		minetest.log("error", "[" .. raz.modname .. "] raz:load_areas() - areas_file, err = io.open :"..err) 
		return err
	end
	areas = minetest.deserialize(areas_file:read("*a"))

	-- Areas mod by ShadowNinja
	-- maybe area isn't a table
	if type(areas) ~= "table" then
		areas = {}
	end
	areas_file:close()
	
	-- the table for the converted areas
	local converted_areas = {}

	-- the data-field of an area
	local data_of_area = {} 

	-- values for the data_of_area
	local parent_id = ""
	local parent_owner= ""
	local parent_area_name = ""
	local parent_parent_of_area = ""
	local parent_pos1
	local parent_pos2
	local parent_guests
	local parent_protected = true


	-- loop all areas
	-- area 	must have: pos1, pos1, owner and name
	--			can have: parent and id	
	for id, area in pairs(areas) do
		minetest.log("action", "[" .. raz.modname .. "] ###### converting - id = "..tostring(id).." ######")
		minetest.log("action", "[" .. raz.modname .. "] ###### area = "..tostring(minetest.serialize(area)).." ######")
		-- if area.parent == nil
		-- no parent set that means this area is stand alone or parent
		if area.parent == nil then
			minetest.log("action", "[" .. raz.modname .. "] if area.parent == nil - id = "..tostring(id))
			-- check converted_areas[id] --> must be nil
			-- initialize converted_areas[id]
			if converted_areas[id] == nil then
				--minetest.log("action", "[" .. raz.modname .. "] if converted_areas[id] == nil ID = "..tostring(id))
				converted_areas[id] = { 
					id = id, 
					owner = area.owner, 
					name = area.name,
					parent = "",
					pos1 = area.pos1,
					pos2 = area.pos2,
					guests = "",
					protected = true
				}
			else
				minetest.log("action", "[" .. raz.modname .. "] **** if area.parent == nil ")
				minetest.log("action", "[" .. raz.modname .. "] **** if converted_areas[id] ~= nil!  ------------> WHY????????????????? ")
				minetest.log("action", "[" .. raz.modname .. "] **** converted_area = "..tostring(minetest.serialize(converted_areas[id])).." ****")
			end
		elseif area.parent ~= nil then
			-- a parent is set 
			-- is this the only parent? 
			-- then set area.owner onto the guest list 
			local found_parent = false
			local id_of_parent = area.parent
			minetest.log("action", "[" .. raz.modname .. "] **** converted_areas set! values:")
			minetest.log("action", "[" .. raz.modname .. "] **** converted_areas set! ID = "..tostring(id) )
			minetest.log("action", "[" .. raz.modname .. "] **** converted_areas set! area.parent = "..tostring(area.parent) )
								
			while found_parent == false do
				if areas[id_of_parent].parent == nil then	-- no parent of parent
					found_parent = true
				else
					id_of_parent = areas[id_of_parent].parent
				end
			end --while found_parent == false do
			minetest.log("action", "[" .. raz.modname .. "] **** converted_areas set! id_of_parent = "..tostring(id_of_parent) )
			-- parent ID is found, two cases
			-- case 1, converted_area[id_of_parent] exists
			if converted_areas[id_of_parent] ~= nil then
				-- get guests form converted_areas 
				--parent_owner= tostring(converted_areas[id_of_parent].owner)
				--parent_area_name = tostring(converted_areas[id_of_parent].name)
				--parent_parent_of_area = tostring(converted_areas[id_of_parent].parent)
				--parent_pos1 = converted_areas[id_of_parent].pos1
				--parent_pos2 = converted_areas[id_of_parent].pos2
				parent_guests = converted_areas[id_of_parent].guests
				minetest.log("action", "[" .. raz.modname .. "] **** parent values: parent_guests (before) = "..tostring(parent_guests) )
				if parent_guests == nil or parent_guests == "" then
					parent_guests = area.owner
				else
					parent_guests = parent_guests..","..area.owner
				end
				--parent_protected = true
				-- set values
				--converted_areas[id_of_parent] = { 
				--	id = id_of_parent, 
				--	owner = parent_owner, 
				--	name = parent_area_name,
				--	parent = parent_parent_of_area,
				--	pos1 = parent_pos1,
				--	pos2 = parent_pos2,
				--	guests = parent_guests,
				--	protected = true
				--}
				minetest.log("action", "[" .. raz.modname .. "] **** parent values: parent_guests (after) = "..tostring(parent_guests) )
				converted_areas[id_of_parent].guests = parent_guests
				minetest.log("action", "[" .. raz.modname .. "] **** parent values: converted_areas[id_of_parent].guests = "..tostring(converted_areas[id_of_parent].guests) )
			-- case 2 it did not exist			
			else --if converted_areas[id_of_parent] ~= nil then
				converted_areas[id] = { 
					id = id, 
					owner = "", 
					name = area.name,
					parent = "",
					pos1 = area.pos1,
					pos2 = area.pos2,
					guests = area.owner,
					protected = true
				}
				minetest.log("action", "[" .. raz.modname .. "] **** if area.parent ~= nil ")
				minetest.log("action", "[" .. raz.modname .. "] **** if converted_areas[id_of_parent] == nil!  ------------> there is no existing parent of parent!")
				minetest.log("action", "[" .. raz.modname .. "] **** if converted_areas[id_of_parent] == nil!  ------------> creating a reagion with Guest as owner!")
				minetest.log("action", "[" .. raz.modname .. "] **** converted_area = "..tostring(minetest.serialize(converted_areas[id])).." ****")
			end --if converted_areas[id_of_parent] ~= nil then
		end -- elseif area.parent ~= nil then
	end -- for id, area in pairs(areas) do

	-- export the converted_areas to file
	return raz:areas_export(raz.areas_raz_export,converted_areas)

end






-- Export the AreaStore table to a file
-- the export-file has this format, 3 lines: [min/pos1], [max/pos2], [data]
	-- 	return {["y"] = -15, ["x"] = -5, ["z"] = 154}
	-- 	return {["y"] = 25, ["x"] = 2, ["z"] = 160}
	--	return {["owner"] = "adownad", ["region_name"] = "dinad Weide", ["protected"] = false, ["guests"] = ",", ["PvP"] = false, ["MvP"] = true, ["effect"] = "dot", ["parent"] = false}
-- return 0 - no error
-- return err from io.open
function raz:areas_export(export_file_name, converted_areas)
	local counter = 0
	local file_name = raz.worlddir .."/".. export_file_name 
	local file
	local err
	-- open/create a new file for the export
	file, err = io.open(file_name, "w")
	if err then	
		minetest.log("action", "[" .. raz.modname .. "] raz:areas_export(export_file_name, converted_areas)")
		minetest.log("action", "[" .. raz.modname .. "] raz:file_exists(file_name) :"..tostring(raz:file_exists(file_name))) 
		minetest.log("error", "[" .. raz.modname .. "] file, err = io.open(file_name, w) ERROR :"..err) 
		return err
	end
	io.close(file)
	
	-- open file for append
	file, err = io.open(file_name, "a")
	if err then	
		minetest.log("action", "[" .. raz.modname .. "] raz:areas_export(export_file_name, converted_areas)")
		minetest.log("error", "[" .. raz.modname .. "] file, err = io.open(file_name, a) ERROR :"..tostring(err)) 
		return err
	--else
	--	minetest.log("action", "[" .. raz.modname .. "] file, err = io.open(file_name, a) opend file :"..tostring(err)) 
	end
	local owner = ""
	local region_name = ""
	local protected = ""
	local guests_string = "" 
	local PvP = raz.default.PvP
	local MvP = raz.default.MvP
	local effect = raz.default.effecz
	local parent = raz.default.parent
	local pos1 = ""
	local pos2 = ""
	local do_not_check_player = true

	-- loop converted_areas and write for every region 3 lines [min/pos1], [max/pos2], [data]
	for k,v in pairs(converted_areas) do
		owner = v.owner
		region_name = v.name
		protected =  v.protected
		--guests_string = v.guests
		if v.guests == "" or v.guests == nil then
			guests_string = ""
		else
			guests_string = raz:remove_double_from_string(v.guests)
		end
		pos1 = v.pos1
		pos2 = v.pos2
		-- create the data-string
		data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,parent,do_not_check_player)

		file:write(minetest.serialize(pos1).."\n")
		file:write(minetest.serialize(pos2).."\n")
		file:write(data.."\n")
	end
	file:close()
	return 5 -- successfully exported
end

