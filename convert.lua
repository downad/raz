-- convert areas to raz
-- Load the areas table from the save file
-- convert them to the converted_areas table
-- call the function: raz:areas_export(raz.areas_raz_export,converted_areas) to export the table
-- return 4 - file did not exist
-- return err - from io.open
-- return the returnvalue from raz:areas_export(raz.areas_raz_export,converted_areas)
function raz:convert_areas()
	local areas = {}

	-- check privileg region_admin
	local err = minetest.check_player_privs(name, { region_admin = true })
	if not err then 
		return err		
	end	
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
	local id_of_area = ""
	local owner_of_area = ""
	local area_name = ""
	local parent_of_area = ""
	local pos1_of_area = ""
	local pos2_of_area = ""
	local guest_of_area = ""
	local guests = {}
	local protection_of_area = true


	-- loop all areas
	-- area 	must have: pos1, pos1, owner and name
	--			can have: parent and id	
	for id, area in pairs(areas) do
		minetest.log("action", "[" .. raz.modname .. "] ###### converting - id = "..tostring(id).." ######")
		minetest.log("action", "[" .. raz.modname .. "] ###### area = "..tostring(minetest.serialize(area)).." ######")
		-- if area.parent == nil
		-- 	the area has no parent, the owner is new owner 
		--		converted area: 
		--		fill id, owner, parent ="", pos1, pos2, guests = "", protected = true
		if area.parent == nil then
			minetest.log("action", "[" .. raz.modname .. "] if area.parent == nil - id = "..tostring(id))
			-- initialize converted_areas[id]
			if converted_areas[id] == nil then
				minetest.log("action", "[" .. raz.modname .. "] if converted_areas[id] == nil ID = "..tostring(id))
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
				minetest.log("action", "[" .. raz.modname .. "] **** if area.parent == nil then ****")
				minetest.log("action", "[" .. raz.modname .. "] **** if converted_areas[id] == nil then ****")
				minetest.log("action", "[" .. raz.modname .. "] **** converted_area = "..tostring(minetest.serialize(converted_areas[id])).." ****")

			else -- if converted_areas[id] == nil then
			-- converted_areas[id] exists
			-- that can happen if guests is set, maybe parent can be set 
			-- get all values
				minetest.log("action", "[" .. raz.modname .. "] if converted_areas[id] else ID = "..tostring(id))
				id_of_area = tostring(converted_areas[id].id)				-- must be the id
				owner_of_area = tostring(converted_areas[id].owner)		-- must be "" and set with area.owner
				parent_of_area = tostring(converted_areas[id].parent)		-- the guest initialized this converted_areas
				pos1_of_area = (converted_areas[id].pos1)			-- check if it is the same area
				pos2_of_area = (converted_areas[id].pos2)			-- check if it is the same area
				if converted_areas[id].guests ~= nil then
					guest_of_area = converted_areas[id].guests		-- the guest initialized this converted_areas
				else
					guest_of_area = ""
				end
				protection_of_area = true 								-- all converted areas are proteced!
				area_name = tostring(converted_areas[id].name)
				-- do some checks
				if id ~= id_of_area then
					minetest.log("action", "[" .. raz.modname .. "] id ~= id_of_area! ID = "..tostring(id))
				end
				if owner_of_area ~= "" then
					minetest.log("action", "[" .. raz.modname .. "] owner_of_area is set. WHY?! owner_of_area = "..tostring(owner_of_area))
				else
					owner_of_area = area.owner
				end
				if pos1_of_area ~= area.pos1 then
					minetest.log("action", "[" .. raz.modname .. "] area.pos1 ~= pos1 ID = "..tostring(id))
				end
				if pos2_of_area ~= area.pos2 then
					minetest.log("action", "[" .. raz.modname .. "] area.pos1 ~= pos2 ID = "..tostring(id))
				end
				if guest_of_area == "" then
					minetest.log("action", "[" .. raz.modname .. "] guest_of_area is empty! ID = "..tostring(id))	
				end	
			-- set values
				converted_areas[id] = { 
					id = id_of_area, 
					owner = owner_of_area, 
					name = area_name,
					parent = parent_of_area,
					pos1 = pos1_of_area,
					pos2 = pos2_of_area,
					guests = guest_of_area,
					protected = true
				}
				minetest.log("action", "[" .. raz.modname .. "] **** if area.parent == nil then ****")
				minetest.log("action", "[" .. raz.modname .. "] **** else converted_areas[id] == nil ****")
				minetest.log("action", "[" .. raz.modname .. "] ****converted_area (esle area.parent == nil) = "..tostring(minetest.serialize(converted_areas[parent_of_area])).." ****")

			end -- if converted_areas[id] == nil then
		else -- if area.parent == nil then
		-- an parent is set
		-- that means the owner is guest in an other area
		-- the converted_areas[parent]
			-- initialize converted_areas[id]
			parent_of_area = area.parent
			if converted_areas[parent_of_area] == nil then
				minetest.log("action", "[" .. raz.modname .. "] if converted_areas[parent_of_area] == nil ID(parent_of_area) = "..tostring(parent_of_area))
				converted_areas[id] = { 
					id = id, 
					owner = "", 
					name = area.name,
					parent = parent_of_area,
					pos1 = area.pos1,
					pos2 = area.pos2,
					guests = area.owner,			-- the onwer is an guest of the parent
					protected = true
				}
				minetest.log("action", "[" .. raz.modname .. "] **** else area.parent == nil  ****")
				minetest.log("action", "[" .. raz.modname .. "] **** if converted_areas[parent_of_area] == nil then ****")
				minetest.log("action", "[" .. raz.modname .. "] ****converted_area = "..tostring(minetest.serialize(converted_areas[parent_of_area])).." ****")
			else -- if converted_areas[parent_of_area] == nil then
			-- converted_areas[parent] exists
				-- the area has no parent == ""
				-- the owner is a guest in the parent areas
				minetest.log("action", "[" .. raz.modname .. "] if converted_areas[parent_of_area] - else - ID(parent_of_area) = "..tostring(parent_of_area))
				if converted_areas[parent_of_area].parent == ""  or converted_areas[parent_of_area].parent == nil then
					minetest.log("action", "[" .. raz.modname .. "] if converted_areas[parent_of_area].parent == \"\" ID = "..tostring(id))
					minetest.log("action", "[" .. raz.modname .. "] parent_of_area = "..tostring(parent_of_area))
					minetest.log("action", "[" .. raz.modname .. "] area.pos1 = "..tostring(minetest.serialize(area.pos1)))
					minetest.log("action", "[" .. raz.modname .. "] parent.pos1 = "..tostring(minetest.serialize(converted_areas[parent_of_area].pos1)))
		
					-- get all values
					id_of_area = parent_of_area											-- must be the id
					owner_of_area = tostring(converted_areas[parent_of_area].owner)		-- must set 
					pos1_of_area = (converted_areas[parent_of_area].pos1)			-- check if it is the same area
					pos2_of_area = (converted_areas[parent_of_area].pos2)			-- check if it is the same area
					if converted_areas[parent_of_area].guests ~= nil then
						guest_of_area = converted_areas[parent_of_area].guests		-- the guest initialized this converted_areas
					else
						guest_of_area = ""
					end	
					protection_of_area = true 										-- all converted areas are proteced!
					area_name = tostring(converted_areas[parent_of_area].name)			
					
					-- do some checks
					if owner_of_area == "" then
						minetest.log("action", "[" .. raz.modname .. "] owner_of_area is NOT set. WHY?! parent_of_area = "..tostring(parent_of_area))
					end
					if pos1_of_area ~= area.pos1 then
						minetest.log("action", "[" .. raz.modname .. "] area.pos1 ~= pos1 ID = "..tostring(id))
					end
					if pos2_of_area ~= area.pos2 then
						minetest.log("action", "[" .. raz.modname .. "] area.pos2 ~= pos2 ID = "..tostring(id))
					end
					if guest_of_area == "" then
						minetest.log("action", "[" .. raz.modname .. "] guest_of_area is empty! ID = "..tostring(id))
						guest_of_area = area.guests
					else
						guest_of_area = guest_of_area..","..area.guests
					end	
				-- set values
					converted_areas[parent_of_area] = { 
						id = id_of_area, 
						owner = owner_of_area, 
						name = area_name,
						parent = parent_of_area,
						pos1 = pos1_of_area,
						pos2 = pos2_of_area,
						guests = guest_of_area,
						protected = true
					}	
				minetest.log("action", "[" .. raz.modname .. "] **** else area.parent == nil  ****")
				minetest.log("action", "[" .. raz.modname .. "] **** else converted_areas[parent_of_area] == nil ****")
				minetest.log("action", "[" .. raz.modname .. "] **** converted_area = "..tostring(minetest.serialize(converted_areas[parent_of_area])).." ****")	
				-- the area an parent
				-- that means an owner of an subarea invited new owners
				-- this became a guest in the parent areas
				else -- if converted_areas[parent_of_area].parent == ""  or converted_areas[parent_of_area].parent == nil then
				-- get the ID from the parent and add all value into parent_of_area
					-- get all values
					minetest.log("action", "[" .. raz.modname .. "] if converted_areas[parent_of_area].parent - else -  converted_areas[parent_of_area].parent = "..tostring(converted_areas[parent_of_area].parent))
					parent_of_area = converted_areas[parent_of_area].parent				-- hte parent id is the new parent ID
					id_of_area = parent_of_area											-- must be the id
					owner_of_area = tostring(converted_areas[parent_of_area].owner)		-- must set 
					pos1_of_area = (converted_areas[parent_of_area].pos1)			-- check if it is the same area
					pos2_of_area = (converted_areas[parent_of_area].pos2)			-- check if it is the same area
					guest_of_area = converted_areas[parent_of_area].guests		-- if a guest initialized this converted_areas
					protection_of_area = true 											-- all converted areas are proteced!
					area_name = tostring(converted_areas[parent_of_area].name)
					-- do some checks
					if owner_of_area == "" then
						minetest.log("action", "[" .. raz.modname .. "] owner_of_area is NOT set. WHY?! parent_of_area = "..tostring(parent_of_area))
					end
					if pos1_of_area ~= area.pos1 then
						minetest.log("action", "[" .. raz.modname .. "] area.pos1 ~= pos1 ID = "..tostring(id))
					end
					if pos2_of_area ~= area.pos2 then
						minetest.log("action", "[" .. raz.modname .. "] area.pos1 ~= pos2 ID = "..tostring(id))
					end
					if guest_of_area == "" or guest_of_area == nil then
						minetest.log("action", "[" .. raz.modname .. "] guest_of_area is empty! ID = "..tostring(id))
						if area.guest == nil or area.guest == "" then
							guest_of_area = area.owner
						else
							guest_of_area = area.guests
						end
					else
						guest_of_area = guest_of_area..","..area.owner					-- the owner is guest in parent area
					end	
				-- set values
					converted_areas[parent_of_area] = { 
						id = id_of_area, 
						owner = owner_of_area, 
						name = area_name,
						parent = parent_of_area,
						pos1 = pos1_of_area,
						pos2 = pos2_of_area,
						guests = guest_of_area,
						protected = true
					}	
				end -- if converted_areas[parent_of_area].parent == ""  or converted_areas[parent_of_area].parent == nil then
			end  -- if converted_areas[parent_of_area] == nil then 

 		end -- if area.parent == nil then

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
		guests_string = v.guests
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

