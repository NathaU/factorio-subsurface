require "util"
math2d = require "math2d"
require "scripts.lib"
require "scripts.remote"
require "scripts.cutscene"
require "scripts.aai-miners"
require "scripts.resources"
require "scripts.elevators"
require "scripts.enemies"
require "scripts.trains"

max_pollution_move_passive = 64

suffocation_threshold = 400
suffocation_damage = 2.5 -- per 64 ticks (~1 second)
attrition_threshold = 150
attrition_types = {"assembling-machine", "reactor", "mining-drill", "generator", "inserter", "burner-generator", "car", "construction-robot", "lab", "loader", "loader-1x1", "locomotive", "logistic-robot", "power-switch", "pump", "radar", "roboport", "spider-vehicle", "splitter", "transport-belt"}

aai_miners = script.active_mods["aai-vehicles-miner"] ~= nil

subsurface_wall_expressions = {}
subsurface_wall_names = {"subsurface-wall"}

blacklist = {}

function setup_globals()
	storage.subsurfaces = storage.subsurfaces or {}
	storage.pole_links = storage.pole_links or {}
	storage.car_links = storage.car_links or {}
	storage.heat_elevators = storage.heat_elevators or {}
	storage.air_vents = storage.air_vents or {}
	storage.aai_digging_miners = storage.aai_digging_miners or {}
	storage.prospectors = storage.prospectors or {}
	storage.support_lamps = storage.support_lamps or {}
	storage.placement_indicators = storage.placement_indicators or {}
	storage.selection_indicators = storage.selection_indicators or {}
	storage.next_burrowing = storage.next_burrowing or game.map_settings.enemy_expansion.max_expansion_cooldown
	if not storage.enemies_above_exposed_underground then init_enemies_global() end
	storage.revealed_resources = storage.revealed_resources or {}
	storage.train_subways = storage.train_subways or {}
	storage.train_transport = storage.train_transport or {}
	storage.train_stop_clones = storage.train_stop_clones or {}
	storage.wall_scanners = storage.wall_scanners or {}
end

function register_subsurface_walls()
	for interface, functions in pairs(remote.interfaces) do
		if functions["subsurface_register_walls"] then
			subsurface_wall_expressions = util.merge({subsurface_wall_expressions, remote.call(interface, "subsurface_register_walls")})
		end
	end

	for k, _ in pairs(subsurface_wall_expressions) do
		table.insert(subsurface_wall_names, k)
	end
end

script.on_init(function()
	setup_globals()
	for _, s in pairs(game.surfaces) do
		if allow_subsurfaces(s) then manipulate_resource_data(s) end
	end
	
	register_subsurface_walls()
	
	if remote.interfaces["space-exploration"] then
		script.on_event("se-remote-view", function(event)
			on_remote_view_started(game.get_player(event.player_index))
		end)
	end
end)
script.on_configuration_changed(function(config) -- TBC
	setup_globals()
	
	if config.mod_changes then
		if config.mod_changes["BlackMap-continued"] and not config.mod_changes["BlackMap-continued"].old_version then
			for _, s in pairs(storage.subsurfaces) do
				remote.call("blackmap", "register", s)
			end
		end

		for ac, _ in pairs(prototypes.autoplace_control) do
			local creating_mod = prototypes.get_history("autoplace-control", ac).created
			if config.mod_changes[creating_mod] and not config.mod_changes[creating_mod].old_version and prototypes.autoplace_control[ac].category == "resource" then
				for _, s in pairs(game.surfaces) do
					if not is_subsurface(s) and allow_subsurfaces(s) and s.map_gen_settings.autoplace_controls and s.map_gen_settings.autoplace_controls[control_name] then
						local mgs = s.map_gen_settings
						mgs.autoplace_controls[control_name].size = (mgs.autoplace_controls[control_name].size or 0) * size_formula(0)
						mgs.autoplace_controls[control_name].richness = (mgs.autoplace_controls[control_name].richness or 0) * richness_formula(0)
						s.map_gen_settings = mgs
					end
				end
			end
		end

		for _, s in pairs(storage.subsurfaces) do
			local mgs = s.map_gen_settings
			copy_resource_data(mgs, get_top_surface(s), get_subsurface_depth(s))
			s.map_gen_settings = mgs
		end
	end
	
	-- handle too much tiles
	local found = false
	local substitute = (prototypes.tile["mineral-brown-dirt-2"] or prototypes.tile["grass-4"]).name
	for _, s in pairs(storage.subsurfaces) do
		local new_tiles = {}
		for _, t in ipairs(s.find_tiles_filtered{name = "grass-1"}) do
			table.insert(new_tiles, {name = substitute, position = t.position})
			found = true
		end
		s.set_tiles(new_tiles)
		for _, t in ipairs(s.find_tiles_filtered{name = "out-of-map", has_hidden_tile = true}) do
			if t.hidden_tile == "grass-1" then
				s.set_hidden_tile(t.position, substitute)
				found = true
			end
		end
	end
	if found then game.print("[font=default-large-bold][color=yellow]Subsurface: At least one tile generated in subsurfaces was removed from the game due to your mod configuration changes. It has been replaced with dirt-like tiles.[/color][/font]") end
end)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == "enable-quality" then
		for _, s in pairs(storage.subsurfaces) do
			local effect = s.global_effect
			if settings.global["enable-quality"].value then effect.quality = 0.1 * get_subsurface_depth(s) else effect.quality = nil end
			s.global_effect = effect
		end
	end
end)

script.on_load(function()
	register_subsurface_walls()
	
	if remote.interfaces["space-exploration"] then
		script.on_event("se-remote-view", function(event)
			on_remote_view_started(game.get_player(event.player_index))
		end)
	end
end)

function get_subsurface(surface, create)
	if create == nil then create = true end
	if storage.subsurfaces[surface.index] then -- the subsurface already exists
		return storage.subsurfaces[surface.index]
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
		
		local top_surface = game.get_surface(topname)
		local subsurface = game.get_surface(subsurface_name)
		if not subsurface then
			
			local mgs = {
				seed = surface.map_gen_settings.seed,
				width = surface.map_gen_settings.width,
				height = surface.map_gen_settings.height,
				peaceful_mode = surface.map_gen_settings.peaceful_mode,
				no_enemies_mode = surface.map_gen_settings.no_enemies_mode,
				autoplace_controls = {},
				default_enable_all_autoplace_controls = false,
				autoplace_settings = {
				  decorative = {treat_missing_as_default = false, settings = {
					["small-rock"] = {},
					["tiny-rock"] = {}
				  }},
				  tile = {treat_missing_as_default = false, settings = {
					["caveground"] = {},
					["mineral-brown-dirt-2"] = {},
					["grass-4"] = {},
					["out-of-map"] = {},
				  }},
				  entity = {treat_missing_as_default = false, settings = {}}
				},
				property_expression_names = { -- priority is from top to bottom
					["tile:caveground:probability"] = 0, -- basic floor
					["tile:mineral-brown-dirt-2:probability"] = 0, -- alternative if alienbiomes is active
					["tile:grass-4:probability"] = 0, -- 2nd alternative
					["decorative:small-rock:probability"] = 0.1,
					["decorative:tiny-rock:probability"] = 0.7,

					["subsurface_seed"] = bit32.band(bit32.bxor(simple_hash(subsurface_name), surface.map_gen_settings.seed), 0xFFFFFFF),
					["subsurface_level"] = depth,
				}
			}
			copy_resource_data(mgs, top_surface, depth)
			
			subsurface = game.create_surface(subsurface_name, mgs)
			
			subsurface.daytime = 0.5
			subsurface.freeze_daytime = true
			subsurface.show_clouds = false
			subsurface.localised_name = {"subsurface.subsurface-name", top_surface.localised_name or topname, depth}

			for sp, _ in pairs(prototypes.surface_property) do
				subsurface.set_property(sp, surface.get_property(sp))
			end
			subsurface.set_property("subsurface-level", depth)

			local effect = surface.global_effect or {}
			effect.productivity = 0.05 * depth
			effect.speed = 0.05 * depth
			effect.consumption = 0.1 * depth
			effect.pollution = 0.1 * depth
			if settings.global["enable-quality"].value then effect.quality = 0.1 * depth end
			subsurface.global_effect = effect
			
			if remote.interfaces["blackmap"] then remote.call("blackmap", "register", subsurface) end
			
			storage.enemies_above_exposed_underground[surface.index] = {}
			
		end
		storage.subsurfaces[surface.index] = subsurface
		return subsurface
	else return nil
	end
end
function get_oversurface(subsurface)
	for i, s in pairs(storage.subsurfaces) do -- i is the index of the oversurface
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
	if type(surface) == "userdata" then surface = surface.name end
	local _, _, _, depth = string.find(surface, "(.+)_subsurface_([0-9]+)$")
	return tonumber(depth or 0)
end

function is_subsurface(surface)
	local name = ""
	if type(surface) == "userdata" then name = surface.name
	elseif type(surface) == "string" then name = surface
	elseif type(surface) == "number" then name = game.get_surface(surface).name
	end
	
	if string.find(name, "_subsurface_([0-9]+)$") or 0 > 1 then return true
	else return false end
end

function create_walls(surface, positions)
	local props = {}
	local names_ordered = {}
	for name, expr in pairs(subsurface_wall_expressions) do
		table.insert(names_ordered, name)
		table.insert(props, expr)
	end
	local calcresult = surface.calculate_tile_properties(props, positions)
	for pos_i, pos in ipairs(positions) do
		local name = "subsurface-wall"
		local prio = 0
		for j, p in ipairs(props) do
			if calcresult[p][pos_i] > prio then
				name = names_ordered[j]
				prio = calcresult[p][pos_i]
			end
		end
		surface.create_entity{name = name, position = pos, force = game.forces.neutral}
	end
end

function clear_subsurface(surface, pos, radius, clearing_radius, return_inventory)
	if not is_subsurface(surface) then return 0 end
	pos = math2d.position.ensure_xy(pos)
	local new_tiles = {}
	local new_resource_positions = {}
	local area = get_area(pos, radius)

	if clearing_radius and clearing_radius < radius then -- destroy all entities in this radius except players
		local clearing_subsurface_area = get_area(pos, clearing_radius)
		for _, entity in ipairs(surface.find_entities(clearing_subsurface_area)) do
			if entity.type ~= "player" then entity.destroy()
			else entity.teleport(get_safe_position(pos, {x = pos.x + clearing_radius, y = pos.y})) end
		end
	end
	
	local inventory = game.create_inventory(10)	
	for x, y in iarea(area) do -- first, replace all out-of-map tiles with their hidden tile which means that it is inside map limits)
		if (x-pos.x)^2 + (y-pos.y)^2 < radius^2 and surface.get_hidden_tile({x, y}) then
			local wall = surface.find_entities_filtered{name = subsurface_wall_names, position = {x, y}}[1]
			if wall then
				wall.mine{inventory = return_inventory and inventory or nil, force = true, raise_destroyed = false, ignore_minable = true}
			end
			table.insert(new_tiles, {name = surface.get_hidden_tile({x, y}), position = {x, y}})
			surface.set_hidden_tile({x, y}, nil)
			table.insert(new_resource_positions, {x, y})
		end
	end
	surface.set_tiles(new_tiles)
	place_resources(surface, new_resource_positions)
	
	local new_wall_positions = {}
	for x, y in iarea(area) do -- second, place a wall where at least one out-of-map is adjacent
		if surface.get_tile(x, y).valid and surface.get_tile(x, y).name == "out-of-map" and not surface.find_entities_filtered{name = subsurface_wall_names, position = {x, y}}[1] and not surface.find_entity("subsurface-wall-map-border", {x, y}) then
			if (surface.get_tile(x+1, y).valid and surface.get_tile(x+1, y).name ~= "out-of-map")
			or (surface.get_tile(x-1, y).valid and surface.get_tile(x-1, y).name ~= "out-of-map")
			or (surface.get_tile(x, y+1).valid and surface.get_tile(x, y+1).name ~= "out-of-map")
			or (surface.get_tile(x, y-1).valid and surface.get_tile(x, y-1).name ~= "out-of-map") then
				if surface.get_hidden_tile({x, y}) then
					table.insert(new_wall_positions, {x, y})
				else
					local w = surface.create_entity{name = "subsurface-wall-map-border", position = {x, y}, force = game.forces.neutral}
					w.destructible = false
				end
			end
		end
	end
	create_walls(surface, new_wall_positions)
	
	find_enemies_above(surface, pos, radius)
	
	if return_inventory then return inventory
	else inventory.destroy() end
end

script.on_event(defines.events.on_tick, function(event)
	
	-- handle prospectors
	for i, p in ipairs(storage.prospectors) do
		if p.valid and is_subsurface(p.surface) and p.products_finished == 1 then
			p.active = false
			prospect_resources(p)
			table.remove(storage.prospectors, i)
		end
	end

	-- handle wall scanners
	for i, scanner in ipairs(storage.wall_scanners) do
		if scanner.valid and is_subsurface(scanner.surface) then
			if event.tick % 60 == 0 then
				local walls = scanner.surface.find_entities_filtered{name = subsurface_wall_names, position = scanner.position, radius = 32}
				if #walls > 0 then
					for _, w in ipairs(walls) do
						w.order_deconstruction(scanner.force)
					end
				else
					scanner.order_deconstruction(scanner.force)
				end
			end
		else
			table.remove(storage.wall_scanners, i)
		end
	end
	
	handle_elevators(event.tick)

	handle_subways()
	
	-- POLLUTION (since there is no mechanic to just reflect pollution (no absorption but also no spread) we have to do it for our own. The game's mechanic can't be changed so we need to consider it)
	if (event.tick - 1) % 64 == 0 then
		
		for _, subsurface in pairs(storage.subsurfaces) do
			for chunk in subsurface.get_chunks() do
				local cx = chunk.x
				local cy = chunk.y
				local pollution = subsurface.get_pollution{cx*32, cy*32}
				if pollution > 0 and subsurface.count_tiles_filtered{area = chunk.area, name = "out-of-map"} == 1024 then
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
			
			-- machine inefficiency due to pollution
			if not settings.global["disable-autoplace-manipulation"].value then
				for _, e in ipairs(subsurface.find_entities_filtered{type = attrition_types}) do
					if subsurface.get_pollution(e.position) > attrition_threshold and math.random(5) == 1 then e.damage(e.max_health * 0.01, game.forces.neutral, "physical") end
				end
			end
			
		end
		
		-- next, move pollution using air vents
		for i, vent in ipairs(storage.air_vents) do
			if vent.valid then
				local subsurface = get_subsurface(vent.surface, false)
				if subsurface and vent.name == "air-vent" then
					local pollution_surface = vent.surface.get_pollution(vent.position)
					local pollution_subsurface = subsurface.get_pollution(vent.position)
					local diff = pollution_surface - pollution_subsurface
					local max_movable_pollution = max_pollution_move_passive * (0.8 ^ (get_subsurface_depth(subsurface) - 1))
					
					if math.abs(diff) > max_movable_pollution then
						diff = diff / math.abs(diff) * max_movable_pollution
					end

					if diff < 0 then -- pollution in subsurface is higher
						vent.surface.create_trivial_smoke{name = "light-smoke", position = {vent.position.x, vent.position.y}, force = game.forces.neutral}
					end

					vent.surface.pollute(vent.position, -diff, vent.name)
					subsurface.pollute(vent.position, diff, vent.name)
				elseif subsurface and vent.energy > 0 then
					local current_energy = vent.energy
					local max_energy = vent.prototype.electric_energy_source_prototype.buffer_capacity
					local max_movable_pollution = vent.crafting_speed * (0.8 ^ (get_subsurface_depth(subsurface) - 1)) * current_energy / max_energy -- how much polution can be moved with the current available energy
					
					local pollution_to_move = math.min(max_movable_pollution, subsurface.get_pollution(vent.position))
					
					subsurface.pollute(vent.position, -pollution_to_move, vent.name)
					vent.surface.pollute(vent.position, pollution_to_move, vent.name)
					
					if pollution_to_move > 0 then
						vent.surface.create_trivial_smoke{name = "light-smoke", position = {vent.position.x+0.25, vent.position.y}, force = game.forces.neutral}
					end
				end
			else
				table.remove(storage.air_vents, i)
			end
		end
		
		-- player suffocation damage
		if not settings.global["disable-autoplace-manipulation"].value then
			for _, p in pairs(game.players) do
				if p.character and is_subsurface(p.surface) and p.surface.get_pollution(p.position) > suffocation_threshold then
					p.character.damage(suffocation_damage, game.forces.neutral, "poison")
					if (event.tick - 1) % 256 == 0 then p.print({"subsurface.suffocation"}, {1, 0, 0}) end
				end
			end
		end
		
	end
	
	-- handle miners
	if aai_miners and event.tick % 10 == 0 then handle_miners(event.tick) end
	
	if event.tick % 20 == 0 and not settings.global["disable-autoplace-manipulation"].value and game.map_settings.enemy_expansion.enabled then handle_enemies(event.tick) end
end)

function allow_subsurfaces(surface)
	if string.find(surface.name, "[Ff]actory[- ]floor") or 0 > 1 then -- prevent placement in factorissimo
		return false
	else
		for _, b in ipairs(blacklist) do
			if surface.name == b then return false end
		end
	end
	return true
end

function cancel_placement(event, text)
	local entity = event.entity
	if event.player_index then
		local player = game.get_player(event.player_index)
		if text then player.create_local_flying_text{text = {text}, position = entity.position} end
		player.play_sound{path = "utility/cannot_build", position = entity.position}
		local n = entity.name
		local q = entity.quality
		entity.destroy()
		for _, it in ipairs(event.consumed_items.get_contents()) do
			player.insert(it)
		end
		if not player.cursor_stack.valid_for_read then
			player.pipette_entity({name = n, quality = q})
		end
	else -- robot built it
		entity.surface.play_sound{path = "utility/cannot_build", position = entity.position}
		entity.surface.spill_item_stack{position = entity.position, stack = event.stack, force = event.robot.force, allow_belts = false}
		entity.destroy()
	end
end

-- build entity only if it is safe in subsurface
function build_safe(event, func, check_for_entities)
	if check_for_entities == nil then check_for_entities = true end
	
	-- first, check if the given area is uncovered (ground tiles) and has no entities in it
	local entity = event.entity
	local subsurface = get_subsurface(entity.surface)
	local area = entity.bounding_box
	local safe_position = true
	if not is_subsurface(subsurface) then safe_position = false end
	if not subsurface.is_chunk_generated{entity.position.x / 32, entity.position.y / 32} then safe_position = false end
	for _, t in ipairs(subsurface.find_tiles_filtered{area = area}) do
		if t.name == "out-of-map" then safe_position = false end
	end
	if check_for_entities and subsurface.count_entities_filtered{area = area} > 0 then safe_position = false end
	
	if safe_position then func()
	else cancel_placement(event, "subsurface.cannot-place-here")
	end
	
end
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
	local entity = event.entity
	if entity.name == "surface-drill-placer" then
		local text = ""
		if is_subsurface(entity.surface) and get_subsurface_depth(entity.surface) >= settings.global["subsurface-limit"].value then
			text = "subsurface.limit-reached"
		elseif entity.surface.count_entities_filtered{name = {"tunnel-entrance", "tunnel-exit"}, position = entity.position, radius = 7} > 0 then
			text = "subsurface.cannot-place-here"
		elseif not allow_subsurfaces(entity.surface) then
			text = "subsurface.not-allowed-here"
		end
		
		if text == "" then

			local res_name = "subsurface-hole"
			local res_amount = 100 * (2 ^ (get_subsurface_depth(entity.surface) - 1))
			local res_prio = 0

			for interface, functions in pairs(remote.interfaces) do
				if functions["subsurface_hole_resource"] then
					local prio, name, amount = remote.call(interface, "subsurface_hole_resource", entity.surface, get_subsurface_depth(entity.surface), entity.position)
					if prio > res_prio then
						res_name = name
						res_amount = amount
						res_prio = prio
					end
				end
			end

			entity.surface.create_entity{name = res_name, position = entity.position, amount = res_amount}
			local real_drill = entity.surface.create_entity{name = "surface-drill", position = entity.position, direction = entity.direction, force = entity.force, player = entity.last_user, quality = entity.quality}
			entity.destroy()
			get_subsurface(real_drill.surface).request_to_generate_chunks(real_drill.position, 3)
		else cancel_placement(event, text)
		end
	elseif entity.name == "prospector" then table.insert(storage.prospectors, entity)
	elseif entity.name == "subsurface-wall-scanner" then table.insert(storage.wall_scanners, entity)
	elseif string.sub(entity.name, 1, 13) == "item-elevator" then elevator_built(entity)
	elseif entity.name == "fluid-elevator-input" then
		if event.tags and event.tags.output then entity = switch_elevator(entity) end
		elevator_built(entity)
	elseif entity.name == "heat-elevator" then
		entity.operable = false
		elevator_built(entity)
	elseif entity.name == "air-vent" or entity.name == "active-air-vent" or entity.name == "active-air-vent-2" then
		table.insert(storage.air_vents, entity)
	elseif entity.name == "wooden-support" or entity.name == "steel-support" then
		script.register_on_object_destroyed(entity)
		storage.support_lamps[entity.unit_number] = entity.surface.create_entity{name = "support-lamp", position = entity.position, quality = entity.quality, force = entity.force}
	elseif entity.name == "subway" then
		subway_built(entity)
		elevator_built(entity)
	elseif (entity.type == "train-stop" and entity.connected_rail and entity.connected_rail.name == "subway-rail") or ((entity.type == "rail-signal" or entity.type == "rail-chain-signal") and entity.get_connected_rails()[1] and entity.get_connected_rails()[1].name == "subway-rail") then
		cancel_placement(event, "cant-build-reason.cant-build-here")
	elseif entity.type == "train-stop" then
		create_fake_stops(entity)
	elseif is_subsurface(entity.surface) then -- check for placement restrictions, cancel placement if one of the consumed items has the hint in the description
		if not script.feature_flags["space_travel"] then
			for _, item in ipairs(event.consumed_items and event.consumed_items.get_contents() or {event.stack}) do
				if string.find(serpent.line(prototypes.item[item.name].localised_description), "placement%-restriction") then
					cancel_placement(event)
					break
				end
			end
		end
	end
end)

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, function(event)
	if event.entity.name == "surface-drill" then
		if event.entity.mining_target then event.entity.mining_target.destroy() end
	else
		for _, w in ipairs(subsurface_wall_names) do
			if event.entity.valid and event.entity.name == w then clear_subsurface(event.entity.surface, event.entity.position, 1.5) end
		end
	end
end)

script.on_event(defines.events.on_player_configured_blueprint, function(event)
	local item = game.get_player(event.player_index).cursor_stack
	if item.valid_for_read then
		local contents = item.get_blueprint_entities()
		for _, e in ipairs(contents or {}) do
			if e.name == "surface-drill" then e.name = "surface-drill-placer"
			elseif e.name == "fluid-elevator-output" then e.tags = {output = true} end
		end
		item.set_blueprint_entities(contents)
	end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
	elevator_on_cursor_stack_changed(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_selected_entity_changed, function(event)
	local player = game.get_player(event.player_index)
	for _, r in ipairs(storage.selection_indicators[event.player_index] or {}) do
		r.destroy()
	end
	if player.selected then elevator_selected(player, player.selected) end
end)

script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	if entity.name == "surface-drill" then
		if entity.mining_target then entity.mining_target.destroy() end
		entity.surface.create_entity{name = "massive-explosion", position = entity.position}
	end
end)
script.on_event(defines.events.on_post_entity_died, function(event)
	if event.prototype.name == "fluid-elevator-output" then event.ghost.tags = {output = true} end
end)

script.on_event(defines.events.on_resource_depleted, function(event)
	if event.entity.prototype.resource_category == "subsurface-hole" then
		local drill = event.entity.surface.find_entity("surface-drill", event.entity.position)
		if drill then
			local pos = drill.position
			
			-- oversurface entity placing
			local entrance_car = drill.surface.create_entity{name = "tunnel-entrance", position = pos, force = drill.force}
			local entrance_pole = drill.surface.create_entity{name = "tunnel-entrance-cable", position = pos, force = drill.force}
			entrance_car.destructible = false
			entrance_pole.destructible = false
			
			-- subsurface entity placing
			local subsurface = get_subsurface(drill.surface)
			clear_subsurface(subsurface, pos, 4, 1.5)
			local exit_car = subsurface.create_entity{name = "tunnel-exit", position = pos, force = drill.force}
			local exit_pole = subsurface.create_entity{name = "tunnel-exit-cable", position = pos, force = drill.force}
			exit_car.destructible = false
			exit_pole.destructible = false
			
			
			for w, wc in pairs(entrance_pole.get_wire_connectors()) do
				wc.connect_to(exit_pole.get_wire_connector(w), false, defines.wire_origin.script)
			end
			
			storage.pole_links[entrance_pole.unit_number] = exit_pole
			storage.pole_links[exit_pole.unit_number] = entrance_pole
			storage.car_links[entrance_car.unit_number] = exit_car
			storage.car_links[exit_car.unit_number] = entrance_car
			
			script.register_on_object_destroyed(entrance_pole)
			script.register_on_object_destroyed(exit_pole)
			script.register_on_object_destroyed(entrance_car)
			script.register_on_object_destroyed(exit_car)
			
			local temp_s = drill.surface
			repeat
				for _, stop in ipairs(temp_s.find_entities_filtered{type = "train-stop"}) do
					if stop.name ~= "subway-stop" then create_fake_stop(subsurface, stop) end
				end
				temp_s = get_oversurface(temp_s)
			until not temp_s
		end
	else
		local pos = {x = math.floor(event.entity.position.x), y = math.floor(event.entity.position.y)}
		local chunk_id = spiral({math.floor(pos.x / 32), math.floor(pos.y / 32)})
		local pos_i = get_position_index_in_chunk(pos)
		storage.revealed_resources[chunk_id] = storage.revealed_resources[chunk_id] or {}
		storage.revealed_resources[chunk_id][pos_i] = storage.revealed_resources[chunk_id][pos_i] or {}
		storage.revealed_resources[chunk_id][pos_i][event.entity.name] = 0
	end
end)

script.on_event(defines.events.on_chunk_generated, function(event)
	if is_subsurface(event.surface) then
		local set_tiles = {}
		local set_hidden_tiles = {}
		for x, y in iarea(event.area) do
			local tile = event.surface.get_tile(x, y)
			tile = tile.valid and tile.name or "out-of-map"
			
			table.insert(set_tiles, {name = "out-of-map", position = {x, y}})
			
			if tile ~= "out-of-map" then table.insert(set_hidden_tiles, {tile, {x, y}}) end
		end
		event.surface.set_tiles(set_tiles)
		for _, p in ipairs(set_hidden_tiles) do -- for performance reasons, first set the tiles and then the hidden tiles
			event.surface.set_hidden_tile(p[2], p[1])
		end
	end
end)

script.on_event(defines.events.on_pre_surface_deleted, function(event)
	-- delete all its subsurfaces and remove from list
	local i = event.surface_index
	while(storage.subsurfaces[i]) do -- if surface i has a subsurface
		local s = storage.subsurfaces[i] -- s is that subsurface
		storage.subsurfaces[i] = nil -- remove from list
		i = s.index
		game.delete_surface(s) -- delete s
	end
	if is_subsurface(game.get_surface(event.surface_index)) then -- remove this surface from list
		for s, ss in pairs(storage.subsurfaces) do
			if ss.index == event.surface_index then storage.subsurfaces[s] = nil end
		end
	end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
	-- entrances can't be mined, but in case they are destroyed by mods we have to handle it
	if storage.pole_links[event.useful_id] and storage.pole_links[event.useful_id].valid then
		local opposite_car = storage.pole_links[event.useful_id].surface.find_entities_filtered{name = {"tunnel-entrance", "tunnel-exit"}, position = storage.pole_links[event.useful_id].position, radius = 1}[1]
		if opposite_car and opposite_car.valid then opposite_car.destroy() end
		storage.pole_links[event.useful_id].destroy()
		storage.pole_links[event.useful_id] = nil
	elseif storage.car_links[event.useful_id] and storage.car_links[event.useful_id].valid then
		local opposite_pole = storage.car_links[event.useful_id].surface.find_entities_filtered{name = {"tunnel-entrance-cable", "tunnel-exit-cable"}, position = storage.car_links[event.useful_id].position, radius = 1}[1]
		if opposite_pole and opposite_pole.valid then opposite_pole.destroy() end
		storage.car_links[event.useful_id].destroy()
		storage.car_links[event.useful_id] = nil
	elseif storage.support_lamps[event.useful_id] then
		storage.support_lamps[event.useful_id].destroy()
	elseif storage.train_subways[event.useful_id] then
		subway_entity_destroyed(event.useful_id)
	elseif storage.train_stop_clones[event.useful_id] then
		for _, s in ipairs(storage.train_stop_clones[event.useful_id]) do s.destroy() end
		storage.train_stop_clones[event.useful_id] = nil
	end
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
	local surface = game.get_surface(event.surface_index)
	if event.effect_id == "cliff-explosives" then
		clear_subsurface(surface, event.target_position, 2.5)
		surface.spill_item_stack{position = event.target_position, stack = {name = "stone", count = 20}, enable_looted = true, force = game.forces.neutral}
		surface.pollute(event.target_position, 10)
	elseif event.effect_id == "cave-sealing" then
		
		-- first, try to seal tunnel entrances
		local entrance = surface.find_entities_filtered{name = {"tunnel-entrance", "tunnel-entrance-sealed-0", "tunnel-entrance-sealed-1", "tunnel-entrance-sealed-2"}, position = event.target_position, radius = 3}[1]
		if entrance then
			local next_stage = {["tunnel-entrance"] = "tunnel-entrance-sealed-0", ["tunnel-entrance-sealed-0"] = "tunnel-entrance-sealed-1", ["tunnel-entrance-sealed-1"] = "tunnel-entrance-sealed-2", ["tunnel-entrance-sealed-2"] = "tunnel-entrance-sealed-3"}
			local new_entrance = surface.create_entity{name = next_stage[entrance.name], position = entrance.position, force = game.forces.neutral}
			new_entrance.destructible = false
			
			if entrance.name == "tunnel-entrance" then create_walls(get_subsurface(surface), get_area_positions(get_area(event.target_position, 0.2))) end
			
			entrance.destroy()
		elseif is_subsurface(surface) then -- place walls: first, prevent resources from being restored, then set out-of-map tiles, then place walls on those spots that have at least one adjacent ground tile 
			for _, res in ipairs(surface.find_entities(get_area(event.target_position, 1))) do
				if res.type == "resource" then
					local x = math.floor(res.position.x)
					local y = math.floor(res.position.y)
					local chunk_id = spiral({math.floor(x / 32), math.floor(y / 32)})
					local pos_i = get_position_index_in_chunk({x, y})
					storage.revealed_resources[chunk_id] = storage.revealed_resources[chunk_id] or {}
					storage.revealed_resources[chunk_id][pos_i] = storage.revealed_resources[chunk_id][pos_i] or {}
					storage.revealed_resources[chunk_id][pos_i][res.name] = res.amount
				end
			end

			local set_tiles = {}
			local set_hidden_tiles = {}
			for x, y in iarea(get_area(event.target_position, 0.2)) do
				table.insert(set_tiles, {position = {x, y}, name = "out-of-map"})
				local tile = surface.get_tile(x, y)
				if tile.name ~= "out-of-map" then table.insert(set_hidden_tiles, {tile.hidden_tile or tile.name, {x, y}}) end
			end
			surface.set_tiles(set_tiles)
			for _, p in ipairs(set_hidden_tiles) do surface.set_hidden_tile(p[2], p[1]) end
			for x, y in iarea(get_area(event.target_position, 2)) do
				if surface.get_tile(x, y).name == "out-of-map"
				and (surface.get_tile(x+1, y).name ~= "out-of-map" or surface.get_tile(x-1, y).name ~= "out-of-map" or surface.get_tile(x, y+1).name ~= "out-of-map" or surface.get_tile(x, y-1).name ~= "out-of-map")
				and not surface.find_entities_filtered{name = subsurface_wall_names, position = {x, y}}[1] and not surface.find_entity("subsurface-wall-map-border", {x, y}) then
					create_walls(surface, {{x, y}})
					for i = 1, 100 do surface.create_trivial_smoke{name = "subsurface-smoke", position = {x + (math.random(-20, 20) / 20), y + (math.random(-21, 19) / 20)}} end
				end
			end
			surface.pollute(event.target_position, 5)
		end
	end
end)

script.on_event(defines.events.on_entity_renamed, function(event)
	if event.entity.type == "train-stop" and event.entity.name ~= "subway-stop" then
		for _, s in ipairs(storage.train_stop_clones[event.entity.unit_number] or {}) do s.backer_name = event.entity.backer_name end
	end
end)
script.on_event(defines.events.on_entity_color_changed, function(event)
	if event.entity.type == "train-stop" and not event.entity.name == "subway-stop" then
		for _, s in ipairs(storage.train_stop_clones[event.entity.unit_number] or {}) do s.color = event.entity.color end
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
		for _, r in ipairs(storage.selection_indicators[event.player_index] or {}) do
			r.destroy()
		end
		elevator_rotated(player.selected, player.selected.direction)
		if player.selected then elevator_selected(player, player.selected) end
	end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
	if event.prototype_name == "se-remote-view" then
		on_remote_view_started(game.get_player(event.player_index))
	end
end)
script.on_event(defines.events.on_gui_click, function(event)
	if event.element.name == "se-overhead_satellite" then
		on_remote_view_started(game.get_player(event.player_index))
	elseif event.element.name == "unit_digging" then
		aai_on_gui_click(event)
	end
end)

function on_remote_view_started(player)
	if remote.call("space-exploration", "remote_view_is_active", {player = player}) then
		local character = remote.call("space-exploration", "get_player_character", {player = player})
		if is_subsurface(character.surface) then
			remote.call("space-exploration", "remote_view_start", {player = player, zone_name = get_top_surface(character.surface).name, position = character.position})
		end
	end
end
