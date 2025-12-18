rolling_stock_types = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}

function subway_built(entity)
	storage.train_subways[entity.unit_number] = {rails = {}}
	
	for i = 4, -4, -2 do
		local rail_pos = util.moveposition({entity.position.x, entity.position.y}, entity.direction, i)
		local rail = entity.surface.create_entity{name = "subway-rail", position = rail_pos, direction = entity.direction, force = entity.force, player = entity.last_user}
		if not rail then rail = entity.surface.find_entities_filtered{position = rail_pos, name = "subway-rail", direction = entity.direction, force = entity.force, limit = 1}[1] end
		rail.minable_flag = false
		rail.destructible = false
		table.insert(storage.train_subways[entity.unit_number].rails, rail)
	end

	entity.rotatable = false
	entity.destructible = false
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

function create_fake_stop(surface, ref_stop)
	storage.train_stop_clones[ref_stop.unit_number] = storage.train_stop_clones[ref_stop.unit_number] or {}
	local fake = surface.create_entity{name = "subway-stop", position = {0, 0}, force = ref_stop.force}
	fake.backer_name = ref_stop.backer_name
	fake.color = ref_stop.color
	table.insert(storage.train_stop_clones[ref_stop.unit_number], fake)
end
function create_fake_stops(stop)
	script.register_on_object_destroyed(stop)
	local s = get_top_surface(stop.surface)
	repeat
		if s ~= stop.surface then create_fake_stop(s, stop) end
		s = storage.subsurfaces[s.index]
	until not s
end

function subway_link(entity1, entity2)
	storage.train_subways[entity1.unit_number].connection = entity2
	storage.train_subways[entity2.unit_number].connection = entity1

	local level1 = get_subsurface_depth(entity1.surface)
	local level2 = get_subsurface_depth(entity2.surface)

	local stop = nil
	for _, e in ipairs({entity1, entity2}) do
		stop = e.surface.create_entity{name = "subway-stop", position = offset_position(e, {2, -4}), direction = e.direction, force = e.force, player = e.last_user}
		stop.backer_name = math.min(level1, level2) .. " [img=elevator] " .. math.max(level1, level2)
		storage.train_subways[e.unit_number].stop = stop
	end
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
	for u, v in pairs(storage.train_subways) do
		if v.connection then
			local carriage_arriving_at_station = v.stop.surface.find_entities_filtered{type = rolling_stock_types, position = v.rails[5].position}[1]
			if carriage_arriving_at_station and carriage_arriving_at_station.train.path_end_stop == v.stop and carriage_arriving_at_station.train.path.size - carriage_arriving_at_station.train.path.current == 4 then
				-- capture trains in auto mode early to prevent decelerating
				storage.train_transport[u] = {leaving_train = carriage_arriving_at_station.train, leaving_speed = carriage_arriving_at_station.train.speed, manual = false, stop1 = v.stop, stop2 = storage.train_subways[v.connection.unit_number].stop}
				storage.train_transport[u].stop2.trains_limit = 0
				local current_record = carriage_arriving_at_station.train.schedule.current
				if carriage_arriving_at_station.train.schedule.records[current_record].temporary then
					carriage_arriving_at_station.train.get_schedule().remove_record({schedule_index = current_record})
				else
					if current_record == #carriage_arriving_at_station.train.schedule.records then current_record = 0 end
					current_record = current_record + 1
				end
				storage.train_transport[u].next_station = current_record
			end
			
			local carriage = v.stop.surface.find_entities_filtered{type = rolling_stock_types, position = offset_position(v.stop, {-2, 1})}[1]
			
			if carriage then
				-- teleport position is the position where the carriage touches the rail end
				local teleport_pos = offset_position(storage.train_subways[v.connection.unit_number].stop, {-2, math.max(3, math.max(math.abs(carriage.prototype.collision_box.left_top.y), math.abs(carriage.prototype.collision_box.right_bottom.y)) - 1)})
				
				if ((carriage.train.speed > 0 and (carriage.train.front_end.rail == v.rails[1] or carriage.train.front_end.rail == v.rails[2])) or (carriage.train.speed < 0 and (carriage.train.back_end.rail == v.rails[1] or carriage.train.back_end.rail == v.rails[2]))) and v.connection.surface.can_place_entity{name = carriage.name, position = teleport_pos, direction = carriage.direction, force = carriage.force} then
					-- teleport if there is rolling stock moving towards the entrance and the exit is free
					local data = storage.train_transport[u]
					if not data then
						local manual = carriage.train.manual_mode
						for _, t in pairs(storage.train_transport) do
							-- if the train is going through multiple subways, then copy mode from the original one
							if t.arriving_train == carriage.train then manual = t.manual end
						end
						local sign = carriage.train.speed < 0 and -1 or 1
						data = {leaving_train = carriage.train, leaving_speed = math.min(math.max(0.1, math.abs(carriage.train.speed)), 6) * sign, manual = manual, stop1 = v.stop, stop2 = storage.train_subways[v.connection.unit_number].stop}
						storage.train_transport[u] = data
					end
					
					if data.arriving_train then -- if the train is already arriving, then we need to move the teleport position that the trains can connect
						while v.connection.surface.can_place_entity{name = carriage.name, position = teleport_pos, direction = carriage.direction, force = carriage.force} do
							teleport_pos = math2d.position.add(teleport_pos, math2d.vector.from_orientation(storage.train_subways[v.connection.unit_number].stop.orientation, -0.25))
						end
						teleport_pos = math2d.position.add(teleport_pos, math2d.vector.from_orientation(storage.train_subways[v.connection.unit_number].stop.orientation, 0.25))
					end
					
					local e = v.connection.surface.create_entity{name = carriage.name, orientation = carriage.orientation, position = teleport_pos, force = carriage.force, quality = carriage.quality}
					
					if data.arriving_train then
						local previous_speed_sign = data.arriving_speed < 0 and -1 or 1
						local new_speed_sign = e.train.speed < 0 and -1 or 1
						if previous_speed_sign ~= new_speed_sign then data.arriving_speed = -data.arriving_speed end
					else -- this is the first carriage to be teleported
						if carriage.train.schedule and #carriage.train.schedule.records > 0 then
							for i = #carriage.train.schedule.records, 1, -1 do
								local rec = carriage.train.schedule.records[i]
								if rec.rail then carriage.train.get_schedule().remove_record({schedule_index = i}) end
							end
						end
						if carriage.train.schedule then e.train.schedule = carriage.train.schedule end

						local front_out = v.connection.orientation == to_orientation(math2d.position.subtract(e.train.back_end.rail.position, e.train.front_end.rail.position)) -- example: exit points to south (0.5), position of back rail - front rail is also 0.5 if the train front is heading
						data.arriving_speed = (front_out and 1 or -1) * math.abs(data.leaving_speed)
					end
					data.arriving_train = e.train

					local schedule = data.arriving_train.schedule
					e.copy_settings(carriage)
					data.arriving_train.schedule = schedule
					data.arriving_train.get_schedule().set_interrupts(carriage.train.get_schedule().get_interrupts())
					
					local driver = carriage.get_driver()
					if driver and (not driver.is_player() or (driver.is_player() and driver.controller_type == defines.controllers.character)) then
						driver.teleport(v.connection.surface.find_non_colliding_position((driver.is_player() and driver.character or driver).name, e.position, 10, 0.5), v.connection.surface)
						e.set_driver(driver)
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
					e.copy_color_from_train_stop = carriage.copy_color_from_train_stop
					e.health = carriage.health
					e.enable_logistics_while_moving = carriage.enable_logistics_while_moving
					if e.type == "artillery-wagon" then e.artillery_auto_targeting = carriage.artillery_auto_targeting end

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
					
					local next_carriage = carriage.get_connected_rolling_stock(defines.rail_direction.front) or carriage.get_connected_rolling_stock(defines.rail_direction.back)
					local previus_speed_sign = data.leaving_speed < 0 and -1 or 1

					carriage.destroy()
					
					if next_carriage then
						data.leaving_train = next_carriage.train

						local new_speed_sign = next_carriage.train.speed < 0 and -1 or 1
						if previus_speed_sign ~= new_speed_sign then -- leaving train changed front and back due to disconnecting
							data.leaving_speed = -data.leaving_speed
						end
					else
						if not data.manual and data.next_station then data.arriving_train.go_to_station(data.next_station) end
						data.arriving_train.manual_mode = data.manual
						data.arriving_train.speed = data.arriving_speed
						storage.train_transport[u].stop2.trains_limit = nil
						storage.train_transport[u] = nil
					end
				end
			end
		end
	end

	for u, t in pairs(storage.train_transport) do
		if t.stop1.valid and t.stop2.valid then
			if t.leaving_train.valid then
				t.leaving_train.speed = t.leaving_speed
				t.leaving_train.manual_mode = true
			end
			if t.arriving_train and t.arriving_train.valid then
				t.arriving_train.speed = t.arriving_speed
				t.arriving_train.manual_mode = true
			end
		else
			if t.arriving_train and t.arriving_train.valid then t.arriving_train.manual_mode = true end
			t.leaving_train.manual_mode = true
			storage.train_transport[u] = nil
		end
	end
end
