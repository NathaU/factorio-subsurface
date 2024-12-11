function place_resources(surface, pos_arr)
	local resources = {}
	local properties = {"probability"}
	local game_prototypes = prototypes.entity
	for proto,_ in pairs(surface.map_gen_settings.autoplace_controls or {}) do
		if game_prototypes[proto] then
			table.insert(resources, proto)
			table.insert(properties, "entity:"..proto..":richness")
			table.insert(properties, "entity:"..proto..":probability")
			if surface.map_gen_settings.property_expression_names["probability-" .. proto] and prototypes.named_noise_expression[proto .. "-probability"] then table.insert(properties, "probability-" .. proto) end
		end
	end
	
	local stored_results = {}
	
	for _,pos in ipairs(pos_arr) do
		local chunk_id = spiral({math.floor(pos[1] / 32), math.floor(pos[2] / 32)})
		if not stored_results[chunk_id] then
			stored_results[chunk_id] = surface.calculate_tile_properties(properties, get_chunk_positions(pos))
		end
		local pos_i = get_position_index_in_chunk(pos)
		for _,proto in ipairs(resources) do
			if (stored_results[chunk_id]["entity:"..proto..":richness"] or {[pos_i] = 0})[pos_i] > 0
			and (stored_results[chunk_id]["probability-"..proto] or stored_results[chunk_id]["probability"])[pos_i] <= stored_results[chunk_id]["entity:"..proto..":probability"][pos_i]
			and not surface.entity_prototype_collides(proto, {pos[1]+0.5, pos[2]+0.5}, false) then
				local amount = math.ceil(stored_results[chunk_id]["entity:"..proto..":richness"][pos_i])
				if storage.revealed_resources[chunk_id] and storage.revealed_resources[chunk_id][pos_i] and storage.revealed_resources[chunk_id][pos_i][proto] then
					amount = storage.revealed_resources[chunk_id][pos_i][proto]
				end
				if amount > 0 then surface.create_entity{name = proto, position = pos, force = game.forces.neutral, enable_cliff_removal = false, amount = amount} end
			end
		end
	end
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
	
	-- first, halve all resource richness
	for proto,control in pairs(mgs.autoplace_controls) do
		if control.richness then
			mgs.autoplace_controls[proto].richness = control.richness / 2
		end
	end
	mgs.autoplace_controls["stone"].richness = mgs.autoplace_controls["stone"].richness / 4
	
	-- second, halve all existing resources (only if the mod was added to an existing game)
	for _,res in ipairs(surface.find_entities_filtered{type = "resource"}) do
		res.amount = math.ceil(res.amount / 2)
	end
	
	surface.map_gen_settings = mgs
end

-- This is for subsurfaces, it returns a freshly new autoplace_controls array
-- depth is always >= 1
function make_autoplace_controls(topname, depth)
	if settings.global["disable-autoplace-manipulation"].value then return {} end
	local res_table = {}
	setmetatable(res_table, meta)
	
	-- mirror top surface resource patches only in 1st subsurface
	if depth == 1 then
		for res,control in pairs(game.get_surface(topname).map_gen_settings.autoplace_controls or {}) do -- alter all resources that occur on the topsurface
			res_table[res] = {
				frequency = control.frequency,
				size = control.size,
				richness = control.richness
			}
		end
	end
	
	res_table["stone"].size = 0
	res_table["trees"].size = 0
	
	return res_table
end

-- When top surfaces are created (this is not called for nauvis)
script.on_event(defines.events.on_surface_created, function(event)
	if not is_subsurface(event.surface_index) then
		manipulate_autoplace_controls(game.get_surface(event.surface_index))
	end
end)

function prospect_resources(prospector)
	
end
