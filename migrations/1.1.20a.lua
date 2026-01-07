-- Selection indicators
for i, p in pairs(storage.selection_indicators) do
	for j = #p, 1, -1 do
		storage.selection_indicators[i][j].destroy()
	end
end
storage.selection_indicators = {}
for _, s in pairs(game.surfaces) do
	local elevator_names = get_item_elevator_names()
	table.insert(elevator_names, "subway")
	table.insert(elevator_names, "heat-elevator")
	table.insert(elevator_names, "fluid-elevator-input")
	table.insert(elevator_names, "fluid-elevator-output")
	for _, entity in pairs(s.find_entities_filtered{name = elevator_names}) do
		local endpoint = get_linked_entity(entity)
		if endpoint then
			local offs = 0 -- line offset, when 0 then don't show indicators
			local orien = 0 -- arrow orientation (0 is arrow pointing north)
			if is_item_elevator(entity.name) then
				if endpoint.surface == get_subsurface(entity.surface, false) then -- selected entity is top
					offs = -0.3
					if entity.linked_belt_type == "input" then orien = 0.5 end
				else offs = 0.3
					if entity.linked_belt_type == "output" then orien = 0.5 end
				end
			elseif entity.name == "fluid-elevator-input" or entity.name == "fluid-elevator-output" then
				if endpoint.surface == get_subsurface(entity.surface, false) then -- selected entity is top
					offs = -0.3
					if entity.fluidbox.get_pipe_connections(1)[1].flow_direction == "input" then orien = 0.5 end
				else
					offs = 0.3
					if entity.fluidbox.get_pipe_connections(1)[1].flow_direction == "output" then orien = 0.5 end
				end
			elseif entity.name == "heat-elevator" then
				storage.selection_indicators[entity.unit_number] = {rendering.draw_sprite{sprite = "utility/indication_arrow", surface = entity.surface, target = entity, orientation = endpoint.surface == get_subsurface(entity.surface, false) and 0.5 or 0, visible = false}}
			elseif entity.name == "subway" then
				storage.selection_indicators[entity.unit_number] = {rendering.draw_sprite{sprite = "utility/indication_arrow", surface = entity.surface, target = entity, orientation = endpoint.surface == get_subsurface(entity.surface, false) and 0.5 or 0, visible = false}}
			end
			if offs ~= 0 then
				storage.selection_indicators[entity.unit_number] = {rendering.draw_sprite{sprite = "utility/indication_line", surface = entity.surface, target = {entity = entity, offset = {0, offs}}, visible = false}, rendering.draw_sprite{sprite = "utility/indication_arrow", surface = entity.surface, target = entity, orientation = orien, visible = false}}
			end
		end
	end

	if is_subsurface(s) then
		for _, f in pairs(game.forces) do
			s.set_default_cover_tile(f, "out-of-map", "caveground")

			for x, ydata in pairs((storage.deconstruction_queue[f.name] or {})[s.index] or {}) do
				for y, r in pairs(ydata) do
					r[1].destroy()
					r[2].destroy()
					s.create_entity{name = "tile-ghost", inner_name = "caveground", position = {x, y}, force = f}
				end
			end
		end
	end
end
storage.deconstruction_queue = nil
