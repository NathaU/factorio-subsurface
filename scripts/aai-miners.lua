miner_names = {
	"vehicle-miner", "vehicle-miner-mk2", "vehicle-miner-mk3", "vehicle-miner-mk4", "vehicle-miner-mk5",
	"vehicle-miner-0", "vehicle-miner-mk2-0", "vehicle-miner-mk3-0", "vehicle-miner-mk4-0", "vehicle-miner-mk5-0",
	"vehicle-miner-0-_-ghost", "vehicle-miner-mk2-0-_-ghost", "vehicle-miner-mk3-0-_-ghost", "vehicle-miner-mk4-0-_-ghost", "vehicle-miner-mk5-0-_-ghost",
	"vehicle-miner-0-_-solid", "vehicle-miner-mk2-0-_-solid", "vehicle-miner-mk3-0-_-solid", "vehicle-miner-mk4-0-_-solid", "vehicle-miner-mk5-0-_-solid"
}
ai_miner_names = {
	["vehicle-miner-0"] = 1, ["vehicle-miner-mk2-0"] = 1, ["vehicle-miner-mk3-0"] = 1, ["vehicle-miner-mk4-0"] = 1, ["vehicle-miner-mk5-0"] = 1
}
non_ai_miner_names = {"vehicle-miner", "vehicle-miner-mk2", "vehicle-miner-mk3", "vehicle-miner-mk4", "vehicle-miner-mk5"}
non_ai_miner_names_k = {["vehicle-miner"] = 1, ["vehicle-miner-mk2"] = 1, ["vehicle-miner-mk3"] = 1, ["vehicle-miner-mk4"] = 1, ["vehicle-miner-mk5"] = 1}

script.on_event(defines.events.on_player_selected_area, function(event)
	local player = game.get_player(event.player_index)
	if is_subsurface(event.surface) and player.gui.left.remote_selected_units then -- unit remote was used, it now shows selected units
		local all_units = remote.call("aai-programmable-vehicles", "get_units")
		
		for _, frame in pairs(player.gui.left.remote_selected_units.remote_selected_units_frame.remote_selected_units_scroll.children) do
			local unit_id = tonumber(frame.name)
			if ai_miner_names[all_units[unit_id].unit_type] then
				local digging_button = frame.add{
                    type = "sprite-button", style = "aai_vehicles_unit-button-fixed",
                    name = "unit_digging",
                    sprite = "entity/subsurface-wall",
                    tooltip = {"subsurface.unit_digging"},
					auto_toggle = true
                }
				digging_button.toggled = storage.aai_digging_miners[unit_id] ~= nil
			end
		end
	end
end)
function aai_on_gui_click(event)
	if event.element.toggled then
		storage.aai_digging_miners[tonumber(event.element.parent.name)] = {}
	else
		storage.aai_digging_miners[tonumber(event.element.parent.name)] = nil
	end
end

function aai_on_unit_change_mode(unit, new_mode, old_mode)
	if storage.aai_digging_miners[unit.unit_id] then
		if new_mode == "unit" then -- when "unit" and path exists, it arrived at the first waypoint to follow the path
			if unit.path then
				storage.aai_digging_miners[unit.unit_id] = {unit.path.path_id, unit.path.waypoint_id} -- waypoint_id is the next waypoint
				local path = remote.call("aai-programmable-vehicles", "get_surface_paths", {surface_index = unit.surface_index, force_name = unit.vehicle.force.name})[unit.path.path_id]
				if path.waypoints[unit.path.waypoint_id].type == "position" then
					remote.call("aai-programmable-vehicles", "set_unit_command", {unit_id = unit.unit_id, target_speed = 0})
					remote.call("aai-programmable-vehicles", "set_unit_command", {unit_id = unit.unit_id, target_position_direct = path.waypoints[unit.path.waypoint_id].position})
				end
			else
				storage.aai_digging_miners[unit.unit_id] = {}
			end
		elseif new_mode == "vehicle" and storage.aai_digging_miners[unit.unit_id][1] or 0 > 0 then -- when mode is "vehicle", then it may have arrived at the target position
			local path = remote.call("aai-programmable-vehicles", "get_surface_paths", {surface_index = unit.surface_index, force_name = unit.vehicle.force.name})[storage.aai_digging_miners[unit.unit_id][1]]
			if math2d.position.distance(unit.vehicle.position, path.waypoints[storage.aai_digging_miners[unit.unit_id][2]].position) < 1 then
				local next_waypoint = path.first_waypoint_id
				for i, _ in pairs(path.waypoints) do
					if next_waypoint == path.first_waypoint_id and i > storage.aai_digging_miners[unit.unit_id][2] and path.waypoints[i] and path.waypoints[i].type == "position" then
						next_waypoint = i -- take the first waypoint after the current one that is a position
					end
				end
				storage.aai_digging_miners[unit.unit_id][2] = next_waypoint
			end
			remote.call("aai-programmable-vehicles", "set_unit_command", {unit_id = unit.unit_id, target_position_direct = path.waypoints[storage.aai_digging_miners[unit.unit_id][2]].position})
		end
	end
end

function aai_on_unit_given_order(unit, order)
	if order.target_position and storage.aai_digging_miners[unit.unit_id] then
		remote.call("aai-programmable-vehicles", "set_unit_command", {unit_id = unit.unit_id, target_speed = 0})
		remote.call("aai-programmable-vehicles", "set_unit_command", {unit_id = unit.unit_id, target_position_direct = order.target_position})
	end
end

function handle_miners(tick)
	local miners = non_ai_miner_names
	if remote.interfaces["aai-programmable-vehicles"] then miners = miner_names end
	for _, subsurface in pairs(storage.subsurfaces) do
		for _, miner in ipairs(subsurface.find_entities_filtered{name = miners}) do
			
			if not non_ai_miner_names_k[miner.name] then -- navigation part
				local unit = remote.call("aai-programmable-vehicles", "get_unit_by_entity", miner)
				
				if unit.vehicle.get_inventory(defines.inventory.car_trunk).is_full() then
					for _, p in ipairs(miner.force.connected_players) do
						if tick % 180 == 0 then p.add_custom_alert(miner, {type = "item", name = unit.unit_type}, {"subsurface.miner-inventory-full"}, true) end
						if tick % 300 == 0 then p.create_local_flying_text{text = {"subsurface.miner-inventory-full"}, position = miner.position, time_to_live = 75} end
					end
					remote.call("aai-programmable-vehicles", "set_unit_command", {unit_id = unit.unit_id, target_speed = 0})
				end
			end
			
			if miner.valid and miner.speed ~= 0 then -- digging part
				local orientation = miner.orientation
				local miner_collision_box = miner.prototype.collision_box
				local center_big_excavation = math2d.position.add(miner.position, math2d.vector.from_orientation(orientation, -miner_collision_box.left_top.y))
				local center_small_excavation = math2d.position.add(center_big_excavation, math2d.vector.from_orientation(orientation, 1.5))
				local speed_test_position = math2d.position.add(center_small_excavation, math2d.vector.from_orientation(orientation, 1.6))
				
				local inv_1 = clear_subsurface(subsurface, center_small_excavation, 1, nil, true)
				local inv_2 = clear_subsurface(subsurface, center_big_excavation, 3, nil, true)
				
				if not inv_1.is_empty() or not inv_2.is_empty() then
					for _, inv in ipairs({inv_1, inv_2}) do
						for _, v in ipairs(inv.get_contents()) do
							local actually_inserted = miner.insert(v)
							if actually_inserted ~= v.count then
								v.count = v.count - actually_inserted
								subsurface.spill_item_stack{position = miner.position, stack = v}
							end
						end
					end
					
					subsurface.pollute(center_small_excavation, (inv_1.get_item_count() + inv_2.get_item_count()) * 0.01, miner.name)
					subsurface.create_trivial_smoke{name = "fire-smoke-without-glow", position = speed_test_position}
					subsurface.create_trivial_smoke{name = "fire-smoke-without-glow", position = speed_test_position}
					subsurface.create_trivial_smoke{name = "fire-smoke-without-glow", position = speed_test_position}
				end
				
				inv_1.destroy()
				inv_2.destroy()
				
				if miner.speed > 0 and subsurface.find_entities_filtered{name = subsurface_wall_names, position = speed_test_position}[1] then
					miner.friction_modifier = 7
				else
					miner.friction_modifier = 1
				end
			end
		end
	end
end
