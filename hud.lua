
function raz:update_hud(player, hud_stringtext, color)
    local name = player:get_player_name()
	--minetest.log("action", "[" .. raz.modname .. "] playername: "..tostring(name))
    local ids = raz.player_huds[name]
	--minetest.log("action", "[" .. raz.modname .. "] ids: "..tostring(ids))
    if ids then
		--minetest.log("action", "[" .. raz.modname .. "] ids in if: "..tostring(ids))
		player:hud_change(ids, "text", hud_stringtext)
		player:hud_change(ids, "number", color)
		--minetest.chat_send_player(name, "update HuD")	
    else
        ids = {}
		--minetest.log("action", "[" .. raz.modname .. "] ids in else: "..tostring(ids))
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
		--minetest.chat_send_player(name, hud_stringtext)	
    end
end


--minetest.register_on_joinplayer(create_hud)

minetest.register_on_leaveplayer(function(player)
    raz.player_huds[player:get_player_name()] = nil
end)
