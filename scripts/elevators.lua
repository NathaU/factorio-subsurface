function is_item_elevator(name)
	return string.sub(name, 1, 13) == "item-elevator"
end
function is_fluid_elevator(name)
	return string.sub(name, 1, 14) == "fluid-elevator"
end

function get_item_elevator_names()
	local tbl = {}
	local i = 1
	while prototypes.entity["item-elevator-"..i] do
		table.insert(tbl, "item-elevator-"..i)
		i = i + 1
	end
	return tbl
end

function switch_elevator(entity) -- switch between input and output
	if is_item_elevator(entity.name == "entity-ghost" and entity.ghost_name or entity.name) then
		if entity.linked_belt_type == "input" then
			entity.linked_belt_type = "output"
		else
			entity.linked_belt_type = "input"
		end
		storage.selection_indicators[entity.unit_number][2].orientation = (storage.selection_indicators[entity.unit_number][2].orientation + 0.5) % 1
	elseif string.sub(entity.name, 1, 14) == "fluid-elevator" then
		local new_name = "fluid-elevator-input"
		if entity.name == "fluid-elevator-input" then new_name = "fluid-elevator-output" end
		
		local new_endpoint = entity.surface.create_entity{name = new_name, position = entity.position, direction = entity.direction, force = entity.force, player = entity.last_user, quality = entity.quality}
		new_endpoint.fluidbox[1] = entity.fluidbox[1]

		if storage.selection_indicators[entity.unit_number] then
			storage.selection_indicators[new_endpoint.unit_number] = storage.selection_indicators[entity.unit_number]
			storage.selection_indicators[new_endpoint.unit_number][1].target = {entity = new_endpoint, offset = storage.selection_indicators[entity.unit_number][1].target.offset}
			storage.selection_indicators[new_endpoint.unit_number][2].target = new_endpoint
			storage.selection_indicators[new_endpoint.unit_number][2].orientation = (storage.selection_indicators[new_endpoint.unit_number][2].orientation + 0.5) % 1
		end
		entity.destroy()
		
		return new_endpoint
	end
end

function get_linked_entity(entity)
	if is_item_elevator(entity.name) then
		return entity.linked_belt_neighbour
	elseif is_fluid_elevator(entity.name) then
		return entity.fluidbox.get_linked_connection(1)
	elseif entity.name == "heat-elevator" then
		for _, v in ipairs(storage.heat_elevators) do
			if v[1] == entity then return v[2]
			elseif v[2] == entity then return v[1] end
		end
	elseif entity.name == "subway" then
		return storage.train_subways[entity.unit_number].connection
	end
	return nil
end

function handle_elevators(tick)
	
	-- heat elevators
	if tick % 30 == 0 then
		for i, elevators in ipairs(storage.heat_elevators) do  -- average heat between input and output
			if not(elevators[1].valid and elevators[2].valid) then table.remove(storage.heat_elevators, i)
			else
				
				local t1 = elevators[1].temperature
				local t2 = elevators[2].temperature
				if math.abs(t1 - t2) > 5 then -- difference need to be greater that 5 degree, which is equivalent to 5 heat pipes between them
					local transfer = math.min(math.abs(t1 - t2) - 5, 100) -- max transfer is 100°C (1GW is 500MJ per 0.5s)
					if t1 > t2 then
						elevators[1].temperature = t1 - transfer
						elevators[2].temperature = t2 + transfer
					else
						elevators[1].temperature = t1 + transfer
						elevators[2].temperature = t2 - transfer
					end
				end
			end
		end
	end
end

function show_placement_indicators(player, elevator_type)
	local entities = {}
	if elevator_type == 1 then entities = get_item_elevator_names()
	elseif elevator_type == 2 then entities = {"fluid-elevator-input", "fluid-elevator-output"}
	elseif elevator_type == 3 then entities = {"heat-elevator"}
	else entities = {"subway"}
	end
		
	local iter = {get_oversurface(player.surface), get_subsurface(player.surface, false)}
	for i = 1, 2 do
		if iter[i] then
			for _, e in ipairs(iter[i].find_entities_filtered{name = entities}) do
				if not get_linked_entity(e) then
					storage.placement_indicators[player.index] = storage.placement_indicators[player.index] or {}
					if elevator_type == 4 then
						subway_show_placement_indicators(player, e)
					else
						table.insert(storage.placement_indicators[player.index], rendering.draw_sprite{sprite = "placement-indicator-"..(elevator_type + (i - 1) * 3), surface = player.surface, x_scale = 0.3, y_scale = 0.3, target = e.position, players = {player}})
					end
				end
			end
		end
	end
end

function elevator_on_cursor_stack_changed(player)
	for _, r in ipairs(storage.placement_indicators[player.index] or {}) do r.destroy() end
	
	local item = false
	local fluid = false
	local heat = false
	local subway = false
			
	if player.is_cursor_blueprint() then
		local blueprint = player.cursor_record or player.cursor_stack
		if player.cursor_record then
			while blueprint and blueprint.type == "blueprint-book" do
				blueprint = blueprint.contents[blueprint.get_active_index(player)]
			end
			if not blueprint or blueprint.is_blueprint_preview then return end
		else
			while blueprint.is_blueprint_book do
				blueprint = blueprint.get_inventory(defines.inventory.item_main)[blueprint.active_index]
			end
		end
		
		for _, e in ipairs(blueprint.get_blueprint_entities() or {}) do
			if is_fluid_elevator(e.name) then fluid = true
			elseif is_item_elevator(e.name) then item = true
			elseif e.name == "heat-elevator" then heat = true
			end
		end
	elseif player.cursor_stack and player.cursor_stack.valid_for_read then
		if player.cursor_stack.name == "fluid-elevator" then fluid = true
		elseif is_item_elevator(player.cursor_stack.name) then item = true
		elseif player.cursor_stack.name == "heat-elevator" then heat = true
		elseif player.cursor_stack.name == "subway" then subway = true
		end
	end
	
	if item then show_placement_indicators(player, 1) end
	if fluid then show_placement_indicators(player, 2) end
	if heat then show_placement_indicators(player, 3) end
	if subway then show_placement_indicators(player, 4) end
end

function elevator_rotated(entity, previous_direction)
	if entity.name == "fluid-elevator-input" or entity.name == "fluid-elevator-output" then
		if entity.fluidbox.get_linked_connection(1) ~= nil then
			entity.direction = previous_direction
			local endpoint, _ = entity.fluidbox.get_linked_connection(1)
			entity = switch_elevator(entity)
			endpoint = switch_elevator(endpoint)
			entity.fluidbox.add_linked_connection(1, endpoint, 1)
		end
	elseif is_item_elevator(entity.name == "entity-ghost" and entity.ghost_name or entity.name) and entity.linked_belt_neighbour then
		local neighbour = entity.linked_belt_neighbour
		entity.disconnect_linked_belts()
		switch_elevator(entity)
		switch_elevator(neighbour)
		entity.connect_linked_belts(neighbour)
		entity.rotate{reverse = true}
	end
end

function elevator_built(entity)
	local iter = {get_oversurface(entity.surface), get_subsurface(entity.surface, false)}
	local name_filter = {}
	local direction_filter = {defines.direction.north, defines.direction.south, defines.direction.east, defines.direction.west}
	local offset = {0, 0}
	if is_item_elevator(entity.name) then name_filter = get_item_elevator_names()
	elseif is_fluid_elevator(entity.name) then name_filter = {"fluid-elevator-input", "fluid-elevator-output"}
	elseif entity.name == "heat-elevator" then name_filter = {"heat-elevator"}
	else
		name_filter = {"subway"}
		if entity.direction == defines.direction.north then
			offset = {0, -12}
			direction_filter = {defines.direction.south}
		elseif entity.direction == defines.direction.south then
			offset = {0, 12}
			direction_filter = {defines.direction.north}
		elseif entity.direction == defines.direction.east then
			offset = {14, 0}
			direction_filter = {defines.direction.west}
		else
			offset = {-14, 0}
			direction_filter = {defines.direction.east}
		end
	end
	for i = 1, 2 do
		if iter[i] then
			local e = iter[i].find_entities_filtered{name = name_filter, position = math2d.position.add(entity.position, offset), radius = 0.3, direction = direction_filter}[1]
			if e and not get_linked_entity(e) then
				local offs = 0 -- line offset, when 0 then don't show indicators
				local orien = 0 -- arrow orientation (0 is arrow pointing north)
				
				if entity.name == "fluid-elevator-input" then
					if e.name == "fluid-elevator-input" then
						entity = switch_elevator(entity) -- if both are input, switch last placed one to output
					end
					entity.fluidbox.add_linked_connection(1, e, 1)

					if i == 2 then -- built entity is top
						offs = -0.3
						orien = entity.name == "fluid-elevator-input" and 0.5 or 0
					else
						offs = 0.3
						orien = entity.name == "fluid-elevator-output" and 0.5 or 0
					end

				elseif entity.name == "fluid-elevator-output" then
					if e.name == "fluid-elevator-input" then
						entity.fluidbox.add_linked_connection(1, e, 1)
						if i == 2 then -- built entity is top
							offs = -0.3
						else
							offs = 0.3
							orien = 0.5
						end
					end
				elseif entity.name == "heat-elevator" then
					local top, bottom = entity, e
					if i == 1 then
						top = e
						bottom = entity
					end
					table.insert(storage.heat_elevators, {top, bottom})
					storage.selection_indicators[entity.unit_number] = {rendering.draw_sprite{sprite = "utility/indication_arrow", surface = entity.surface, target = entity, orientation = top == entity and 0.5 or 0, visible = false}}
					storage.selection_indicators[e.unit_number] = {rendering.draw_sprite{sprite = "utility/indication_arrow", surface = e.surface, target = e, orientation = top == e and 0.5 or 0, visible = false}}
				elseif entity.name == "subway" then
					subway_link(entity, e)
					storage.selection_indicators[entity.unit_number] = {rendering.draw_sprite{sprite = "utility/indication_arrow", surface = entity.surface, target = entity, orientation = i == 2 and 0.5 or 0, players = {}}}
					storage.selection_indicators[e.unit_number] = {rendering.draw_sprite{sprite = "utility/indication_arrow", surface = e.surface, target = e, orientation = i == 1 and 0.5 or 0, players = {}}}
				else
					if not entity.linked_belt_neighbour then
						if e.linked_belt_type == "input" then
							entity.linked_belt_type = "output"
						else
							entity.linked_belt_type = "input"
						end
						entity.connect_linked_belts(e)

						if i == 2 then -- built entity is top
							offs = -0.3
							orien = entity.linked_belt_type == "input" and 0.5 or 0
						else
							offs = 0.3
							orien = entity.linked_belt_type == "output" and 0.5 or 0
						end
					end
				end
				if offs ~= 0 then
					storage.selection_indicators[entity.unit_number] = {
						rendering.draw_sprite{sprite = "utility/indication_line", surface = entity.surface, target = {entity = entity, offset = {0, offs}}, visible = false},
						rendering.draw_sprite{sprite = "utility/indication_arrow", surface = entity.surface, target = entity, orientation = orien, visible = false}
					}
					storage.selection_indicators[e.unit_number] = {
						rendering.draw_sprite{sprite = "utility/indication_line", surface = e.surface, target = {entity = e, offset = {0, -offs}}, visible = false},
						rendering.draw_sprite{sprite = "utility/indication_arrow", surface = e.surface, target = e, orientation = orien, visible = false}
					}
				end
				break
			end
		end
	end
end

function elevator_removed(entity)
	local endpoint = get_linked_entity(entity)
	if endpoint then
		for _, r in ipairs(storage.selection_indicators[entity.unit_number]) do r.destroy() end
		for _, r in ipairs(storage.selection_indicators[endpoint.unit_number]) do r.destroy() end
		storage.selection_indicators[entity.unit_number] = nil
		storage.selection_indicators[endpoint.unit_number] = nil
	end
end

function elevator_unselected(player, entity)
	for _, r in ipairs(storage.selection_indicators[entity.unit_number] or {}) do
		local players = r.players or {}
		if players[1] == player then
			r.visible = false
			players = {}
		else
			for i, p in ipairs(players or {}) do
				if p == player then table.remove(players, i) end
			end
		end
		r.players = players
	end
end

function elevator_selected(player, entity)
	for _, r in ipairs(storage.selection_indicators[entity.unit_number] or {}) do
		r.visible = true
		if not r.players then r.players = {player}
		else table.insert(r.players, player) end
	end
end
