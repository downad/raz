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

-----------------------------------------
--
-- convert areas 
-- [areas - ShadowNinja - https://github.com/minetest-mods/areas] to raz
--
-----------------------------------------
-- Load the areas table from the save file
-- convert them to the converted_areas table
-- call the function: raz:areas_export(raz.areas_raz_export,converted_areas) to export the table
-- msg/error handling: 
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
	local region_id = ""
	local region_owner= ""
	local region_area_name = ""
	local region_pos1
	local region_pos2
	local region_guests
	local region_protected = true


	-- loop all areas
	-- area 	must have: pos1, pos1, owner and name
	--			can have: plot and id	
	for id, area in pairs(areas) do
		minetest.log("action", "[" .. raz.modname .. "] ###### converting - id = "..tostring(id).." ######")
		minetest.log("action", "[" .. raz.modname .. "] ###### area = "..tostring(minetest.serialize(area)).." ######")
		-- if area.plot == nil
		-- no plot set that means this area is stand alone or plot
		if area.plot == nil then
			minetest.log("action", "[" .. raz.modname .. "] if area.plot == nil - id = "..tostring(id))
			-- check converted_areas[id] --> must be nil
			-- initialize converted_areas[id]
			if converted_areas[id] == nil then
				--minetest.log("action", "[" .. raz.modname .. "] if converted_areas[id] == nil ID = "..tostring(id))
				converted_areas[id] = { 
					id = id, 
					owner = area.owner, 
					name = area.name,
					plot = "",
					pos1 = area.pos1,
					pos2 = area.pos2,
					guests = "",
					protected = true
				}
			else
				minetest.log("action", "[" .. raz.modname .. "] **** if area.plot == nil ")
				minetest.log("action", "[" .. raz.modname .. "] **** if converted_areas[id] ~= nil!  ------------> WHY????????????????? ")
				minetest.log("action", "[" .. raz.modname .. "] **** converted_area = "..tostring(minetest.serialize(converted_areas[id])).." ****")
			end
		elseif area.plot ~= nil then
			-- a plot is set 
			-- is this the only plot? 
			-- then set area.owner onto the guest list 
			local found_plot = false
			local id_of_plot = area.plot
			minetest.log("action", "[" .. raz.modname .. "] **** converted_areas set! values:")
			minetest.log("action", "[" .. raz.modname .. "] **** converted_areas set! ID = "..tostring(id) )
			minetest.log("action", "[" .. raz.modname .. "] **** converted_areas set! area.plot = "..tostring(area.plot) )
								
			while found_plot == false do
				if areas[id_of_plot].plot == nil then	-- no plot of plot
					found_plot = true
				else
					id_of_plot = areas[id_of_plot].plot
				end
			end --while found_plot == false do
			minetest.log("action", "[" .. raz.modname .. "] **** converted_areas set! id_of_plot = "..tostring(id_of_plot) )
			-- plot ID is found, two cases
			-- case 1, converted_area[id_of_plot] exists
			if converted_areas[id_of_plot] ~= nil then
				-- get guests form converted_areas 
				region_guests = converted_areas[id_of_plot].guests
				minetest.log("action", "[" .. raz.modname .. "] **** plot values: region_guests (before) = "..tostring(region_guests) )
				if region_guests == nil or region_guests == "" then
					region_guests = area.owner
				else
					region_guests = region_guests..","..area.owner
				end
				-- set values
				minetest.log("action", "[" .. raz.modname .. "] **** plot values: region_guests (after) = "..tostring(region_guests) )
				converted_areas[id_of_plot].guests = region_guests
				minetest.log("action", "[" .. raz.modname .. "] **** plot values: converted_areas[id_of_plot].guests = "..tostring(converted_areas[id_of_plot].guests) )
			-- case 2 it did not exist			
			else --if converted_areas[id_of_plot] ~= nil then
				converted_areas[id] = { 
					id = id, 
					owner = "", 
					name = area.name,
					plot = "",
					pos1 = area.pos1,
					pos2 = area.pos2,
					guests = area.owner,
					protected = true
				}
				minetest.log("action", "[" .. raz.modname .. "] **** if area.plot ~= nil ")
				minetest.log("action", "[" .. raz.modname .. "] **** if converted_areas[id_of_plot] == nil!  ------------> there is no existing plot of plot!")
				minetest.log("action", "[" .. raz.modname .. "] **** if converted_areas[id_of_plot] == nil!  ------------> creating a reagion with Guest as owner!")
				minetest.log("action", "[" .. raz.modname .. "] **** converted_area = "..tostring(minetest.serialize(converted_areas[id])).." ****")
			end --if converted_areas[id_of_plot] ~= nil then
		end -- elseif area.plot ~= nil then
	end -- for id, area in pairs(areas) do

	-- export the converted_areas to file
	return raz:areas_export(raz.areas_raz_export,converted_areas)

end





-----------------------------------------
--
-- Export the AreaStore table to a file
--
-----------------------------------------
-- Export the AreaStore table to a file
-- the export-file has this format, 3 lines: [min/pos1], [max/pos2], [data]
-- 	return {["y"] = -15, ["x"] = -5, ["z"] = 154}
-- 	return {["y"] = 25, ["x"] = 2, ["z"] = 160}
--	return {["owner"] = "adownad", ["region_name"] = "dinad Weide", ["protected"] = false, ["guests"] = ",", ["PvP"] = false, ["MvP"] = true, ["effect"] = "dot", ["plot"] = false, ["city"] = false}
-- msg/error handling: 
-- return 5 -- successfully exported
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
	local plot = raz.default.plot
	local city = raz.default.city
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
		data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,plot,city,do_not_check_player)

		file:write(minetest.serialize(pos1).."\n")
		file:write(minetest.serialize(pos2).."\n")
		file:write(data.."\n")
	end
	file:close()
	return 5 -- successfully exported
end

