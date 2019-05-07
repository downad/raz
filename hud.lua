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
-- raz:update_hud(player, hud_stringtext, color)
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		player			as playerobject
--		hud_stingtext 	as string
--		color 			as string
-- ids = hud-id   
-- msg/error handling: no 
-- return owner 	as string
function raz:update_hud(player, hud_stringtext, color)
    local name = player:get_player_name()
    local ids = raz.player_huds[name]
    if ids then
		player:hud_change(ids, "text", hud_stringtext)
		player:hud_change(ids, "number", color)
    else
        ids = {}
        ids = player:hud_add({
				hud_elem_type = "text",
				name = "Areas",
				number = 0xFFFFFF,
				position      = {x = 0, y = 0.85},
				offset        = {x = 10,   y = 10},
				--position = {x=0, y=1},
				--offset = {x=8, y=-8},
				text = hud_stringtext,
				scale = {x=200, y=60},
				alignment = {x=1, y=-1},
			})
		raz.player_huds[name] = ids
    end
end

-- when a player joins the game
minetest.register_on_joinplayer(function(player)
    raz:update_hud(player, raz.default.hud_stringtext, raz.color.white)
end)

-- when player leaves the game
minetest.register_on_leaveplayer(function(player)
    raz.player_huds[player:get_player_name()] = nil
end)
