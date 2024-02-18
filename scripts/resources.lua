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
