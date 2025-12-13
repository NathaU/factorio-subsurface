resources = {}
for proto, _ in pairs(prototypes.get_entity_filtered({{filter = "type", type = "resource"}, {mode = "and", filter = "autoplace"}})) do
	table.insert(resources, proto)
end

function calculate_resources(surface, pos_arr)
	local properties = {"subsurface_random", "subsurface_richness_multiplier"}
	for proto, _ in pairs((surface.map_gen_settings.autoplace_settings.entity or {settings = {}}).settings or {}) do
		if (prototypes.entity[proto] or {}).type == "resource" then
			table.insert(properties, "entity:" .. proto .. ":richness")
			table.insert(properties, "entity:" .. proto .. ":probability")
			if prototypes.named_noise_expression[proto .. "-probability"] then table.insert(properties, proto .. "-probability") end
		end
	end
	
	local stored_results = {}
	local result = {}

	for i, pos in ipairs(pos_arr) do
		local chunk_id = spiral({math.floor(pos[1] / 32), math.floor(pos[2] / 32)})
		local pos_i = get_position_index_in_chunk(pos)
		if not stored_results[chunk_id] then stored_results[chunk_id] = surface.calculate_tile_properties(properties, get_chunk_positions(pos)) end
		for _, proto in ipairs(resources) do
			local richness = (stored_results[chunk_id]["entity:"..proto..":richness"] or {[pos_i] = 0})[pos_i] * stored_results[chunk_id]["subsurface_richness_multiplier"][pos_i]
			if richness > 0 and (stored_results[chunk_id][proto.."-probability"] or stored_results[chunk_id]["subsurface_random"])[pos_i] <= stored_results[chunk_id]["entity:"..proto..":probability"][pos_i] then
				if not result[i] then result[i] = {proto, math.ceil(richness)} end
			end
		end
	end
	return result
end

function place_resources(surface, pos_arr)
	local resources = calculate_resources(surface, pos_arr)
	for i, v in pairs(resources) do
		local proto = v[1]
		local pos = pos_arr[i]
		local amount = v[2]
		local collision_box_vector = {x = prototypes.entity[proto].tile_width, y = prototypes.entity[proto].tile_height}
		if surface.count_tiles_filtered{name = "out-of-map", area = math2d.bounding_box.create_from_centre({pos[1] + 0.5 * (collision_box_vector.x % 2), pos[2] + 0.5 * (collision_box_vector.y % 2)}, collision_box_vector.x, collision_box_vector.y)} > 0 then
			clear_subsurface(surface, pos, math2d.vector.length(collision_box_vector) / 2)
		end
		if not surface.entity_prototype_collides(proto, {pos[1] + 0.5 * (collision_box_vector.x % 2), pos[2] + 0.5 * (collision_box_vector.y % 2)}, false) then -- check for other collision than out-of-map tiles (already placed resources)
			if storage.revealed_resources[chunk_id] and storage.revealed_resources[chunk_id][pos_i] and storage.revealed_resources[chunk_id][pos_i][proto] then
				amount = storage.revealed_resources[chunk_id][pos_i][proto]
			end
			if amount > 0 then surface.create_entity{name = proto, position = pos, force = game.forces.neutral, enable_cliff_removal = false, amount = amount} end
		end
	end
end

function size_formula(level)
	return 2 - 2 / (1 + 2 ^ (-0.8 * level))
end

-- This is for top surfaces. It directly manipulates the map_gen_settings table
-- It is either called upon game start, mod installation or newly created surfaces which aren't subsurfaces
function manipulate_resource_data(surface)
	if not settings.global["generate-resources-underground"].value then return end
	local mgs = surface.map_gen_settings
	
	-- first, adjust autoplace controls
	for control_name, data in pairs(mgs.autoplace_controls or {}) do
		if prototypes.autoplace_control[control_name].category == "resource" then
			mgs.autoplace_controls[control_name].size = data.size * size_formula(0)
		end
	end
	
	-- second, adjust all existing resources
	manipulate_resource_entities(surface)
	
	surface.map_gen_settings = mgs
end
function manipulate_resource_entities(surface, area)
	if not settings.global["generate-resources-underground"].value then return end

	if area then
		dummy_iter = function()
			local i = 0
			return function()
				i = i + 1
				if i == 1 then return {area = area} end
			end
		end
	end
	for chunk in area and dummy_iter() or surface.get_chunks() do
		local entities_in_area = {}
		for _, e in ipairs(surface.find_entities_filtered{type = "resource", area = chunk.area}) do
			entities_in_area[get_position_index_in_chunk(e.position)] = e
		end

		local calc_result = surface.calculate_tile_properties({"subsurface_richness_multiplier", "subsurface_stone_richness_multiplier"}, get_chunk_positions(chunk.area.left_top))
		for pos_i, e in pairs(entities_in_area) do
			local amount = e.amount
			amount = math.ceil(amount * (e.name == "stone" and calc_result.subsurface_stone_richness_multiplier[pos_i] or calc_result.subsurface_richness_multiplier[pos_i]))
			if amount > 0 then e.amount = amount
			else e.destroy() end
		end
	end
end

function copy_resource_data(mgs, from_surface, depth)
	for control_name, data in pairs(from_surface.map_gen_settings.autoplace_controls or {}) do
		if prototypes.autoplace_control[control_name].category == "resource" then
			mgs.autoplace_controls[control_name] = {
				frequency = data.frequency,
				size = data.size * size_formula(depth) / size_formula(0),
				richness = settings.global["generate-resources-underground"].value and data.richness or 0
			}
		end
	end
	
	for name, _ in pairs((from_surface.map_gen_settings.autoplace_settings.entity or {settings = {}}).settings) do
		if (prototypes.entity[name] or {}).type == "resource" then
			mgs.autoplace_settings.entity.settings[name] = {}
			mgs.property_expression_names["entity:"..name..":richness"] = from_surface.map_gen_settings.property_expression_names["entity:"..name..":richness"]
			if mgs.property_expression_names["entity:"..name..":richness"] and not settings.global["generate-resources-underground"].value then mgs.property_expression_names["entity:"..name..":richness"] = 0 end
			mgs.property_expression_names["entity:"..name..":probability"] = from_surface.map_gen_settings.property_expression_names["entity:"..name..":probability"]
		end
	end
	mgs.autoplace_settings.entity.settings["stone"] = nil
	mgs.property_expression_names["entity:stone:richness"] = nil
	mgs.property_expression_names["entity:stone:probability"] = nil
end

-- When top surfaces are created (this is not called for nauvis)
script.on_event(defines.events.on_surface_created, function(event)
	local surface = game.get_surface(event.surface_index)
	if not is_subsurface(surface) and allow_subsurfaces(surface) then
		local mgs = surface.map_gen_settings
		mgs.property_expression_names["subsurface_level"] = get_subsurface_depth(surface)
		surface.map_gen_settings = mgs
		manipulate_resource_data(surface)
	end
end)

function prospect_resources(prospector)
	local surface = prospector.surface
	local radius = 64
	local pos_arr = get_area_positions(get_area(prospector.position, radius))
	for i = #pos_arr, 1, -1 do
		if (pos_arr[i][1] - prospector.position.x) ^ 2 + (pos_arr[i][2] - prospector.position.y) ^ 2 >= radius ^ 2 or (surface.get_tile(pos_arr[i][1], pos_arr[i][2]).valid and surface.get_tile(pos_arr[i][1], pos_arr[i][2]).name ~= "out-of-map") then
			table.remove(pos_arr, i)
		end
	end
	local max = {0, 0}
	for i, v in pairs(calculate_resources(surface, pos_arr)) do
		if v[2] > max[2] then
			max = {pos_arr[i], v[2], v[1]}
		end
	end
	for _, e in ipairs(surface.find_entities_filtered{type = "resource", position = prospector.position, radius = radius}) do
		if e.amount > max[2] then
			max = {{e.position.x, e.position.y}, e.amount, e.name}
		end
	end
	
	local logistic_section = prospector.get_control_behavior().get_section(1)
	if max[2] > 0 then
		prospector.force.print("[gps=".. string.format("%.1f,%.1f,", max[1][1], max[1][2]) .. surface.name .."]")
		logistic_section.set_slot(1, {value = "signal-X", min = max[1][1]})
		logistic_section.set_slot(2, {value = "signal-Y", min = max[1][2]})
		logistic_section.set_slot(3, {value = {type = "entity", name = max[3], quality = "normal"}, min = max[2]})
	else
		logistic_section.clear_slot(1)
		logistic_section.clear_slot(2)
		logistic_section.clear_slot(3)
	end
end

function create_prospector_gui(player, prospector)
	if player.gui.screen["prospector"] then player.gui.screen["prospector"].destroy() return end

	local gui = player.gui.screen.add{
		type = "frame",
		name = "prospector",
		style = "invisible_frame",
		direction = "horizontal",
		tags = {["prospector"] = prospector.unit_number}
	}
	gui.auto_center = true
	local main_frame = gui.add{type = "frame", direction = "vertical"}

	local titlebar = main_frame.add{type = "flow"}
	titlebar.drag_target = gui
	titlebar.add{
		type = "label",
		style = "frame_title",
		caption = prospector.localised_name,
		ignored_by_interaction = true,
	}
	local filler = titlebar.add{
		type = "empty-widget",
		style = "draggable_space",
		ignored_by_interaction = true,
	}
	filler.style.height = 24
	filler.style.horizontally_stretchable = true
	titlebar.add{
		type = "sprite-button",
		name = "prospector_close",
		style = "frame_action_button",
		sprite = "utility/close",
		hovered_sprite = "utility/close",
		clicked_sprite = "utility/close",
		tooltip = {"gui.close-instruction"},
    }

	local inner_frame = main_frame.add{type = "frame", direction = "vertical", style = "entity_frame"}
	-- local indicator = inner_frame.add{type = "flow", direction = "vertical"}
	-- local status_flow = indicator.add{
	-- 	type = "flow",
	-- 	--style = "status_flow",
	-- }
	-- status_flow.style.vertical_align = "center"
	-- status_flow.add{
	-- 	type = "sprite",
	-- 	style = "status_image",
	-- 	sprite = GUI_util.STATUS_SPRITE[entity.status],
	-- }
	-- status_flow.add{
	-- 	type = "label",
	-- 	caption = {GUI_util.STATUS_NAME[entity.status]},
	-- }
	-- local preview_frame = indicator.add{
	-- 	type = "frame",
	-- 	style = "entity_button_frame",
	-- }
	-- local preview = preview_frame.add{
	-- 	type = "entity-preview",
	-- }
	-- preview.entity = entity
	-- preview.style.height = 148
	-- preview.style.horizontally_stretchable = true

	inner_frame.add{
		type = "button",
		caption = "Scan",
		name = "prospector_scan"
	}

	return gui
end
