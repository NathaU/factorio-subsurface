miner_names = {
	"vehicle-miner", "vehicle-miner-mk2", "vehicle-miner-mk3", "vehicle-miner-mk4", "vehicle-miner-mk5",
	"vehicle-miner-0", "vehicle-miner-mk2-0", "vehicle-miner-mk3-0", "vehicle-miner-mk4-0", "vehicle-miner-mk5-0",
	"vehicle-miner-0-_-ghost", "vehicle-miner-mk2-0-_-ghost", "vehicle-miner-mk3-0-_-ghost", "vehicle-miner-mk4-0-_-ghost", "vehicle-miner-mk5-0-_-ghost",
	"vehicle-miner-0-_-solid", "vehicle-miner-mk2-0-_-solid", "vehicle-miner-mk3-0-_-solid", "vehicle-miner-mk4-0-_-solid", "vehicle-miner-mk5-0-_-solid"
}

-- AAI miner gui
script.on_event({defines.events.on_player_cursor_stack_changed, defines.events.on_player_changed_surface}, function(event)
	local player = game.get_player(event.player_index)
	local surface = player.surface
	if player.gui.left.aai_gui ~= nil then player.gui.left.aai_gui.destroy() end
	if player.cursor_stack.valid_for_read and player.cursor_stack.name == "unit-remote-control" and is_subsurface(surface) then
		local miners = surface.find_entities_filtered{name=miner_names, force=player.force}
		if #miners > 0 then
			
			local paths = remote.call("aai-programmable-vehicles", "get_surface_paths", {surface_index=surface.index, force_name=player.force.name})
			local path_names = {"None"}
			for _,p in ipairs(paths or {}) do
				path_names[p.path_id + 1] = p.path_id .. ": " .. p.name
			end
			
			local miner_list = player.gui.left.add{
				type = "scroll-pane",
				name = "aai_gui",
				direction = "vertical",
				style = "aai_vehicles_units-scroll-pane"
			}
			for _,miner in ipairs(miners) do
				local miner_data = remote.call("aai-programmable-vehicles", "get_unit_by_entity", miner)
				local frame = miner_list.add{
					type = "frame",
					name = miner_data.unit_id,
					direction = "horizontal",
					style = "aai_vehicles_unit-frame"
				}
				frame.add{type="sprite", sprite="entity/"..miner_data.unit_type}
				frame.add{type="label", caption=miner_data.unit_id, style="aai_vehicles_unit-number-label"}
				frame.add{type="drop-down", name="miner_path", tags={unit_id=miner_data.unit_id}, items=path_names, selected_index=(global.aai_miner_paths[miner_data.unit_id] or {0, 0})[1] + 1}
			end
		end
	end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
	if event.element.name == "miner_path" then
		local unit_id = event.element.tags.unit_id
		if event.element.selected_index == 1 then
			global.aai_miner_paths[unit_id] = {0, 0}
		else
			global.aai_miner_paths[unit_id] = {event.element.selected_index - 1, remote.call("aai-programmable-vehicles", "get_surface_paths", {surface_index=game.get_player(event.player_index).surface.index, force_name=game.get_player(event.player_index).force.name})[event.element.selected_index - 1].first_waypoint_id}
		end
	end
end)

function handle_miners(tick)
	for _,subsurface in ipairs(global.subsurfaces) do
		for _,miner in ipairs(subsurface.find_entities_filtered{name=miner_names}) do
			
			-- navigation part
			local miner_data = remote.call("aai-programmable-vehicles", "get_unit_by_entity", miner)
			local path = nil
			if global.aai_miner_paths[miner_data.unit_id] and global.aai_miner_paths[miner_data.unit_id][1] > 0 then
				path = remote.call("aai-programmable-vehicles", "get_surface_paths", {surface_index=subsurface.index, force_name=miner.force.name})[global.aai_miner_paths[miner_data.unit_id][1]]
			end
			
			if path then
				local target_position = path.waypoints[global.aai_miner_paths[miner_data.unit_id][2]].position -- position of next waypoint
				if miner_data.mode == "unit" and miner_data.speed == 0 then -- miner has no path (stucked)
					for _,p in ipairs(miner.force.players) do
						if tick % 180 == 0 then p.add_custom_alert(miner, {type="item", name=miner_data.unit_type}, {"subsurface.miner-stuck"}, true) end
					end
				elseif miner_data.mode == "vehicle" and not miner_data.vehicle.get_inventory(defines.inventory.car_trunk).is_full() then
					if miner.position.x - 2 < target_position.x and miner.position.x + 2 > target_position.x and miner.position.y - 2 < target_position.y and miner.position.y + 2 > target_position.y then
						local next_waypoint = path.first_waypoint_id
						for i,w in pairs(path.waypoints) do
							if next_waypoint == path.first_waypoint_id and i > global.aai_miner_paths[miner_data.unit_id][2] and path.waypoints[i] and path.waypoints[i].type == "position" then
								next_waypoint = i
							end
						end
						global.aai_miner_paths[miner_data.unit_id][2] = next_waypoint
					end
					remote.call("aai-programmable-vehicles", "set_unit_command", {unit_id=miner_data.unit_id, target_position_direct=path.waypoints[global.aai_miner_paths[miner_data.unit_id][2]].position})
				elseif miner_data.vehicle.get_inventory(defines.inventory.car_trunk).is_full() then
					for _,p in ipairs(miner.force.players) do
						if tick % 180 == 0 then p.add_custom_alert(miner, {type="item", name=miner_data.unit_type}, {"subsurface.miner-inventory-full"}, true) end
					end
					remote.call("aai-programmable-vehicles", "set_unit_command", {unit_id=miner_data.unit_id, target_speed=0})
				end
			else
				global.aai_miner_paths[miner_data.unit_id] = {0, 0}
			end
			
			if miner.valid and miner.speed > 0 then -- digging part
				local orientation = miner.orientation
				local miner_collision_box = miner.prototype.collision_box
				local center_big_excavation = move_towards_continuous(miner.position, orientation, -miner_collision_box.left_top.y)
				local center_small_excavation = move_towards_continuous(center_big_excavation, orientation, 1.7)
				local speed_test_position = center_big_excavation --move_towards_continuous(center_small_excavation, orientation, 1.5)
				
				local walls_dug = clear_subsurface(subsurface, center_small_excavation, 1, nil)
				walls_dug = walls_dug + clear_subsurface(subsurface, center_big_excavation, 3, nil)
				
				if walls_dug > 0 then
					local stack = {name = "stone", count = 20 * walls_dug}
					local actually_inserted = miner.insert(stack)
					if actually_inserted ~= stack.count then
						stack.count = stack.count - actually_inserted
						subsurface.spill_item_stack(miner.position, stack)
					end
				end

				local speed_test_tile = subsurface.get_tile(speed_test_position.x, speed_test_position.y)
				if miner.speed > 0 and speed_test_tile.name == "out-of-map" then
					miner.friction_modifier = 50
				elseif not(miner.speed > 0 and speed_test_tile.name == "out-of-map") then
					miner.friction_modifier = 1
				end
			end
		end
	end
end
