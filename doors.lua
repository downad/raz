--[[
-- inspired by landrush
if minetest.get_modpath("doors") then
	function raz:protect_against_door(door)
		local definition = minetest.registered_items[door]
		--local on_place = definition.on_place
		function definition.on_place(itemstack, placer, pointed_thing)
			local bottom = pointed_thing.above
			local top = {x=pointed_thing.above.x, y=pointed_thing.above.y+1, z=pointed_thing.above.z}
			local name = placer:get_player_name()
			
			-- can name interact in top and bottom?
			if raz:can_interact(top,name) and raz:can_interact(bottom, name) then
				return on_place(itemstack, placer, pointed_thing)
			else
				topowner = raz:get_owner_for_pos(top)  			-- strings, if there are more than 1 owner ',' separeates the names
				bottomowner = raz:get_owner_for_pos(bottom)		-- strings, if there are more than 1 owner ',' separeates the names
				--if topowner and bottomowner and topowner ~= bottomowner then
					minetest.chat_send_player(name, "Area owned by "..topowner.." and "..bottomowner)
				--elseif topowner then
				--	minetest.chat_send_player(name, "Area owned by "..topowner)
				--else
				--	minetest.chat_send_player(name, "Area owned by "..bottomowner)
				--end
			end
		end
	end

	raz:protect_against_door("doors:door_wood")
	raz:protect_against_door("doors:door_steel")
end

function raz:can_dig_door(pos, digger)
	local digger_name = digger and digger:get_player_name()
	if digger_name and minetest.get_player_privs(digger_name).protection_bypass then
		return true
	end
	return minetest.get_meta(pos):get_string("doors_owner") == digger_name
end

]]--
--doors:door_steel
--doors:door_wood
--doors:trapdoor_steel
--castle_gates:jail_door
--castle_gates:oak_door

local old_node_dig = minetest.node_dig
function minetest.node_dig(pos, node, digger)
	local name = digger:get_player_name()
	if not raz:can_interact(pos, name) then
		minetest.chat_send_player(name, "This area is protected by "..raz:get_owner_for_pos(pos))
		return	
	else
		return old_node_dig(pos, node, digger)
	end
end
