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
--+++++++++++++++++++++++++++++++++++++++
--
-- Globalstep: create info for the hud
--
--+++++++++++++++++++++++++++++++++++++++
-- loop all connected player
-- find the region of the players position -> get_areas_for_pos
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
		local hud_stringtext = "" --"wilderness"
		if raz.pvp_only_in_pvp_regions then
			hud_stringtext = raz.default.hud_stringtext
		elseif raz.enable_pvp then	
			hud_stringtext = raz.default.hud_stringtext_pvp
			PvP = true
		end

		--   attributes are: region_name, owner, protected, guests, PvP, MvP, effect 
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

				-- region_name
				local region_name = data_table.region_name

				-- owner
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
				-- is PvP allowed in one area at this position PvP is allowed in all. 
				-- mark this zone as PvP
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
				-- mark this zone as PvP
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
