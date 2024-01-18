require "util"
require "lib"

local subsurface_map_settings = {
	pollution=
    {
      enabled=true,
      -- these are values for 60 ticks (1 simulated second)
      --
      -- amount that is diffused to neighboring chunk
      -- (possibly repeated for other directions as well)
      diffusion_ratio=0.001,
      -- this much PUs must be on the chunk to start diffusing
      min_to_diffuse=15,
      -- constant modifier a percentage of 1 - the pollution eaten by a chunks tiles
      ageing=0,
      -- anything bigger than this is visualised as this value
      expected_max_per_chunk=7000,
      -- anything lower than this (but > 0) is visualised as this value
      min_to_show_per_chunk=700,
      min_pollution_to_damage_trees = 3500,
      pollution_with_max_forest_damage = 10000,
      pollution_per_tree_damage = 2000,
      pollution_restored_per_tree_damage = 500,
      max_pollution_to_restore_trees = 1000
    },
	steering=
    {
      default=
      {
        -- not including the radius of the unit
        radius = 1.2,
        separation_force = 0.005,
        separation_factor = 1.2,
        force_unit_fuzzy_goto_behavior = false
      },
      moving=
      {
        radius = 3,
        separation_force = 0.01,
        separation_factor = 3,
        -- used only for special "to look good" purposes (like in trailer)
        force_unit_fuzzy_goto_behavior = false
      }
    },
	default_enable_all_autoplace_controls = false,
	cliff_settings = {cliff_elevation_0 = 1024},
}

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         --if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function get_subsurface(surface)
	if global.subsurfaces == nil then global.subsurfaces = {} end
	if global.subsurfaces[surface.name] then -- if the subsurface already exist
		return global.subsurfaces[surface.name]
	else -- we need to create the subsurface (pattern : <surface>_subsurface_<number>
		local name = ""
		local _, _, oname, number = string.find(surface.name, "(.+)_subsurface_([0-9]+)$")
		if oname == nil then name = surface.name .. "_subsurface_1"
		else name = oname .. "_subsurface_" .. (tonumber(number)+1) end
		
		local subsurface = game.get_surface(name)
		if not subsurface then
			subsurface = game.create_surface(name, subsurface_map_settings)
			subsurface.generate_with_lab_tiles = true
			subsurface.daytime = 0.5
			subsurface.freeze_daytime = true
		end
		global.subsurfaces[surface.name] = subsurface
		return subsurface
	end
end
function get_oversurface(subsurface)
	for n,s in pairs(global.subsurfaces) do
		if s == subsurface and game.get_surface(n) then return game.get_surface(n) end
	end
	return nil
end

function is_subsurface(_surface)
	if string.find(_surface.name, "_subsurface_([0-9]+)$") or 0 > 1 then return true
	else return false end
end

function clear_subsurface(_surface, _position, _digging_radius, _clearing_radius)
	if _digging_radius < 1 then return nil end -- min _digging_radius is 1 
	local digging_subsurface_area = get_area(_position, _digging_radius - 1)
	local new_tiles = {}

	if _clearing_radius then
		local clearing_subsurface_area = get_area(_position, _clearing_radius)
		for _,entity in ipairs(_surface.find_entities(clearing_subsurface_area)) do
			if entity.type ~="player" then
				entity.destroy()
			else
				entity.teleport(get_safe_position(_position, {x=_position.x + _clearing_radius, y = _position.y}))
			end
		end 
	end

	if not is_subsurface(_surface) then return end

	local walls_destroyed = 0
	for x, y in iarea(digging_subsurface_area) do
		if _surface.get_tile(x, y).name ~= "caveground" then
			table.insert(new_tiles, {name = "caveground", position = {x, y}})
		end

		--[[if global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))] then -- remove the mark
			if global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))].valid then
				global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))].destroy()
			end
			global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))] = nil
		end
		if global.digging_pending[_surface.name] and global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] then -- remove the digging pending entity
			if global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))].valid then
				global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))].destroy()
			end
			global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] = nil
		end]]

		local wall = _surface.find_entity("subsurface-walls", {x = x, y = y})
		if wall then 
			wall.destroy()
			walls_destroyed = walls_destroyed + 1
		else
		end
	end
	local to_add = {}
	for x, y in iouter_area_border(digging_subsurface_area) do
		if _surface.get_tile(x, y).name == "out-of-map" then
			table.insert(new_tiles, {name = "cave-walls", position = {x, y}})
			_surface.create_entity{name = "subsurface-walls", position = {x, y}, force=game.forces.neutral}
			--[[if global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))] then -- manage the marked for digging cells
				if global.digging_pending[_surface.name] == nil then global.digging_pending[_surface.name] = {} end
				if global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] == nil then 
					table.insert(to_add, {surface = _surface,x = x, y = y})
				end
				if global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))].valid then	
					global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))].destroy()
				end
				global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))] = nil
			end]]
		end
	end
	_surface.set_tiles(new_tiles)

	-- done after because set_tiles remove decorations
	for _,data in ipairs(to_add) do
		local pending_entity = data.surface.create_entity{name = "pending-digging", position = {x = data.x, y = data.y}, force=game.forces.neutral}
		global.digging_pending[data.surface.name][string.format("{%d,%d}", math.floor(data.x), math.floor(data.y))] = pending_entity
	end

	return walls_destroyed
end

script.on_event(defines.events.on_tick, function(event)
	
	-- handle all working drillers
	if global.subsurface_surface_drillers ~= nil then
		for u,d in pairs(global.subsurface_surface_drillers) do
			if d.products_finished == 1 then -- time for one driller finish digging
				
				-- oversurface entity placing
				local p = d.position
				local entrance_car = d.surface.create_entity{name="tunnel-entrance", position={p.x+0.5, p.y+0.5}, force=d.force} -- because Factorio sets the entity at -0.5, -0.5
				local entrance_pole = d.surface.create_entity{name="tunnel-entrance-cable", position=p, force=d.force}
				table.remove(global.subsurface_surface_drillers, i)
				
				-- subsurface entity placing
				local subsurface = get_subsurface(d.surface)
				clear_subsurface(subsurface, d.position, 4, 1.5)
				local exit_car = subsurface.create_entity{name="tunnel-exit", position={p.x+0.5, p.y+0.5}, force=d.force} -- because Factorio sets the entity at -0.5, -0.5
				local exit_pole = subsurface.create_entity{name="tunnel-exit-cable", position=p, force=d.force}
				
				entrance_pole.connect_neighbour(exit_pole)
				entrance_pole.connect_neighbour{wire=defines.wire_type.red, target_entity=exit_pole, source_circuit_id=1, target_circuit_id=1}
				entrance_pole.connect_neighbour{wire=defines.wire_type.green, target_entity=exit_pole, source_circuit_id=1, target_circuit_id=1}
				
				if global.subsurface_pole_links == nil then global.subsurface_pole_links = {} end
				global.subsurface_pole_links[entrance_pole.unit_number] = exit_pole
				global.subsurface_pole_links[exit_pole.unit_number] = entrance_pole
				if global.subsurface_car_links == nil then global.subsurface_car_links = {} end
				global.subsurface_car_links[entrance_car.unit_number] = exit_car
				global.subsurface_car_links[exit_car.unit_number] = entrance_car
				
				d.destroy()
			end
		end
	end
	if global.subsurface_item_elevators ~= nil then -- move items from input to output
		for i,elevators in ipairs(global.subsurface_item_elevators) do
			if not(elevators[1].valid and elevators[2].valid) then
				if not elevators[1].valid then elevators[1].destroy() end
				if not elevators[2].valid then elevators[2].destroy() end
				table.remove(global.subsurface_item_elevators, i)
			else
				if elevators[1].get_item_count() > 0 and elevators[2].can_insert(elevators[1].get_inventory(defines.inventory.chest)[1]) then
					elevators[2].insert(elevators[1].get_inventory(defines.inventory.chest)[1])
					elevators[1].remove_item(elevators[1].get_inventory(defines.inventory.chest)[1])
				end
			end
		end
	end
	if global.subsurface_fluid_elevators ~= nil then -- average fluid between input and output
		for i,elevators in ipairs(global.subsurface_fluid_elevators) do
			if not(elevators[1].valid and elevators[2].valid) then
				if not elevators[1].valid then elevators[1].destroy() end
				if not elevators[2].valid then elevators[2].destroy() end
				table.remove(global.subsurface_fluid_elevators, i)
			elseif elevators[1].fluidbox[1] then -- input has some fluid
				local f1 = elevators[1].fluidbox[1]
				local f2 = elevators[2].fluidbox[1] or {name=f1.name, amount=0}
				local new_amount = (f1.amount + f2.amount) / 2
				f1.amount = new_amount
				f2.amount = new_amount
				elevators[1].fluidbox[1] = f1
				elevators[2].fluidbox[1] = f2
			end
		end
	end
end)

-- build entity only if it is safe in subsurface
function build_safe(event, func)
	
	-- first, check if the given area is uncovered (caveground tiles) and has no entities in it
	local subsurface = get_subsurface(event.created_entity.surface)
	local area = event.created_entity.bounding_box
	local safe_position = true
	if not is_subsurface(subsurface) then safe_position = false end
	if not subsurface.is_chunk_generated{event.created_entity.position.x / 32, event.created_entity.position.y / 32} then safe_position = false end
	for _,t in ipairs(subsurface.find_tiles_filtered{area=area}) do
		if t.name ~= "caveground" then safe_position = false end
	end
	if subsurface.count_entities_filtered{area=area} > 0 then safe_position = false end
	
	if safe_position then func()
	elseif event["player_index"] then
		local p = game.get_player(event.player_index)
		p.create_local_flying_text{text={"subsurface.cannot-place-here"}, position=event.created_entity.position}
		p.mine_entity(event.created_entity, true)
	else
		-- robot built it
	end
	
end
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
	local entity = event.created_entity
	if entity.name == "surface-driller" then
		
		get_subsurface(entity.surface).request_to_generate_chunks(entity.position, 3)
		if global.subsurface_surface_drillers == nil then global.subsurface_surface_drillers = {} end
		table.insert(global.subsurface_surface_drillers, entity)
	
	elseif entity.name == "item-elevator-input" then
		
		build_safe(event, function()
			local complementary = get_subsurface(entity.surface).create_entity{name="item-elevator-input", position=entity.position, force=entity.force, direction=entity.direction}
			if complementary then
				if global.subsurface_item_elevators == nil then global.subsurface_item_elevators = {} end
				table.insert(global.subsurface_item_elevators, {entity, complementary}) -- {input, output}
			end
		end)
		
	
	elseif entity.name == "item-elevator-output" then
		
		build_safe(event, function()
			local complementary = get_subsurface(entity.surface).create_entity{name="item-elevator-output", position=entity.position, force=entity.force, direction=entity.direction}
			if complementary then
				if global.subsurface_item_elevators == nil then global.subsurface_item_elevators = {} end
				table.insert(global.subsurface_item_elevators, {complementary, entity}) -- {input, output}
			end
		end)
	
	elseif entity.name == "fluid-elevator-input" then
		
		build_safe(event, function()
			local complementary = get_subsurface(entity.surface).create_entity{name = "fluid-elevator-output", position = entity.position, force=entity.force, direction=entity.direction}
			if complementary then
				if global.subsurface_fluid_elevators == nil then global.subsurface_fluid_elevators = {} end
				table.insert(global.subsurface_fluid_elevators, {entity, complementary}) -- {input, output}
			end
		end)
	
	elseif entity.name == "fluid-elevator-output" then
		
		build_safe(event, function()
			local complementary = get_subsurface(entity.surface).create_entity{name = "fluid-elevator-input", position = entity.position, force=entity.force, direction=entity.direction}
			if complementary then
				if global.subsurface_fluid_elevators == nil then global.subsurface_fluid_elevators = {} end
				table.insert(global.subsurface_fluid_elevators, {complementary, entity}) -- {input, output}
			end
		end)
	end
end)

-- player elevator
script.on_event(defines.events.on_player_driving_changed_state, function(event)
	if event.entity and (event.entity.name == "tunnel-entrance" or event.entity.name == "tunnel-exit") and global.subsurface_car_links and global.subsurface_car_links[event.entity.unit_number] then
		local opposite_car = global.subsurface_car_links[event.entity.unit_number]
		game.get_player(event.player_index).teleport(game.get_player(event.player_index).position, opposite_car.surface)
	end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
	if is_subsurface(event.surface) then
		local newTiles = {}
		for x, y in iarea(event.area) do
			table.insert(newTiles, {name = "out-of-map", position = {x, y}})
		end
		event.surface.set_tiles(newTiles)
	end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
	if event.entity.name == "subsurface-walls" then
		clear_subsurface(event.entity.surface, event.entity.position, 1, nil)
	elseif event.entity.name == "item-elevator-output" or event.entity.name == "item-elevator-input" then
		for i,elevators in ipairs(global.subsurface_item_elevators) do
			if event.entity == elevators[1] then
				elevators[2].destroy()
				table.remove(global.subsurface_item_elevators, i)
			elseif event.entity == elevators[2] then
				elevators[1].destroy()
				table.remove(global.subsurface_item_elevators, i)
			end
		end
	elseif event.entity.name == "fluid-elevator-input" or event.entity.name == "fluid-elevator-output" then
		for i,elevators in ipairs(global.subsurface_fluid_elevators) do
			if event.entity == elevators[1] then
				elevators[2].destroy()
				table.remove(global.subsurface_fluid_elevators, i)
			elseif event.entity == elevators[2] then
				elevators[1].destroy()
				table.remove(global.subsurface_fluid_elevators, i)
			end
		end
	end
end)


script.on_event(defines.events.on_pre_surface_deleted, function(event)
	if global.subsurfaces then
		-- delete all its subsurfaces and remove from list
		local name = game.get_surface(event.surface_index).name
		while(global.subsurfaces[name]) do
			local s = global.subsurfaces[name]
			global.subsurfaces[name] = nil
			name = s.name
			game.delete_surface(s)
		end
		if is_subsurface(get_surface(event.surface_index)) then
			global.subsurfaces[get_oversurface(game.get_surface(event.surface_index)).name] = nil
		end
	end
end)