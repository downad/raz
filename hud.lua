
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
				offset        = {x = 10,   y = 0},
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
