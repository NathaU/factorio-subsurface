function cutscene_on_player_driving_changed_state(event)
	if event.entity and storage.tunnel_links[event.entity.unit_number] then
		local player = game.get_player(event.player_index)
		local waypoints = {{position = event.entity.position, transition_time = 30, time_to_wait = 0}}
		player.set_controller{type = defines.controllers.cutscene, waypoints = waypoints}
	end
end

script.on_event(defines.events.on_cutscene_finished, function(event)
	local player = game.get_player(event.player_index)
	if player.vehicle and (player.vehicle.name == "tunnel-entrance" or player.vehicle.name == "tunnel-exit") then -- if this is the first part of the whole cutscene
		local endpoint_name = player.vehicle.name
		player.teleport({player.position.x, player.position.y + 1.1}, storage.tunnel_links[player.vehicle.unit_number].surface)
		local start = player.position
		if endpoint_name == "tunnel-entrance" then
			start.y = start.y - 2
		else
			start.y = start.y + 2
		end
		player.set_controller{type = defines.controllers.cutscene, waypoints = {{position = player.position, transition_time = 30, time_to_wait = 0}}, start_position = start}
		if remote.interfaces["jetpack"] then
			if is_subsurface(player.surface) then remote.call("jetpack", "block_jetpack", {character = player.cutscene_character})
			else remote.call("jetpack", "unblock_jetpack", {character = player.cutscene_character}) end
		end
		player.force.script_trigger_research("subsurface-exploration")
	end

	elevator_on_cursor_stack_changed(player)
end)

script.on_event("subsurface-driving", function(event)
	local player = game.get_player(event.player_index)
	if player.selected and (player.selected.name == "tunnel-entrance-cable" or player.selected.name == "tunnel-exit-cable") and player.controller_type ~= defines.controllers.character and player.controller_type ~= defines.controllers.cutscene and player.controller_type ~= defines.controllers.remote then
		player.teleport({player.position.x, player.position.y + 1.1}, storage.tunnel_links[player.selected.unit_number].surface)
	end
end)
