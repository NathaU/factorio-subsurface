require "util"
math2d = require "math2d"
require "scripts.lib"
require "scripts.remote"
require "scripts.cutscene"
require "scripts.aai-miners"
require "scripts.resources"
require "scripts.elevators"

max_pollution_move_active = 128 -- the max amount of pollution that can be moved per 64 ticks from one surface to the above
max_pollution_move_passive = 64

suffocation_threshold = 400
suffocation_damage = 2.5 -- per 64 ticks (~1 second)
attrition_threshold = 150
attrition_types = {"assembling-machine", "reactor", "mining-drill", "generator", "inserter", "burner-generator", "car", "construction-robot", "lab", "loader", "loader-1x1", "locomotive", "logistic-robot", "power-switch", "pump", "radar", "roboport", "spider-vehicle", "splitter", "transport-belt"}

function setup_globals()
	global.subsurfaces = global.subsurfaces or {}
	global.pole_links = global.pole_links or {}
	global.car_links = global.car_links or {}
	global.fluid_elevators = global.fluid_elevators or {}
	global.heat_elevators = global.heat_elevators or {}
	global.air_vents = global.air_vents or {}
	global.air_vent_lights = global.air_vent_lights or {}
	global.exposed_chunks = global.exposed_chunks or {} -- [surface][x][y], 1 means chunk is exposed, 0 means chunk is next to an exposed chunk
	global.aai_miner_paths = global.aai_miner_paths or {}
	global.prospectors = global.prospectors or {}
	global.support_lamps = global.support_lamps or {}
	global.placement_indicators = global.placement_indicators or {}
	global.selection_indicators = global.selection_indicators or {}
end

script.on_init(function()
	setup_globals()
	for _,s in pairs(game.surfaces) do manipulate_autoplace_controls(s) end
end)
script.on_configuration_changed(setup_globals)

function get_subsurface(surface, create)
	if create == nil then create = true end
	if global.subsurfaces[surface.index] then -- the subsurface already exists
		return global.subsurfaces[surface.index]
	elseif create then -- we need to create the subsurface (pattern : <surface>_subsurface_<number>
		local subsurface_name = ""
		local _, _, topname, depth = string.find(surface.name, "(.+)_subsurface_([0-9]+)$")
		if topname == nil then -- surface is not a subsurface
			topname = surface.name
			depth = 1
		else
			depth = tonumber(depth) + 1
		end
		subsurface_name = topname .. "_subsurface_" .. depth
		
		local subsurface = game.get_surface(subsurface_name)
		if not subsurface then
			
			local mgs = {
				seed = surface.map_gen_settings.seed,
				width = surface.map_gen_settings.width,
				height = surface.map_gen_settings.height,
				autoplace_controls = make_autoplace_controls(topname, depth),
				autoplace_settings = {
				  tile = {treat_missing_as_default = false, settings = {
					["caveground"] = {},
					["out-of-map"] = {},
				  }},
				},
				property_expression_names = {
					["tile:caveground:probability"] = 0, -- basic floor
				}
			}
			
			subsurface = game.create_surface(subsurface_name, mgs)
			
			subsurface.daytime = 0.5
			subsurface.freeze_daytime = true
			subsurface.show_clouds = false
		end
		global.subsurfaces[surface.index] = subsurface
		global.exposed_chunks[subsurface.index] = global.exposed_chunks[subsurface.index] or {}
		return subsurface
	else return nil
	end
end
function get_oversurface(subsurface)
	for i,s in pairs(global.subsurfaces) do -- i is the index of the oversurface
		if s == subsurface and game.get_surface(i) then return game.get_surface(i) end
	end
	return nil
end
function get_top_surface(subsurface)
	local _, _, topname, depth = string.find(subsurface.name, "(.+)_subsurface_([0-9]+)$")
	if topname == nil then return subsurface -- surface is not a subsurface
	else return game.get_surface(topname) end
end
function get_subsurface_depth(surface)
	if type(surface) == "table" then surface = surface.name end
	local _, _, _, depth = string.find(surface, "(.+)_subsurface_([0-9]+)$")
	return tonumber(depth or 0)
end

function is_subsurface(surface)
	local name = ""
	if type(surface) == "table" then name = surface.name
	elseif type(surface) == "string" then name = surface
	elseif type(surface) == "number" then name = game.get_surface(surface).name
	end
	
	if string.find(name, "_subsurface_([0-9]+)$") or 0 > 1 then return true
	else return false end
end

function clear_subsurface(surface, pos, radius, clearing_radius)
	if not is_subsurface(surface) then return 0 end
	local new_tiles = {}
	local new_resource_positions = {}
	local walls_destroyed = 0
	local area = get_area(pos, radius)

	if clearing_radius and clearing_radius < radius then -- destroy all entities in this radius except players
		local clearing_subsurface_area = get_area(pos, clearing_radius)
		for _,entity in ipairs(surface.find_entities(clearing_subsurface_area)) do
			if entity.type ~="player" then entity.destroy()
			else entity.teleport(get_safe_position(pos, {x=pos.x + clearing_radius, y = pos.y})) end
		end
	end
	
	for x, y in iarea(area) do -- first, replace all out-of-map tiles with their hidden tile (which means that it is inside map limits)
		if (x-pos.x)^2 + (y-pos.y)^2 < radius^2 and surface.get_hidden_tile({x, y}) then
			local wall = surface.find_entity("subsurface-wall", {x, y})
			if wall then
				wall.destroy()
				walls_destroyed = walls_destroyed + 1
			end
			table.insert(new_tiles, {name = surface.get_hidden_tile({x, y}), position = {x, y}})
			table.insert(new_resource_positions, {x, y})
			surface.set_hidden_tile({x, y}, nil)
		end
	end
	surface.set_tiles(new_tiles)
	place_resources(surface, new_resource_positions)
	
	for x, y in iarea(area) do -- second, place a wall where at least one out-of-map is adjacent
		if surface.get_tile(x, y).valid and surface.get_tile(x, y).name == "out-of-map" and not surface.find_entity("subsurface-wall", {x, y}) and not surface.find_entity("subsurface-wall-map-border", {x, y}) then
			if (surface.get_tile(x+1, y).valid and surface.get_tile(x+1, y).name ~= "out-of-map")
			or (surface.get_tile(x-1, y).valid and surface.get_tile(x-1, y).name ~= "out-of-map")
			or (surface.get_tile(x, y+1).valid and surface.get_tile(x, y+1).name ~= "out-of-map")
			or (surface.get_tile(x, y-1).valid and surface.get_tile(x, y-1).name ~= "out-of-map") then
				if surface.get_hidden_tile({x, y}) then
					surface.create_entity{name = "subsurface-wall", position = {x, y}, force=game.forces.neutral}
				else
					surface.create_entity{name = "subsurface-wall-map-border", position = {x, y}, force=game.forces.neutral}
				end
			end
		end
	end
	
	return walls_destroyed
end

script.on_event(defines.events.on_tick, function(event)
	
	-- handle prospectors
	for i,p in ipairs(global.prospectors) do
		if p.valid and p.products_finished == 1 then
			p.active = false
			prospect_resources(p)
			table.remove(global.prospectors, i)
		end
	end
	
	handle_elevators(event.tick)
	
	-- POLLUTION (since there is no mechanic to just reflect pollution (no absorption but also no spread) we have to do it for our own. The game's mechanic can't be changed so we need to consider it)
	if (event.tick - 1) % 64 == 0 then
		
		for _,subsurface in pairs(global.subsurfaces) do
			-- chunks that are not exposed but polluted distribute their pollution back to a chunk that is polluted (amount is proportional to adjacent chunks pollution)
			--for cx,cyt in pairs(global.exposed_chunks[subsurface.index] or {}) do
				--for cy,expval in pairs(cyt) do
				for chunk in subsurface.get_chunks() do
					local cx = chunk.x
					local cy = chunk.y
					local pollution = subsurface.get_pollution{cx*32, cy*32}
					if pollution > 0 and subsurface.count_tiles_filtered{area=chunk.area, name="out-of-map"} == 1024 then
						local north = subsurface.get_pollution{cx*32, (cy-1)*32}
						local south = subsurface.get_pollution{cx*32, (cy+1)*32}
						local east = subsurface.get_pollution{(cx+1)*32, cy*32}
						local west = subsurface.get_pollution{(cx-1)*32, cy*32}
						local total = north + south + east + west
						if total > 0 then
							subsurface.pollute({cx*32, (cy-1)*32}, pollution*north/total)
							subsurface.pollute({cx*32, (cy+1)*32}, pollution*south/total)
							subsurface.pollute({(cx+1)*32, cy*32}, pollution*east/total)
							subsurface.pollute({(cx-1)*32, cy*32}, pollution*west/total)
							subsurface.pollute({cx*32, cy*32}, -pollution)
						end
					end
				end
			--end
			
			-- machine inefficiency due to pollution
			for _,e in ipairs(subsurface.find_entities_filtered{type=attrition_types}) do
				if subsurface.get_pollution(e.position) > attrition_threshold and math.random(5) == 1 then e.damage(e.prototype.max_health*0.01, game.forces.neutral, "physical") end
			end
			
		end
		
		-- next, move pollution using air vents
		for i,vent in ipairs(global.air_vents) do
			if vent.valid then
				local subsurface = get_subsurface(vent.surface)
				if vent.name == "active-air-vent" and vent.energy > 0 then
					local current_energy = vent.energy -- 918.5285 if full
					local max_energy = 918.5285
					local max_movable_pollution = max_pollution_move_active * (0.8 ^ (get_subsurface_depth(subsurface) - 1)) * current_energy / max_energy -- how much polution can be moved with the current available energy
					
					local pollution_to_move = math.min(max_movable_pollution, subsurface.get_pollution(vent.position))
					
					subsurface.pollute(vent.position, -pollution_to_move)
					vent.surface.pollute(vent.position, pollution_to_move)
					
					if pollution_to_move > 0 then
						vent.active = true
						vent.surface.create_trivial_smoke{name="light-smoke", position={vent.position.x+0.25, vent.position.y}, force=game.forces.neutral}
					else
						vent.active = false
					end
				elseif vent.name == "air-vent" then
					local pollution_surface = vent.surface.get_pollution(vent.position)
					local pollution_subsurface = subsurface.get_pollution(vent.position)
					local diff = pollution_surface - pollution_subsurface
					local max_movable_pollution = max_pollution_move_passive * (0.8 ^ (get_subsurface_depth(subsurface) - 1))
					
					if math.abs(diff) > max_movable_pollution then
						diff = diff / math.abs(diff) * max_movable_pollution
					end

					if diff < 0 then -- pollution in subsurface is higher
						vent.surface.create_trivial_smoke{name="light-smoke", position={vent.position.x, vent.position.y}, force=game.forces.neutral}
					end

					vent.surface.pollute(vent.position, -diff)
					subsurface.pollute(vent.position, diff)
				end
			else
				table.remove(global.air_vents, i)
			end
		end
		
		-- player suffocation damage
		for _,p in pairs(game.players) do
			if p.connected and is_subsurface(p.surface) and p.surface.get_pollution(p.position) > suffocation_threshold then
				p.character.damage(suffocation_damage, game.forces.neutral, "poison")
				if (event.tick - 1) % 256 == 0 then p.print({"subsurface.suffocation"}, {1, 0, 0}) end
			end
		end
		
	end
	
	-- handle miners
	if remote.interfaces["aai-programmable-vehicles"] and event.tick % 10 == 0 then handle_miners(event.tick) end
end)

function cancel_placement(entity, player_index, text)
	if player_index then
		local player = game.get_player(player_index)
		if text then player.create_local_flying_text{text={text}, position=entity.position} end
		player.play_sound{path="utility/cannot_build", position=entity.position}
		player.mine_entity(entity, true)
	else -- robot built it
		entity.surface.play_sound{path="utility/cannot_build", position=entity.position}
		entity.order_deconstruction(entity.force)
	end
end

-- build entity only if it is safe in subsurface
function build_safe(event, func, check_for_entities)
	if check_for_entities == nil then check_for_entities = true end
	
	-- first, check if the given area is uncovered (ground tiles) and has no entities in it
	local entity = event.created_entity
	local subsurface = get_subsurface(entity.surface)
	local area = entity.bounding_box
	local safe_position = true
	if not is_subsurface(subsurface) then safe_position = false end
	if not subsurface.is_chunk_generated{entity.position.x / 32, entity.position.y / 32} then safe_position = false end
	for _,t in ipairs(subsurface.find_tiles_filtered{area=area}) do
		if t.name == "out-of-map" then safe_position = false end
	end
	if check_for_entities and subsurface.count_entities_filtered{area=area} > 0 then safe_position = false end
	
	if safe_position then func()
	else cancel_placement(entity, event.player_index, "subsurface.cannot-place-here")
	end
	
end
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
	local entity = event.created_entity
	if entity.name == "surface-drill-placer" then
		local text = ""
		if is_subsurface(entity.surface) and get_subsurface_depth(entity.surface) >= settings.global["subsurface-limit"].value then
			text = "subsurface.limit-reached"
		elseif entity.surface.count_entities_filtered{name={"tunnel-entrance", "tunnel-exit"}, position=entity.position, radius=7} > 0 then
			text = "subsurface.cannot-place-here"
		elseif string.find(entity.surface.name, "[Ff]actory[- ]floor") or 0 > 1 then -- prevent placement in factorissimo
			text = "subsurface.only-allowed-on-terrain"
		end
		
		if text == "" then
			entity.surface.create_entity{name="subsurface-hole", position=entity.position, amount=100 * (2 ^ (get_subsurface_depth(entity.surface) - 1))}
			local real_drill = entity.surface.create_entity{name="surface-drill", position=entity.position, direction=entity.direction, force=entity.force, player=(event.player_index or nil)}
			entity.destroy()
			get_subsurface(real_drill.surface).request_to_generate_chunks(real_drill.position, 3)
		else cancel_placement(entity, event.player_index, text)
		end
	elseif entity.name == "prospector" then table.insert(global.prospectors, entity)
	elseif string.sub(entity.name, 1, 13) == "item-elevator" then elevator_built(entity)
	elseif entity.name == "fluid-elevator-input" then elevator_built(entity, event.tags)
	elseif entity.name == "heat-elevator" then elevator_built(entity, event.tags)
	elseif entity.name == "air-vent" or entity.name == "active-air-vent" then
		build_safe(event, function()
			table.insert(global.air_vents, entity)
			if not is_subsurface(entity.surface) then -- draw light in subsurface, but only if air vent is placed on surface
				global.air_vent_lights[script.register_on_entity_destroyed(entity)] = rendering.draw_light{surface=get_subsurface(entity.surface), target=entity.position, sprite="utility/light_small"}
			end
		end, false)
	elseif entity.name == "wooden-support" then
		script.register_on_entity_destroyed(entity)
		global.support_lamps[entity.unit_number] = entity.surface.create_entity{name="support-lamp", position=entity.position}
	elseif is_subsurface(entity.surface)
	and (entity.type == "electric-pole"
	or entity.type == "rocket-silo"
	or entity.name == "rsc-silo-stage1"
	or entity.name == "rsc-silo-stage1-sesprs"
	or entity.name == "rsc-silo-stage1-serlp")
	then cancel_placement(entity, event.player_index) -- prevent some entities from being placed in subsurfaces
	end
end)

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, function(event)
	if event.entity.name == "surface-drill" then
		if event.entity.mining_target then event.entity.mining_target.destroy() end
	elseif event.entity.name == "subsurface-wall" then
		clear_subsurface(event.entity.surface, event.entity.position, 1.5)
	end
end)

script.on_event(defines.events.on_player_configured_blueprint, function(event)
	local item = game.get_player(event.player_index).cursor_stack
	if item.valid_for_read then
		local contents = item.get_blueprint_entities()
		for _,e in ipairs(contents or {}) do
			if e.name == "surface-drill" then e.name = "surface-drill-placer"
			elseif e.name == "fluid-elevator-output" then
				e.name = "fluid-elevator-input"
				e.tags = {type=0}
			elseif e.name == "fluid-elevator-input" then
				e.tags = {type=1}
			end
		end
		item.set_blueprint_entities(contents)
	end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
	local player = game.get_player(event.player_index)
	for _,r in ipairs(global.placement_indicators[player.index] or {}) do
		rendering.destroy(r)
	end
	
	aai_cursor_stack_changed(player)
	elevator_on_cursor_stack_changed(player)
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
	local player = game.get_player(event.player_index)
	for _,r in ipairs(global.selection_indicators[event.player_index] or {}) do
		rendering.destroy(r)
	end
	if player.selected then
		if string.sub(player.selected.name, 1, 13) == "item-elevator" or player.selected.name == "fluid-elevator-input" or player.selected.name == "fluid-elevator-output" or player.selected.name == "heat-elevator" then
			elevator_selected(player, player.selected)
		end
	end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
	local player = game.get_player(event.player_index)
	for _,r in ipairs(global.placement_indicators[player.index] or {}) do
		rendering.destroy(r)
	end
	
	aai_cursor_stack_changed(player)
	elevator_on_cursor_stack_changed(player)
end)

script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	if entity.name == "surface-drill" then
		-- destroy this entity and create a placer_dummy ghost, which we need to revive with the correct item
		if entity.mining_target then entity.mining_target.destroy() end
		local placer_dummy = entity.surface.create_entity{name="surface-drill-placer", position=entity.position, direction=entity.direction, force=entity.force}
		entity.destroy()
		placer_dummy.surface.create_entity{name="massive-explosion", position=placer_dummy.position}
		placer_dummy.die(event.force, event.cause)
	elseif entity.name == "fluid-elevator-output" then
		local ghost = entity.surface.create_entity{name="entity-ghost", position=entity.position, direction=entity.direction, force=entity.force, inner_name="fluid-elevator-input", expires=true}
		ghost.tags = {type=0}
	end
end)
script.on_event(defines.events.on_post_entity_died, function(event)
	if event.prototype.name == "fluid-elevator-input" then
		event.ghost.tags = {type=1}
	end
end)

script.on_event(defines.events.on_resource_depleted, function(event)
	if event.entity.name == "subsurface-hole" then
		local drill = event.entity.surface.find_entity("surface-drill", event.entity.position)
		if drill then
			local pos = drill.position
			
			-- oversurface entity placing
			local entrance_car = drill.surface.create_entity{name="tunnel-entrance", position=pos, force=drill.force} -- because Factorio sets the entity at -0.5, -0.5
			local entrance_pole = drill.surface.create_entity{name="tunnel-entrance-cable", position=pos, force=drill.force}
			
			-- subsurface entity placing
			local subsurface = get_subsurface(drill.surface)
			clear_subsurface(subsurface, pos, 4, 1.5)
			local exit_car = subsurface.create_entity{name="tunnel-exit", position=pos, force=drill.force} -- because Factorio sets the entity at -0.5, -0.5
			local exit_pole = subsurface.create_entity{name="tunnel-exit-cable", position=pos, force=drill.force}
			
			entrance_pole.connect_neighbour(exit_pole)
			entrance_pole.connect_neighbour{wire=defines.wire_type.red, target_entity=exit_pole, source_circuit_id=1, target_circuit_id=1}
			entrance_pole.connect_neighbour{wire=defines.wire_type.green, target_entity=exit_pole, source_circuit_id=1, target_circuit_id=1}
			
			global.pole_links[entrance_pole.unit_number] = exit_pole
			global.pole_links[exit_pole.unit_number] = entrance_pole
			global.car_links[entrance_car.unit_number] = exit_car
			global.car_links[exit_car.unit_number] = entrance_car
			
			script.register_on_entity_destroyed(entrance_pole)
			script.register_on_entity_destroyed(exit_pole)
			script.register_on_entity_destroyed(entrance_car)
			script.register_on_entity_destroyed(exit_car)
		end
	end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
	if is_subsurface(event.surface) then
		local newTiles = {}
		for x, y in iarea(event.area) do
			table.insert(newTiles, {name = "out-of-map", position = {x, y}})
			local tile = event.surface.get_tile(x, y)
			if tile.valid and tile.name ~= "out-of-map" then event.surface.set_hidden_tile({x, y}, tile.name) end
		end
		event.surface.set_tiles(newTiles)
	end
end)

script.on_event(defines.events.on_pre_surface_deleted, function(event)
	-- delete all its subsurfaces and remove from list
	local i = event.surface_index
	while(global.subsurfaces[i]) do -- if surface i has a subsurface
		local s = global.subsurfaces[i] -- s is that subsurface
		global.subsurfaces[i] = nil -- remove from list
		i = s.index
		game.delete_surface(s) -- delete s
	end
	if is_subsurface(game.get_surface(event.surface_index)) then -- remove this surface from list
		for s,ss in pairs(global.subsurfaces) do
			if ss.index == event.surface_index then global.subsurfaces[s] = nil end
		end
	end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
	-- entrances can't be mined, but in case they are destroyed by mods we have to handle it
	if global.pole_links[event.unit_number] and global.pole_links[event.unit_number].valid then
		local opposite_car = global.pole_links[event.unit_number].surface.find_entities_filtered{name={"tunnel-entrance", "tunnel-exit"}, position=global.pole_links[event.unit_number].position, radius=1}[1]
		if opposite_car and opposite_car.valid then opposite_car.destroy() end
		global.pole_links[event.unit_number].destroy()
		global.pole_links[event.unit_number] = nil
	elseif global.car_links[event.unit_number] and global.car_links[event.unit_number].valid then
		local opposite_pole = global.car_links[event.unit_number].surface.find_entities_filtered{name={"tunnel-entrance-cable", "tunnel-exit-cable"}, position=global.car_links[event.unit_number].position, radius=1}[1]
		if opposite_pole and opposite_pole.valid then opposite_pole.destroy() end
		global.car_links[event.unit_number].destroy()
		global.car_links[event.unit_number] = nil
	elseif global.air_vent_lights[event.registration_number] then
		rendering.destroy(global.air_vent_lights[event.registration_number])
		global.air_vent_lights[event.registration_number] = nil
	elseif global.support_lamps[event.unit_number] then
		global.support_lamps[event.unit_number].destroy()
 	end
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
	if event.effect_id == "cliff-explosives" then
		local surface = game.get_surface(event.surface_index)
		clear_subsurface(surface, event.target_position, 2.5)
		surface.spill_item_stack(event.target_position, {name="stone", count=20}, true, game.forces.neutral)
		surface.pollute(event.target_position, 10)
	elseif event.effect_id == "cave-sealing" then
		local surface = game.get_surface(event.surface_index)
		
		-- first, try to seal tunnel entrances
		local entrance = surface.find_entities_filtered{name={"tunnel-entrance", "tunnel-entrance-sealed-0", "tunnel-entrance-sealed-1", "tunnel-entrance-sealed-2"}, position=event.target_position, radius=3}[1]
		if entrance then
			local next_stage = {["tunnel-entrance"] = "tunnel-entrance-sealed-0", ["tunnel-entrance-sealed-0"] = "tunnel-entrance-sealed-1", ["tunnel-entrance-sealed-1"] = "tunnel-entrance-sealed-2", ["tunnel-entrance-sealed-2"] = "tunnel-entrance-sealed-3"}
			surface.create_entity{name=next_stage[entrance.name], position=entrance.position, force=game.forces.neutral}
			
			if entrance.name == "tunnel-entrance" then
				for x, y in iarea(get_area(event.target_position, 0.2)) do
					get_subsurface(surface).create_entity{name="subsurface-wall", position={x, y}, force=game.forces.neutral}
				end
			end
			
			entrance.destroy()
		elseif is_subsurface(surface) then -- place walls: first, set out-of-map tiles, then place walls on those spots that have at least one adjacent ground tile 
			local new_tiles = {}
			for x,y in iarea(get_area(event.target_position, 0.2)) do
				table.insert(new_tiles, {position={x, y}, name="out-of-map"})
				local tile = surface.get_tile(x ,y)
				if tile.name ~= "out-of-map" then surface.set_hidden_tile({x, y}, tile.hidden_tile or tile.name) end
			end
			surface.set_tiles(new_tiles)
			for x,y in iarea(get_area(event.target_position, 2)) do
				if surface.get_tile(x, y).name == "out-of-map"
				and (surface.get_tile(x+1, y).name ~= "out-of-map" or surface.get_tile(x-1, y).name ~= "out-of-map" or surface.get_tile(x, y+1).name ~= "out-of-map" or surface.get_tile(x, y-1).name ~= "out-of-map")
				and not surface.find_entity("subsurface-wall", {x, y}) then
					surface.create_entity{name="subsurface-wall", position={x, y}, force=game.forces.neutral}
					for i=1,100,1 do surface.create_trivial_smoke{name="subsurface-smoke", position={x + (math.random(-20, 20) / 20), y + (math.random(-21, 19) / 20)}} end
				end
			end
			surface.pollute(event.target_position, 5)
		end
	end
end)

script.on_event("subsurface-position", function(event)
	local force = game.get_player(event.player_index).force
	local surface = game.get_player(event.player_index).surface
	if get_oversurface(surface) then force.print("[gps=".. string.format("%.1f,%.1f,", event.cursor_position.x, event.cursor_position.y) .. get_oversurface(surface).name .."]") end
	if get_subsurface(surface, false) then force.print("[gps=".. string.format("%.1f,%.1f,", event.cursor_position.x, event.cursor_position.y) .. get_subsurface(surface, false).name .."]") end
end)

script.on_event("subsurface-rotate", function(event)
	local player = game.get_player(event.player_index)
	if player.selected then
		for _,r in ipairs(global.selection_indicators[event.player_index] or {}) do
			rendering.destroy(r)
		end
		elevator_rotated(player.selected, player.selected.direction)
		if player.selected then elevator_selected(player, player.selected) end
	end
end)
