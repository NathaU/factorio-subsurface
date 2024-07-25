function place_resources(surface, pos_arr)
	local resources = {}
	local properties = {"probability"}
	for proto,_ in pairs(surface.map_gen_settings.autoplace_controls or {}) do
		if proto ~= "enemy-base" and proto ~= "trees" then
			table.insert(resources, proto)
			table.insert(properties, "entity:"..proto..":richness")
			table.insert(properties, "entity:"..proto..":probability")
			table.insert(properties, "probability-" .. proto)
		end
	end
	
	local stored_results = {}
	
	for _,pos in ipairs(pos_arr) do
		local chunk_id = spiral({math.floor(pos[1] / 32), math.floor(pos[2] / 32)})
		if not stored_results[chunk_id] then
			stored_results[chunk_id] = surface.calculate_tile_properties(properties, get_chunk_positions(pos))
		end
		local pos_pos = get_position_index_in_chunk(pos)
		for _,proto in ipairs(resources) do
			if stored_results[chunk_id]["entity:"..proto..":richness"]
			and stored_results[chunk_id]["entity:"..proto..":richness"][pos_pos] > 0
			and ((stored_results[chunk_id]["probability-"..proto] and stored_results[chunk_id]["probability-"..proto][pos_pos]) or stored_results[chunk_id]["probability"][pos_pos]) <= stored_results[chunk_id]["entity:"..proto..":probability"][pos_pos]
			and not surface.entity_prototype_collides(proto, pos, false) then
				surface.create_entity{name=proto, position=pos, force=game.forces.neutral, amount=math.ceil(stored_results[chunk_id]["entity:"..proto..":richness"][pos_pos])}
			end
		end
	end
end

local meta = {
	__index = function(self, key) return {size = 0, frequency = 0, richness = 0} end,
	__newindex = function(self, key, value)
		if game.autoplace_control_prototypes[key] then rawset(self, key, value) end
	end,
}

-- This is for top surfaces. It directly manipulates the map_gen_settings table
-- It is either called upon game start, mod installation or newly created surfaces which aren't subsurfaces
function manipulate_autoplace_controls(surface)
	if settings.global["disable-autoplace-manipulation"].value then return end
	local mgs = surface.map_gen_settings
	if not mgs or not mgs.autoplace_controls then return end
	setmetatable(mgs.autoplace_controls, meta)
	
	-- first, half all resource richness
	for proto,control in pairs(mgs.autoplace_controls) do
		if proto ~= "trees" and proto ~= "enemy-base" then
			mgs.autoplace_controls[proto].richness = control.richness / 2
		end
	end
	mgs.autoplace_controls["stone"].richness = mgs.autoplace_controls["stone"].richness / 4
	
	-- second, half all existing resources (only if the mod was added to an existing game)
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
