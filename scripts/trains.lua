rolling_stock_types = {"locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"}

function subway_built(entity)
	storage.train_subways[entity.unit_number] = {rails = {}}
	
	for i = 4, -4, -2 do
		local rail = entity.surface.create_entity{name = "subway-rail", position = util.moveposition({entity.position.x, entity.position.y}, entity.direction, i), direction = entity.direction, force = entity.force, player = entity.last_user}
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
	for _, v in pairs(storage.train_subways) do
		if v.connection then
			local carriage_arriving_at_station = v.stop.surface.find_entities_filtered{type = rolling_stock_types, position = v.rails[5].position}[1]
			if carriage_arriving_at_station and carriage_arriving_at_station.train.state == defines.train_state.arrive_station and carriage_arriving_at_station.train.path_end_stop == v.stop then
				storage.train_transport[carriage_arriving_at_station.train.id] = {leaving_train = carriage_arriving_at_station.train, leaving_speed = carriage_arriving_at_station.train.speed, manual = false}
			end
			
			local carriage = v.stop.surface.find_entities_filtered{type = rolling_stock_types, position = offset_position(v.stop, {-2, 1})}[1]
			
			local teleport_pos = offset_position(storage.train_subways[v.connection.unit_number].stop, {-2, 4})
			teleport_pos[1] = teleport_pos.x
			teleport_pos[2] = teleport_pos.y

			if carriage and ((carriage.train.front_end.rail == v.rails[2] and carriage.train.speed > 0) or (carriage.train.back_end.rail == v.rails[2] and carriage.train.speed < 0)) and not v.connection.surface.entity_prototype_collides(carriage.name, teleport_pos, false, carriage.direction) then
				-- teleport if there is rolling stock moving towards the entrance and the exit is free
				local old_train_id = carriage.train.id
				local data = storage.train_transport[old_train_id]
				if not data then
					local sign = carriage.train.speed < 0 and -1 or 1
					local manual = carriage.train.manual_mode
					for _, t in pairs(storage.train_transport) do
						-- if the train is goig through multiple subways, then copy from the original one
						if t.arriving_train == carriage.train then manual = t.manual end
					end
					data = {leaving_train = carriage.train, leaving_speed = math.max(0.1, math.abs(carriage.train.speed)) * sign, manual = manual}
					storage.train_transport[old_train_id] = data
				end
				
				local e = v.connection.surface.create_entity{name = carriage.name, direction = carriage.direction, orientation = carriage.orientation, position = teleport_pos, force = carriage.force, quality = carriage.quality}
				
				local front_out = v.connection.orientation == to_orientation(math2d.position.subtract(e.train.back_end.rail.position, e.train.front_end.rail.position)) -- example: exit points to south (0.5), position of back rail - front rail is also 0.5 if the train front is heading
				
				if data.arriving_train then
					local previous_speed_sign = data.arriving_speed < 0 and -1 or 1
					e.connect_rolling_stock(front_out and defines.rail_direction.front or defines.rail_direction.back)
					local new_speed_sign = e.train.speed < 0 and -1 or 1
					if previous_speed_sign ~= new_speed_sign then data.arriving_speed = -data.arriving_speed end
				else -- this is the first carriage to be teleported
					if carriage.train.schedule and #carriage.train.schedule.records > 0 then
						e.train.schedule = carriage.train.schedule
						local next = e.train.schedule.current + 1
						if next > #e.train.schedule.records then next = 1 end
						data.next_station = next
					end
					data.arriving_speed = (front_out and 1 or -1) * math.abs(data.leaving_speed)
				end
				data.arriving_train = e.train
				data.last_carriage = e
				
				e.copy_settings(carriage)
				
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
				local previus_speed_sign = data.leaving_speed < 0 and -1 or 1

				carriage.disconnect_rolling_stock(carriage == carriage.train.front_stock and defines.rail_direction.back or defines.rail_direction.front)
				carriage.destroy()
				
				if next_carriage then
					data.leaving_train = next_carriage.train

					local new_speed_sign = next_carriage.train.speed < 0 and -1 or 1
					if previus_speed_sign ~= new_speed_sign then -- leaving train changed front and back due to disconnecting
						data.leaving_speed = -data.leaving_speed
					end

					storage.train_transport[next_carriage.train.id] = data
					storage.train_transport[old_train_id] = nil
				else
					data.finished = {data.leaving_speed > 0, storage.train_subways[v.connection.unit_number].rails[4]}
				end
				
			end
		end
	end

	for u, t in pairs(storage.train_transport) do
		if t.leaving_train.valid then
			t.leaving_train.speed = t.leaving_speed
			t.leaving_train.manual_mode = true
		end
		if t.arriving_train and t.arriving_train.valid then
			if t.finished and (t.finished[1] and t.arriving_train.back_end or t.arriving_train.front_end).rail == t.finished[2] then
				if not t.manual and t.next_station then
					t.arriving_train.go_to_station(t.next_station)
					t.arriving_train.speed = t.arriving_speed
				end
				t.arriving_train.manual_mode = t.manual
				storage.train_transport[u] = nil
			else
				t.arriving_train.speed = t.arriving_speed
				t.arriving_train.manual_mode = true
			end
		end
	end
end
