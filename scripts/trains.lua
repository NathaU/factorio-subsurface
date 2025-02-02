function subway_built(entity)
	storage.train_subways[entity.unit_number] = {rails = {}}
	
	for i = 4, -4, -2 do
		local rail = entity.surface.create_entity{name = "subway-rail", position = util.moveposition({entity.position.x, entity.position.y}, entity.direction, i), direction = entity.direction, force = entity.force, player = entity.last_user}
		rail.minable_flag = false
		rail.destructible = false
		table.insert(storage.train_subways[entity.unit_number].rails, rail)
	end

	storage.train_subways[entity.unit_number].teleport_position = util.moveposition({entity.position.x, entity.position.y}, entity.direction, 1) -- the first carriage center is at that position when arriving at the stop
	storage.train_subways[entity.unit_number].stop_pos = util.rotate_position({2, -4}, entity.orientation)

	entity.rotatable = false
	script.register_on_object_destroyed(entity)
end

function subway_show_placement_indicators(player, entity)
	local suffix = "s"
	local offset = {0, -12}
	if entity.direction == defines.direction.east then
		suffix = "w"
		offset = {14, 0}
	elseif entity.direction == defines.direction.south then
		suffix = "n"
		offset = {0, 12}
	elseif entity.direction == defines.direction.west then
		suffix = "e"
		offset = {-14, 0}
	end
	table.insert(storage.placement_indicators[player.index], rendering.draw_sprite{sprite = "placement-indicator-subway-"..suffix, surface = player.surface, target = math2d.position.add(entity.position, offset), players = {player}})
end

function subway_link(entity1, entity2)
	storage.train_subways[entity1.unit_number].connection = entity2
	storage.train_subways[entity2.unit_number].connection = entity1

	local level1 = get_subsurface_depth(entity1.surface)
	local level2 = get_subsurface_depth(entity2.surface)

	local stop = entity1.surface.create_entity{name = "subway-stop", position = math2d.position.add(entity1.position, storage.train_subways[entity1.unit_number].stop_pos), direction = entity1.direction, force = entity1.force, player = entity1.last_user}
	stop.backer_name = math.min(level1, level2) .. " [img=elevator] " .. math.max(level1, level2)
	storage.train_subways[entity1.unit_number].stop = stop

	stop = entity2.surface.create_entity{name = "subway-stop", position = math2d.position.add(entity2.position, storage.train_subways[entity2.unit_number].stop_pos), direction = entity2.direction, force = entity2.force, player = entity2.last_user}
	stop.backer_name = math.min(level1, level2) .. " [img=elevator] " .. math.max(level1, level2)
	storage.train_subways[entity2.unit_number].stop = stop
end

function subway_entity_destroyed(unit_number)
	if storage.train_subways[unit_number].stop then storage.train_subways[unit_number].stop.destroy() end
	for _, r in ipairs(storage.train_subways[unit_number].rails) do
		if not r.destroy() then
			r.minable = true
			r.destructible = true
		end
	end
	if storage.train_subways[unit_number].connection then
		storage.train_subways[storage.train_subways[unit_number].connection.unit_number].connection = nil
		storage.train_subways[storage.train_subways[unit_number].connection.unit_number].stop.destroy()
	end
	storage.train_subways[unit_number] = nil
end
