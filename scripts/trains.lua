rolling_stock_types = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}

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

function create_fake_stops(stop)
	storage.train_stop_clones[stop.unit_number] = {}
	script.register_on_object_destroyed(stop)

	local s = get_top_surface(stop.surface)
	repeat
		if s ~= stop.surface then
			local fake = s.create_entity{name = "subway-stop", position = {0, 0}, force = stop.force}
			fake.backer_name = stop.backer_name
			fake.color = stop.color
			table.insert(storage.train_stop_clones[stop.unit_number], fake)
		end
		s = storage.subsurfaces[s.index]
	until not s 
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
	create_fake_stops(stop)
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

function handle_subways()
	for _, v in pairs(storage.train_subways) do
		if v.connection then
			local carriage = v.stop.surface.find_entities_filtered{type = rolling_stock_types, position = v.teleport_position, radius = 0.1}[1]
			if carriage and carriage.train.speed ~= 0 and not storage.train_carriage_protection[carriage.unit_number] and not v.connection.surface.entity_prototype_collides(carriage.name, util.moveposition(storage.train_subways[v.connection.unit_number].teleport_position, v.connection.direction, -0.2), false) then
				-- if there is moving rolling stock in the entrance and the exit is free, then transport
				local tid = carriage.train.id
				local teleport_pos = util.moveposition(storage.train_subways[v.connection.unit_number].teleport_position, v.connection.direction, -0.2)
				if not storage.train_transport[tid] then
					local sign = carriage.train.speed < 0 and -1 or 1
					local manual = carriage.train.manual_mode
					for _, t in pairs(storage.train_transport) do
						if t.arriving_train == carriage.train then manual = t.manual end
					end
					storage.train_transport[tid] = {leaving_train = carriage.train, leaving_speed = math.max(0.1, math.abs(carriage.train.speed)) * sign, manual = manual, exit_orientation = v.connection.orientation, detach_pos = util.moveposition(teleport_pos, v.connection.direction, -4)}
				end
				
				local e = v.connection.surface.create_entity{name = carriage.name, direction = carriage.direction, orientation = carriage.orientation, position = teleport_pos, force = carriage.force, quality = carriage.quality}
				if math2d.vector.to_orientation(math2d.position.subtract(e.position, teleport_pos)) == v.connection.orientation then
					-- example: exit points to south (0.5), vector orientation is also 0.5 if the entity is placed below the teleport position
					storage.train_carriage_protection[e.unit_number] = {e, teleport_pos, v.connection.orientation}
				end
				
				local front_out = v.connection.orientation == math2d.vector.to_orientation(math2d.position.subtract(e.train.back_end.rail.position, e.train.front_end.rail.position)) -- example: exit points to south (0.5), position of back rail - front rail is also 0.5 if the train front is heading
				
				if storage.train_transport[tid].arriving_train then
					local previous_speed_sign = storage.train_transport[tid].arriving_speed < 0 and -1 or 1
					e.connect_rolling_stock(front_out and defines.rail_direction.front or defines.rail_direction.back)
					local new_speed_sign = e.train.speed < 0 and -1 or 1
					if previous_speed_sign ~= new_speed_sign then
						storage.train_transport[tid].arriving_speed = -storage.train_transport[tid].arriving_speed
					end
				else
					if carriage.train.schedule and #carriage.train.schedule.records > 0 then
						e.train.schedule = carriage.train.schedule
						local next = e.train.schedule.current + 1
						if next > #e.train.schedule.records then next = 1 end
						storage.train_transport[tid].next_station = next
					end
					storage.train_transport[tid].arriving_speed = math.abs(storage.train_transport[tid].leaving_speed)
					if not front_out then storage.train_transport[tid].arriving_speed = -storage.train_transport[tid].arriving_speed end
				end
				storage.train_transport[tid].arriving_train = e.train
				storage.train_transport[tid].last_carriage = e
				
				e.copy_settings(carriage)
				
				local driver = carriage.get_driver()
				if driver ~= nil then
					driver.teleport(v.connection.surface.find_non_colliding_position((driver.is_player() and driver.character or driver).name, e.position, 5, 0.5), v.connection.surface)
					e.set_driver(driver)
				end
				for k = 1, #carriage.train.passengers do
					passenger = carriage.train.passengers[k]
					passenger.teleport(v.connection.surface.find_non_colliding_position((passenger.is_player() and passenger.character or passenger).name, e.position, 5, 0.5), v.connection.surface)
					e.set_driver(passenger)
				end

				-- COPY ENTITY CONTENTS ETC

				local inventory = carriage.get_inventory(defines.inventory.fuel)
				if inventory ~= nil then
					local to_inventory = e.get_inventory(defines.inventory.fuel)
					for i = 1, #inventory do to_inventory[i].set_stack(inventory[i]) end
				end
				inventory = carriage.get_inventory(defines.inventory.burnt_result)
				if inventory ~= nil then
					local to_inventory = e.get_inventory(defines.inventory.burnt_result)
					for i = 1, #inventory do to_inventory[i].set_stack(inventory[i]) end
				end
				inventory = carriage.get_inventory(defines.inventory.cargo_wagon)
				if inventory ~= nil then
					local to_inventory = e.get_inventory(defines.inventory.cargo_wagon)
					if inventory.supports_filters() then
						for i = 1, #inventory do
							to_inventory.set_filter(i, inventory.get_filter(i))
						end
					end
					for i = 1, #inventory do to_inventory[i].set_stack(inventory[i]) end
					if inventory.supports_bar() then to_inventory.set_bar(inventory.get_bar()) end
				end
				inventory = carriage.get_inventory(defines.inventory.artillery_wagon_ammo)
				if inventory ~= nil then
					local to_inventory = e.get_inventory(defines.inventory.artillery_wagon_ammo)
					for i = 1, #inventory do to_inventory[i].set_stack(inventory[i]) end
				end
				for i = 1, carriage.fluids_count do
					e.set_fluid(i, carriage.get_fluid(i))
				end

				e.color = carriage.color
				e.health = carriage.health

				if carriage.energy > 0 then
					e.energy = carriage.energy
					if carriage.burner then
						e.burner.currently_burning = carriage.burner.currently_burning
						e.burner.remaining_burning_fuel = carriage.burner.remaining_burning_fuel
					end
				end
				
				if carriage.grid then
					for _, equip in pairs(carriage.grid.equipment) do
						local toEquip = e.grid.put{name = equip.name, position = equip.position, quality = equip.quality}
						
						if equip.prototype.type == "energy-shield-equipment" then toEquip.shield = equip.shield	end
						toEquip.energy = equip.energy
						if equip.burner then
							toEquip.burner.heat = equip.burner.heat

							for i = 1, #equip.burner.inventory do toEquip.burner.inventory[i].set_stack(equip.burner.inventory[i]) end
							for i = 1, #equip.burner.burnt_result_inventory do toEquip.burner.urnt_result_inventory[i].set_stack(equip.burner.burnt_result_inventory[i]) end
						end
					end
				end
				
				-- END
				
				local next_carriage = carriage == carriage.train.front_stock and carriage.train.carriages[2] or carriage.train.carriages[#carriage.train.carriages - 1]
				local previus_speed_sign = storage.train_transport[tid].leaving_speed < 0 and -1 or 1

				carriage.disconnect_rolling_stock(carriage == carriage.train.front_stock and defines.rail_direction.back or defines.rail_direction.front)
				carriage.destroy()
				
				if next_carriage then
					storage.train_transport[tid].leaving_train = next_carriage.train

					local new_speed_sign = next_carriage.train.speed < 0 and -1 or 1
					if previus_speed_sign ~= new_speed_sign then -- leaving train changed front and back due to disconnecting
						storage.train_transport[tid].leaving_speed = -storage.train_transport[tid].leaving_speed
					end

					storage.train_transport[next_carriage.train.id] = storage.train_transport[tid]
					storage.train_transport[tid] = nil
				else
					storage.train_transport[tid].finished = true
				end
				
			end
		end
	end
	
	for u, c in pairs(storage.train_carriage_protection) do
		if not (c[1] and c[1].valid and math2d.vector.to_orientation(math2d.position.subtract(c[1].position, c[2])) == c[3]) then
			storage.train_carriage_protection[u] = nil
		end
	end

	for u, t in pairs(storage.train_transport) do
		if t.arriving_train.valid then
			if t.finished and math2d.vector.to_orientation(math2d.position.subtract(t.last_carriage.position, t.detach_pos)) ~= t.exit_orientation then
				if t.next_station then t.arriving_train.go_to_station(t.next_station) end
				t.arriving_train.manual_mode = t.manual
				storage.train_transport[u] = nil
			else
				t.arriving_train.speed = t.arriving_speed
				t.arriving_train.manual_mode = true
				if t.leaving_train.valid then
					t.leaving_train.speed = t.leaving_speed
					t.leaving_train.manual_mode = true
				end
			end
		end
	end
end
