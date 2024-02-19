function place_resources(surface, pos_arr)
	local resources = {}
	local res = {}
	for k,v in pairs(surface.map_gen_settings.autoplace_controls) do
		resources["entity:"..k..":richness"] = k
		table.insert(res, "entity:"..k..":richness")
	end
	
	local calcresult = surface.calculate_tile_properties(res, pos_arr)
	for r,arr in pairs(calcresult) do
		for i,v in ipairs(arr) do
			if v > 0 then
				surface.create_entity{name=resources[r], position={pos_arr[i][1], pos_arr[i][2]}, force=game.forces.neutral, amount=math.ceil(v)}
			end
		end
	end
end

-- this is for top surfaces (level 0). It directly manipulates the surface's map_gen_settings
function manipulate_autoplace_controls(surface)
	local mgs = surface.map_gen_settings
	mgs.default_enable_all_autoplace_controls = false
	
	if surface.name == "nauvis" then
		mgs.autoplace_controls["uranium-ore"] = nil
		mgs.autoplace_controls["stone"].richness = mgs.autoplace_controls["stone"].richness * 0.7
	end
	
	surface.map_gen_settings = mgs
end

-- this is for subsurfaces, it returns a freshly new autoplace_controls array
-- ensure that all resources really exist!
function make_autoplace_controls(topname, level)
	if topname == "nauvis" then
		return {
			["iron-ore"] = 		{frequency = 1.5*level, 	size = 1.1*level, 	richness = 2*level},
			["copper-ore"] = 	{frequency = 1.5*level, 	size = 1.1*level, 	richness = 2*level},
			["uranium-ore"] = 	{frequency = 1, 			size = 1, 			richness = 1},
			["crude-oil"] = 	{frequency = 1.5*level, 	size = 1.1*level, 	richness = 2*level},
			["coal"] = 			{frequency = 0.8^level, 	size = 0.5^level, 	richness = 0.8^level},
		}
	else return {}
	end
end

-- When top surfaces are created (but not for nauvis!)
script.on_event(defines.events.on_surface_created, function(event)
	if not is_subsurface(event.surface_index) then
		manipulate_autoplace_controls(game.get_surface(event.surface_index))
	end
end)
