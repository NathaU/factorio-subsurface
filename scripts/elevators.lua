function switch_elevator(entity) -- switch between input and output
	if entity.name == "item-elevator" or (entity.name == "entity-ghost" and entity.ghost_name == "item-elevator") then
		if entity.linked_belt_type == "input" then
			entity.linked_belt_type = "output"
		else
			entity.linked_belt_type = "input"
		end
		return
	end
	
	local new_name = "fluid-elevator-input"
	if entity.name == "fluid-elevator-input" then new_name = "fluid-elevator-output" end
	
	-- we need to destroy the old entity first because otherwise the new one won't connect to pipes
	local surface = entity.surface
	local pos = entity.position
	local direction = entity.direction
	local force = entity.force
	local last_user = entity.last_user
	local fluidbox = entity.fluidbox[1]
	local inv = false
	entity.destroy()
	
	local new_endpoint = surface.create_entity{name=new_name, position=pos, direction=direction, force=force, player=last_user}
	new_endpoint.fluidbox[1] = fluidbox
	
	return new_endpoint
end

function is_linked(entity)
	if elevator_name == "item-elevator" then
		return entity.linked_belt_neighbour ~= nil
	else
		for i,v in ipairs(global.fluid_elevators) do
			if v[1] == entity or v[2] == entity then return true end
		end
	end
end

function handle_elevators(tick)
	
	-- fluid elevators
	for i,elevators in ipairs(global.fluid_elevators) do  -- average fluid between input and output
		if not(elevators[1].valid and elevators[2].valid) then -- remove link and change output to input
			if elevators[2].valid then switch_elevator(elevators[2]) end
			table.remove(global.fluid_elevators, i)
		elseif elevators[1].fluidbox[1] then -- input has some fluid
			local f1 = elevators[1].fluidbox[1]
			local f2 = elevators[2].fluidbox[1] or {name=f1.name, amount=0, temperature=f1.temperature}
			if f1.name == f2.name then
				local diff = math.min(f1.amount, elevators[2].fluidbox.get_capacity(1) - f2.amount, elevators[2].prototype.pumping_speed)
				f1.amount = f1.amount - diff
				f2.amount = f2.amount + diff
				if f1.amount == 0 then f1 = nil end
				elevators[1].fluidbox[1] = f1
				elevators[2].fluidbox[1] = f2
			end
		end
	end
end

function show_placement_indicators(player, elevator_name)
	if get_oversurface(player.surface) then
		for _,e in ipairs(get_oversurface(player.surface).find_entities_filtered{name=elevator_name}) do
			if not is_linked(e) then
				global.placement_indicators[player.index] = global.placement_indicators[player.index] or {}
				table.insert(global.placement_indicators[player.index], rendering.draw_circle{color={0.5, 0.5, 0.5, 0.1}, surface=player.surface, target=e.position, radius=0.3, players={player}})
			end
		end
	end
	for _,e in ipairs(get_subsurface(player.surface).find_entities_filtered{name=elevator_name}) do
		if not is_linked(e) then
			global.placement_indicators[player.index] = global.placement_indicators[player.index] or {}
			table.insert(global.placement_indicators[player.index], rendering.draw_circle{color={0.5, 0.5, 0.5, 0.1}, surface=player.surface, target=e.position, radius=0.3, players={player}})
		end
	end
end

function elevator_on_cursor_stack_changed(player)
	if player.cursor_stack.valid_for_read then
		local link_key = false
		if player.cursor_stack.name == "fluid-elevator" then show_placement_indicators(player, "fluid-elevator-input")
		elseif player.cursor_stack.name == "item-elevator" then show_placement_indicators(player, "item-elevator")
		elseif player.is_cursor_blueprint() and player.get_blueprint_entities() then
			local item = false
			local fluid = false
			for _,e in ipairs(player.get_blueprint_entities()) do
				if e.name == "fluid-elevator-input" then fluid = true end
				if e.name == "item-elevator" then item = true end
			end
			if fluid then show_placement_indicators(player, "fluid-elevator-input") end
			if item then show_placement_indicators(player, "item-elevator") end
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
	elseif (entity.name == "item-elevator" or entity.ghost_name == "item-elevator") and entity.linked_belt_neighbour then
		local neighbour = entity.linked_belt_neighbour
		entity.disconnect_linked_belts()
		switch_elevator(entity)
		switch_elevator(neighbour)
		entity.connect_linked_belts(neighbour)
		entity.rotate{reverse=true}
	end
end

function elevator_built(entity, tags)
	local iter = {get_oversurface(entity.surface), get_subsurface(entity.surface)}
	for i=1,2,1 do
		if iter[i] then
			local e = iter[i].find_entity(entity.name, entity.position)
			if e then
				if entity.name == "fluid-elevator-input" then
					local inp = e
					local out = entity
					if tags and tags.type == 1 then -- the built one has to be input, so switch the other one
						inp = entity
						out = switch_elevator(e)
					else
						out = switch_elevator(entity)
					end
					table.insert(global.fluid_elevators, {inp, out})
				else
					if not entity.linked_belt_neighbour then
						entity.linked_belt_type = "output"
						entity.connect_linked_belts(e)
					end
				end
				break
			end
		end
	end
end

function elevator_selected(player, entity)
	global.selection_indicators[player.index] = global.selection_indicators[player.index] or {}
	local offs = 0 -- line offset, when 0 then don't show indicators
	local orien = 0 -- arrow orientation (0 is arrow pointing north)
	if entity.name == "item-elevator" and entity.linked_belt_neighbour and entity.linked_belt_neighbour.name == "item-elevator" then
		if entity.linked_belt_neighbour.surface == get_subsurface(entity.surface) then -- selected entity is top
			offs = -0.3
			if entity.linked_belt_type == "input" then orien = 0.5 end
		else offs = 0.3
			if entity.linked_belt_type == "output" then orien = 0.5 end
		end
	elseif entity.name == "fluid-elevator-input" or entity.name == "fluid-elevator-output" then
		for i,v in ipairs(global.fluid_elevators) do
			if v[1] == entity then
				if get_subsurface(v[1].surface) == v[2].surface then -- selected entity is input and on top surface
					offs = -0.3
					orien = 0.5
				else -- selected entity is input and on bottom surface
					offs = 0.3
				end
			elseif v[2] == entity then
				if get_subsurface(v[2].surface) == v[1].surface then -- selected entity is output and on top surface
					offs = -0.3
				else -- selected entity is output and on bottom surface
					offs = 0.3
					orien = 0.5
				end
			end
		end
	end
	if offs ~= 0 then
		table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_line", surface=entity.surface, target=entity, target_offset={0, offs}, players={player}})
		table.insert(global.selection_indicators[player.index], rendering.draw_sprite{sprite="utility/indication_arrow", surface=entity.surface, target=entity, orientation=orien, players={player}})
	end
end
