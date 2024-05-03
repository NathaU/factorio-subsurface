function place_resources(surface, pos_arr)
	local resources = {}
	local properties = {}
	for proto,_ in pairs(surface.map_gen_settings.autoplace_controls) do
		if proto ~= "enemy-base" and proto ~= "trees" then
			table.insert(resources, proto)
			table.insert(properties, "entity:"..proto..":richness")
			table.insert(properties, "entity:"..proto..":probability")
		end
	end
	
	local calcresult = surface.calculate_tile_properties(properties, pos_arr)
	for _,proto in ipairs(resources) do
		for i,pos in ipairs(pos_arr) do
			if calcresult["entity:"..proto..":richness"] and calcresult["entity:"..proto..":richness"][i] > 0 and calcresult["entity:"..proto..":probability"][i] > 0 and surface.count_entities_filtered{type="resource", position={pos[1]+0.5, pos[2]+0.5}} == 0 then
				surface.create_entity{name=proto, position=pos, force=game.forces.neutral, amount=math.ceil(calcresult["entity:"..proto..":richness"][i])}
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
	local subsurface = get_subsurface(prospector.surface)
	
	local resources = {}
	local res = {}
	for k,v in pairs(subsurface.map_gen_settings.autoplace_controls) do
		resources["entity:"..k..":richness"] = k
		table.insert(res, "entity:"..k..":richness")
	end
	
	local pos = prospector.position
	local pos_arr = {}
	for x, y in iarea(get_area(pos, 200)) do
		if (x-pos.x)^2 + (y-pos.y)^2 < 40000 then table.insert(pos_arr, {x, y}) end
	end
	
	local calcresult = subsurface.calculate_tile_properties(res, pos_arr)
	for r,arr in pairs(calcresult) do
		for i,v in ipairs(arr) do
			if v > 0 then
				rendering.draw_circle{color={0.5, 0.5, 0.5, 0.1}, target=pos_arr[i], radius=0.3, surface=prospector.surface, time_to_live=36000, forces={prospector.force}, draw_on_ground=true}
			end
		end
	end
end
