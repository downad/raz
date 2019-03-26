
--globalstep
-- find the region from player position -> get_areas_for_pos
-- create a string with region-name and owner an show it in the hud
-- if there is an effect in the area - do it to the player
local timer = 0
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = vector.round(player:getpos())

		--color for PvP and protected
		local color = raz.color["white"]
		local protected = false				-- true then color blue
		local PvP = false					-- true then color red - both then purple
								

		-- all pos without any region are wilderness
		local hud_stringtext = "wilderness"
		if raz.pvp_only_in_pvp_regions then
			hud_stringtext = "wilderness"
		elseif raz.enable_pvp then	
			hud_stringtext = "wilderness (PvP)"
			PvP = true
		end

		-- all values of this region
		-- region_values.min -> table of koordinates 
		-- region_values.max -> table of koordinates
		-- region_values.data -> string of koordinartes
		--     there it gives region_name, owner, protected, guests, PvP, MvP, effect 
		local region_values = ""
		
		
		local protected_string = ""
		local PvP_string = ""
		local effect = ""
		local is_effect = false
		local effects = {} -- if there are more than one effect at a place
		
		timer = timer + dtime

		local pos_has_regions = false
		-- loop als regions
		for region_id, v in pairs(raz.raz_store:get_areas_for_pos(pos)) do
			if region_id then
				if pos_has_regions == false then
					pos_has_regions = true
					hud_stringtext = ""
				end
				-- get region_data as table
				local data_table = raz:get_region_datatable(region_id)
				local region_name = data_table.region_name
				local owner = data_table.owner

				-- is this region protected?
				if data_table.protected then
					protected = true
					protected_string = " (protected) "
				else
					protected_string = ""
				end 

				-- PvP - is pvp_only_in_pvp_regions = true
				-- then PvP is only allowed in PvP-zones. 
				-- is PvP allowed in one area at this Position PvP is allowed in all. 
				-- mark this area as PvP
				if data_table.PvP and raz.pvp_only_in_pvp_regions then
					PvP = true
					PvP_string = " (PvP) "
				end
			 	if data_table.PvP == false and raz.pvp_only_in_pvp_regions then
					PvP_string = ""
				end 
				-- PvP - is pvp_only_in_pvp_regions = false
				-- then PvP is allowed everyther. 
				-- is PvP = fales in one area at this Position PvP is forbidden in all. 
				-- mark this area as PvP
				if data_table.PvP and raz.pvp_only_in_pvp_regions == false then
					PvP_string = " (PvP) "
				end
			 	if data_table.PvP == false and raz.pvp_only_in_pvp_regions  == false then
					PvP = false
					PvP_string = ""
				end 

				-- has the region an effect
				effect = data_table.effect
				if effect ~= "none" or effect ~=nil then
					--minetest.log("action", "[" .. raz.modname .. "] player in effect-zone ".. tostring(effect))
					is_effect = true
					table.insert(effects, effect)
				end
				local string = "\nZone ("..region_id.."): >"..region_name.."< owned by "..owner.."! "..protected_string..PvP_string

				hud_stringtext = hud_stringtext..string
			end
		end
		-- update the hud

		if protected then
			color = raz.color["blue"]
		end
		if PvP then
			color = raz.color["red"]
		end
		if protected and PvP then
			color = raz.color["purple"]
		end
		if is_effect then
			color = raz.color["orange"]
		end


		raz:update_hud(player,hud_stringtext, color)

		-- do region effect
		if is_effect and timer >= raz.effect.time then
			raz:do_effect_to_player(player,effects)
			timer = 0
		end

	end
end)
