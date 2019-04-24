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
--register items and enitiy
-- got this from https://github.com/Bremaweb/landrush
-- textures and model from Bremaweb/landrush
-- This is a fork of 0gb.us' landclaim mod http://forum.minetest.net/viewtopic.php?id=3679.
-- made it workable with raz by downad 

minetest.register_node("raz:landclaim", {
	description = "Land Rush Land Claim",
	tiles = {"landrush_landclaim.png"},
	groups = {oddly_breakable_by_hand=2},
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local owner = raz:get_owner_for_pos(pos)
		local name = placer:get_player_name()

		if name:find("[gG]uest") then
			minetest.chat_send_player(name,"Guests cannot claim land")
			return itemstack
		end
		
		if ( pointed_thing.above.y < -200 ) then
			minetest.chat_send_player(name,"You cannot claim below -200")
			return itemstack
		end
		
		if owner then
			minetest.chat_send_player(name, "This area is already owned by "..owner)
		else
			minetest.env:remove_node(pointed_thing.above)
			minetest.chat_send_player(name, "raz:landclaim pos = "..minetest.serialize(pointed_thing.above) )
			-- if correct privileg
			-- if plot / city/plot
			-- mark region with
			-- 		region_name = owner
			--		protected = true
			-- 	edges depending on pointed_thing.above
			local pos1, pos2 = raz:create_landrush_edges(pos) 
			local can_add = raz:player_can_mark_region(pos1, pos2, name)
			minetest.log("action", "[" .. raz.modname .. "] register_node(raz:landclaim) can_add = "..tostring(can_add) )
			if can_add == true then
				--			 raz:create_data(owner,region_name,protected,guests_string,PvP,MvP,effect,plot,city,do_not_check_player)
				local data = raz:create_data(name,name,true )
				local err = raz:set_region(pos1,pos2,data)
			end

			itemstack:take_item()
			return itemstack
		end
	end,
})

minetest.register_craft({
			output = 'raz:landclaim',
			recipe = {
				{'default:stone','default:steel_ingot','default:stone'},
				{'default:steel_ingot','default:mese_crystal','default:steel_ingot'},
				{'default:stone','default:steel_ingot','default:stone'}
			}
		})
minetest.register_alias("landclaim", "raz:landclaim")


minetest.register_entity("raz:showarea",{
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(16,function()
			self.object:remove()
		end)
	end,
	initial_properties = {
		hp_max = 1,
		physical = true,
		weight = 0,
		visual = "mesh",
		mesh = "landrush_showarea.x",
		textures = {nil, nil, "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png", "landrush_showarea.png"}, -- number of required textures depends on visual
		colors = {}, -- number of required colors depends on visual
		spritediv = {x=1, y=1},
		initial_sprite_basepos = {x=0, y=0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = false,
	}
})



