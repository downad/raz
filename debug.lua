
-- set some regions
local data = ""

-- test 1
-- vector(x,y,z) y -> up/down
local pos1 = vector.new(0, -15, 128)  	-- down
local pos2 = vector.new(-6, 25, 136)	-- up
local owner = "adownad"
local region_name = "Mein Haus"
local protected = true				-- default = false
local guest = ""					-- default = ""
local guest1 = "dinad"
local guest2 = "elrond"
local guests = {}
	table.insert(guests, guest1)
	table.insert(guests, guest2)
	local guests_string = raz:table_to_string(guests)	
local PvP = true					-- default = false		
local MvP = true					-- default = true
local effect = "none"				-- default = none
local parent = true					-- default = false
 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,parent)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end

--test 2
-- vector(x,y,z) y -> up/down
pos1 = vector.new(2, -15, 160)  	-- down
pos2 = vector.new(-5, 25, 154)		-- up
owner = "dinad"
region_name = "dinad Weide"
protected = false				-- default = false
guest = ""						-- default = ""
guests = {}
	table.insert(guests, guest)
	guests_string = raz:table_to_string(guests)	
PvP = false						-- default = false		
MvP = true						-- default = true
effect = "dot"					-- default = none
parent = false					-- default = false	

data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,parent)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end

--test 3
-- vector(x,y,z) y -> up/down
pos1 = vector.new(-10, -15, 141)  	-- down
pos2 = vector.new(11, 25, 116)		-- up
owner = "adownad"
region_name = "Meine Garten um das Haus"
protected = true					-- default = false
guest = "downad"					-- default = ""
guests = {}
	table.insert(guests, guest)
	 guests_string = raz:table_to_string(guests)	
PvP = false						-- default = false		
MvP = true						-- default = true
effect = "none"					-- default = none
parent = false					-- default = false	

 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,parent)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end

--test 4
-- vector(x,y,z) y -> up/down
pos1 = vector.new(-15, -15, 148)  	-- down
pos2 = vector.new(-11, 25, 146)		-- up
owner = "adownad"
region_name = "Tempel"
protected = true					-- default = false
guest = ""							-- default = ""
guests = {}
	table.insert(guests, guest)
	 guests_string = raz:table_to_string(guests)	
PvP = false						-- default = false		
MvP = true						-- default = true
effect = "holy"					-- default = none
parent = false					-- default = false	

 
data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,parent)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end


--test 5
-- vector(x,y,z) y -> up/down
pos1 = vector.new(13, -15, 148)  	-- down
pos2 = vector.new(15, 25, 150)		-- up
owner = "downad"
region_name = "Evil Tempel"
protected = true					-- default = false
guest = ""							-- default = ""
guests = {}
	table.insert(guests, guest)
	 guests_string = raz:table_to_string(guests)	
PvP = true						-- default = false		
MvP = true						-- default = true
effect = "evil"					-- default = none
parent = false					-- default = false	


data = raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,parent)
if data == 1 then
	minetest.log("action", "[" .. raz.modname .. "] can not create data!" )  
else
	if raz.debug then
		raz:set_region(pos1,pos2,data)
	end
end

-- print a list of all raz.regions
raz:print_regions()



-- only for debugging

minetest.log("action", "[" .. raz.modname .. "] some regions created!")

-- Regiontest 
local test_id = 0
local counter = 0
--while raz.raz_store:get_area(counter) do
--	raz:print_region_datatable_for_id(counter)
--	counter = counter + 1
--end


------------------------ old
-- Export the AreaStore table to a file
--[[
function raz:export_2()
	raz:update_regions()
	local region_values = minetest.serialize(raz.regions)
	--local datastr = {}
	--while raz.raz_store:get_area(counter) do
	--	region_values = raz.raz_store:get_area(counter,true,true)	
--	end
	--local datastr = minetest.serialize(raz.raz_store)
	if not region_values then
		minetest.log("error", "[raz] Failed to serialize AreaStore!")
		return
	end
	local file_name = raz.worlddir .."/".. raz.export_file_name
	local file, err = io.open(file_name, "w")
	if err then
		return err
	end
	file:write(region_values)
	file:close()
end
]]--
