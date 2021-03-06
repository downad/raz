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
-- do an / all effect to player
--
--+++++++++++++++++++++++++++++++++++++++
-- input: 
--		player 		as object player
--		effect 		as string
-- get the data field attributes owner of a given posision 
-- msg/error handling: no 
function raz:do_effect_to_player(player,effects)
	local hot_done = false 		-- hot: heal over time 
	local fot_done = false		-- fot: feed over time
	local bot_done = false		-- bot: breath ober time
	local holy_done = false		-- holy: heal, feed an breath over time
	local dot_done = false		-- dot: damage over time
	local starve_done = false	-- starve: reduce food over time
	local choke_done = false	-- choke: reduce breath over time
	local evil_done = false		-- evil: steals food, blood, breath over time
	-- loop effects
	for k,v in pairs(effects) do
		if v == "hot" and hot_done == false then
			hot_done = raz:do_effect_hot(player)
		end
		if v == "bot" and bot_done == false then
			bot_done = raz:do_effect_bot(player)
		end
		if v == "holy" and holy_done == false then
			holy_done = raz:do_effect_holy(player)
		end
		if v == "dot" and dot_done == false then
			dot_done = raz:do_effect_dot(player)
		end
		if v == "choke" and choke_done == false then
			choke_done = raz:do_effect_choke(player)
		end
		if v == "evil" and evil_done == false then
			evil_done = raz:do_effect_evil(player)
		end
	end
end

-- deal the effects
-- hot - heal over time
function raz:do_effect_hot(player)
	if player:get_hp() < 20 then
		player:set_hp(math.max(player:get_hp() + raz.effect.hot, 0))
		minetest.chat_send_player(player:get_player_name(), "The region regenerate you with "..raz.effect.hot.." life!")
	else
		--minetest.chat_send_player(player:get_player_name(), "Here you healed!")
	end
	return true
end

-- bot - breath over time
function raz:do_effect_bot(player)
	if player:get_breath() < 11 then
		player:set_breath(math.max(player:get_breath() + raz.effect.bot, 0))
		minetest.chat_send_player(player:get_player_name(), "The region gives you "..raz.effect.bot.." breath!")
	end
		--minetest.chat_send_player(player:get_player_name(), "Your are full of air.")
	return true
end

-- holy - the effect of hot and bot and fot
function raz:do_effect_holy(player)
	local done = ""
		done = raz:do_effect_hot(player)
		done = raz:do_effect_bot(player)
		minetest.chat_send_player(player:get_player_name(), "This is an holy region!")
	return true
end

-- dot - damage over time
function raz:do_effect_dot(player)
		player:set_hp(math.max(player:get_hp() - raz.effect.dot, 0))
		minetest.chat_send_player(player:get_player_name(), "You get "..raz.effect.dot.." damage in this region!")
	return true
end

-- choke
function raz:do_effect_choke(player)
		player:set_breath(math.max(player:get_breath() - raz.effect.choke, 0))
		minetest.chat_send_player(player:get_player_name(), "The region steels you "..raz.effect.choke.." breath!")
	return true
end

-- evil - the effect of dot and choke
function raz:do_effect_evil(player)
	local done = ""
		done = raz:do_effect_dot(player)
		done = raz:do_effect_choke(player)
		minetest.chat_send_player(player:get_player_name(), "This is an evil region!")
	return true
end
