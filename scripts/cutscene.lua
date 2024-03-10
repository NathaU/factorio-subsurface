script.on_event(defines.events.on_player_driving_changed_state, function(event)
	if event.entity and global.car_links[event.entity.unit_number] then
		local player = game.get_player(event.player_index)
		local waypoints = {{position=event.entity.position, transition_time=30, time_to_wait=0}}
		if event.entity.name == "tunnel-entrance" then
			waypoints[1].position.y = waypoints[1].position.y + 2
		elseif event.entity.name == "tunnel-exit" then
			waypoints[1].position.y = waypoints[1].position.y - 2
		end
		player.set_controller{type=defines.controllers.cutscene, waypoints=waypoints}
	end
end)

script.on_event(defines.events.on_cutscene_waypoint_reached, function(event)
	local player = game.get_player(event.player_index)
	if event.waypoint_index == 0 and player.cutscene_character.vehicle then -- if this is the first part of the whole cutscene
		player.exit_cutscene()
		local name = player.vehicle.name
		local start = player.position
		player.teleport({start.x, start.y + 1}, global.car_links[player.vehicle.unit_number].surface) -- one tile below entity to not get stuck
		if name == "tunnel-entrance" then
			start.y = start.y - 2
		else
			start.y = start.y + 2
		end
		player.set_controller{type=defines.controllers.cutscene, waypoints={{position=player.position, transition_time=30, time_to_wait=0}}, start_position=start}
	end
end)
