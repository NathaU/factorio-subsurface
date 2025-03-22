resources = {}
for proto, _ in pairs(prototypes.get_entity_filtered({{filter = "type", type = "resource"}, {mode = "and", filter = "autoplace"}})) do
	table.insert(resources, proto)
end

function place_resources(surface, pos_arr)
	local properties = {"subsurface_random"}
	for proto, _ in pairs((surface.map_gen_settings.autoplace_settings.entity or {settings = {}}).settings or {}) do
		if (prototypes.entity[proto] or {}).type == "resource" then
			table.insert(properties, "entity:" .. proto .. ":richness")
			table.insert(properties, "entity:" .. proto .. ":probability")
			if prototypes.named_noise_expression[proto .. "-probability"] then table.insert(properties, proto .. "-probability") end
		end
	end
	
	local stored_results = {}
	
	for _, pos in ipairs(pos_arr) do
		local chunk_id = spiral({math.floor(pos[1] / 32), math.floor(pos[2] / 32)})
		local pos_i = get_position_index_in_chunk(pos)
		if not stored_results[chunk_id] then stored_results[chunk_id] = surface.calculate_tile_properties(properties, get_chunk_positions(pos)) end
		for _, proto in ipairs(resources) do
			if (stored_results[chunk_id]["entity:"..proto..":richness"] or {[pos_i] = 0})[pos_i] > 0
			and (stored_results[chunk_id][proto.."-probability"] or stored_results[chunk_id]["subsurface_random"])[pos_i] <= stored_results[chunk_id]["entity:"..proto..":probability"][pos_i] then
				local collision_box_vector = {x = prototypes.entity[proto].tile_width, y = prototypes.entity[proto].tile_height}
				if surface.count_tiles_filtered{name = "out-of-map", area = math2d.bounding_box.create_from_centre({pos[1] + 0.5 * (collision_box_vector.x % 2), pos[2] + 0.5 * (collision_box_vector.y % 2)}, collision_box_vector.x, collision_box_vector.y)} > 0 then
					clear_subsurface(surface, pos, math2d.vector.length(collision_box_vector) / 2)
				end
				if not surface.entity_prototype_collides(proto, {pos[1] + 0.5 * (collision_box_vector.x % 2), pos[2] + 0.5 * (collision_box_vector.y % 2)}, false) then -- check for other collision than out-of-map tiles (already placed resources)
					local amount = math.ceil(stored_results[chunk_id]["entity:"..proto..":richness"][pos_i])
					if storage.revealed_resources[chunk_id] and storage.revealed_resources[chunk_id][pos_i] and storage.revealed_resources[chunk_id][pos_i][proto] then
						amount = storage.revealed_resources[chunk_id][pos_i][proto]
					end
					if amount > 0 then surface.create_entity{name = proto, position = pos, force = game.forces.neutral, enable_cliff_removal = false, amount = amount} end
				end
			end
		end
	end
end

function size_formula(level)
	return 2 - 2 / (1 + 2 ^ (-0.8 * level))
end
function richness_formula(level)
	return (math.log(level + 1) / math.log(2)) + 0.1
end

local meta = {
	__index = function(self, key) return {size = 0, frequency = 0, richness = 0} end,
	__newindex = function(self, key, value)
		if prototypes.autoplace_control[key] then rawset(self, key, value) end
	end,
}

-- This is for top surfaces. It directly manipulates the map_gen_settings table
-- It is either called upon game start, mod installation or newly created surfaces which aren't subsurfaces
function manipulate_autoplace_controls(surface)
	if settings.global["disable-autoplace-manipulation"].value then return end
	local mgs = surface.map_gen_settings
	if not mgs or not mgs.autoplace_controls then return end
	setmetatable(mgs.autoplace_controls, meta)
	
	-- first, adjust autoplace controls
	for control_name, data in pairs(mgs.autoplace_controls) do
		if prototypes.autoplace_control[control_name].category == "resource" then
			mgs.autoplace_controls[control_name].size = data.size * size_formula(0)
			mgs.autoplace_controls[control_name].richness = data.richness * richness_formula(0)
		end
	end
	
	-- second, adjust all existing resources (only if the mod was added to an existing game)
	for _, res in ipairs(surface.find_entities_filtered{type = "resource"}) do
		res.amount = math.ceil(res.amount * richness_formula(0))
	end
	
	surface.map_gen_settings = mgs
end

-- This is for subsurfaces, it returns a freshly new autoplace_controls array
-- depth is always >= 1
function make_autoplace_controls(top_surface, depth)
	if settings.global["disable-autoplace-manipulation"].value then return {} end
	local controls = {}
	setmetatable(controls, meta)
	
	for control_name, data in pairs(top_surface.map_gen_settings.autoplace_controls or {}) do -- alter all resources that occur on the top surface
		if prototypes.autoplace_control[control_name].category == "resource" then
			controls[control_name] = {
				frequency = data.frequency,
				size = data.size * size_formula(depth) / size_formula(0),
				richness = data.richness * richness_formula(depth) / richness_formula(0)
			}
		end
	end
	
	return controls
end

function make_resource_autoplace_settings(top_surface, depth)
	local res = {}
	for name, _ in pairs((top_surface.map_gen_settings.autoplace_settings.entity or {settings = {}}).settings) do
		if (prototypes.entity[name] or {}).type == "resource" then
			res[name] = {}
		end
	end
	res["stone"] = nil
	return res
end

function make_property_expressions(mgs, top_surface, depth)
	for _, proto in ipairs(resources) do
		if top_surface.map_gen_settings.property_expression_names["entity:"..proto..":richness"] then
			mgs.property_expression_names["entity:"..proto..":richness"] = top_surface.map_gen_settings.property_expression_names["entity:"..proto..":richness"]
		end
		if top_surface.map_gen_settings.property_expression_names["entity:"..proto..":probability"] then
			mgs.property_expression_names["entity:"..proto..":probability"] = top_surface.map_gen_settings.property_expression_names["entity:"..proto..":probability"]
		end
	end
end

-- When top surfaces are created (this is not called for nauvis)
script.on_event(defines.events.on_surface_created, function(event)
	if not is_subsurface(event.surface_index) then
		manipulate_autoplace_controls(game.get_surface(event.surface_index))
	end
end)

function prospect_resources(prospector)
	
end
