max_fluid_flow_per_tick = 100

function switch_elevator(entity) -- switch between input and output
	local is_fluid = false
	
	local new_name = "item-elevator-output"
	if entity.name == "item-elevator-output" then new_name = "item-elevator-input"
	elseif entity.name == "fluid-elevator-input" then
		new_name = "fluid-elevator-output"
		is_fluid = true
	elseif entity.name == "fluid-elevator-output" then
		new_name = "fluid-elevator-input"
		is_fluid = true
	end
	
	local new_endpoint = entity.surface.create_entity{name=new_name, position=entity.position, direction=entity.direction, force=entity.force, player=entity.last_user}
	if is_fluid then new_endpoint.fluidbox[1] = entity.fluidbox[1]
	else -- copy items
	end
	entity.destroy()
	
	return new_endpoint
end

function handle_elevators(tick)
	
	-- item elevators
	for i,elevators in ipairs(global.item_elevators) do  -- move items from input to output
		if not(elevators[1].valid and elevators[2].valid) then
			elevators[1].destroy()
			elevators[2].destroy()
			table.remove(global.item_elevators, i)
		else
			if elevators[1].get_item_count() > 0 and elevators[2].can_insert(elevators[1].get_inventory(defines.inventory.chest)[1]) then
				elevators[2].insert(elevators[1].get_inventory(defines.inventory.chest)[1])
				elevators[1].remove_item(elevators[1].get_inventory(defines.inventory.chest)[1])
			end
		end
	end
	
	-- fluid elevators
	for i,elevators in ipairs(global.fluid_elevators) do  -- average fluid between input and output
		if not(elevators[1].valid and elevators[2].valid) then -- remove link and change output to input
			if elevators[2].valid then switch_elevator(elevators[2]) end
			table.remove(global.fluid_elevators, i)
		elseif elevators[1].fluidbox[1] then -- input has some fluid
			local f1 = elevators[1].fluidbox[1]
			local f2 = elevators[2].fluidbox[1] or {name=f1.name, amount=0, temperature=f1.temperature}
			if f1.name == f2.name then
				local diff = math.min(f1.amount, elevators[2].fluidbox.get_capacity(1) - f2.amount, max_fluid_flow_per_tick)
				f1.amount = f1.amount - diff
				f2.amount = f2.amount + diff
				if f1.amount == 0 then f1 = nil end
				elevators[1].fluidbox[1] = f1
				elevators[2].fluidbox[1] = f2
			end
		end
	end
end

function elevator_on_cursor_stack_changed(player)
	if player.cursor_stack.valid_for_read and player.cursor_stack.name == "fluid-elevator" then
		if get_oversurface(player.surface) then
			for _,e in ipairs(get_oversurface(player.surface).find_entities_filtered{name="fluid-elevator-input"}) do
				local already_linked = false
				for i,v in ipairs(global.fluid_elevators) do
					if v[1] == e or v[2] == e then already_linked = true end
				end
				if not already_linked then
					global.placement_indicators[player.index] = global.placement_indicators[player.index] or {}
					table.insert(global.placement_indicators[player.index], rendering.draw_circle{color={0.5, 0.5, 0.5, 0.1}, surface=player.surface, target=e.position, radius=0.3, players={player}})
				end
			end
		end
		if get_subsurface(player.surface, false) then
			for _,e in ipairs(get_subsurface(player.surface, false).find_entities_filtered{name="fluid-elevator-input"}) do
				local already_linked = false
				for i,v in ipairs(global.fluid_elevators) do
					if v[1] == e or v[2] == e then already_linked = true end
				end
				if not already_linked then
					global.placement_indicators[player.index] = global.placement_indicators[player.index] or {}
					table.insert(global.placement_indicators[player.index], rendering.draw_circle{color={0.5, 0.5, 0.5, 0.1}, surface=player.surface, target=e.position, radius=0.3, players={player}})
				end
			end
		end
	end
end

function elevator_rotated(entity, previous_direction)
	if entity.name == "fluid-elevator-input" or entity.name == "fluid-elevator-output" then
		for i,v in ipairs(global.fluid_elevators) do
			if v[1] == entity or v[2] == entity then
				entity.direction = previous_direction
				global.fluid_elevators[i] = {switch_elevator(v[2]), switch_elevator(v[1])}
			end
		end
	end
end

function elevator_built(entity)
	local done = false -- priority is connecting to oversurface
	if get_oversurface(entity.surface) then
		for _,e in ipairs(get_oversurface(entity.surface).find_entities_filtered{name="fluid-elevator-input"}) do
			if e.position.x == entity.position.x and e.position.y == entity.position.y then -- switch to output and link
				local new_endpoint = switch_elevator(entity)
				table.insert(global.fluid_elevators, {e, new_endpoint})
				done = true
				break
			end
		end
	end
	if not done and get_subsurface(entity.surface, false) then
		for _,e in ipairs(get_subsurface(entity.surface, false).find_entities_filtered{name="fluid-elevator-input"}) do
			if e.position.x == entity.position.x and e.position.y == entity.position.y then -- switch to output and link
				local new_endpoint = switch_elevator(entity)
				table.insert(global.fluid_elevators, {e, new_endpoint})
				break
			end
		end
	end
end

function elevator_selected(player, entity)
	global.selection_indicators[player.index] = global.selection_indicators[player.index] or {}
	for i,v in ipairs(global.fluid_elevators) do
		if v[1] == entity then
			if get_subsurface(v[1].surface, false) == v[2].surface then -- selected entity is input and on top surface
				table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_line", surface=entity.surface, target=entity, target_offset={0, -0.3}, players={player}})
				table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_arrow", surface=entity.surface, target=entity, orientation=0.5, players={player}})
			else -- selected entity is input and on bottom surface
				table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_line", surface=entity.surface, target=entity, target_offset={0, 0.3}, players={player}})
				table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_arrow", surface=entity.surface, target=entity, players={player}})
			end
		elseif v[2] == entity then
			if get_subsurface(v[2].surface, false) == v[1].surface then -- selected entity is output and on top surface
				table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_line", surface=entity.surface, target=entity, target_offset={0, -0.3}, players={player}})
				table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_arrow", surface=entity.surface, target=entity, players={player}})
			else -- selected entity is output and on bottom surface
				table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_line", surface=entity.surface, target=entity, target_offset={0, 0.3}, players={player}})
				table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_arrow", surface=entity.surface, target=entity, orientation=0.5, players={player}})
			end
		end
	end
end
