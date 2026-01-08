for _, s in pairs(game.surfaces) do
	for _, e in ipairs(s.find_entities_filtered{name = {"subsurface-wall-map-border", "tunnel-entrance-sealed-0", "tunnel-entrance-sealed-1", "tunnel-entrance-sealed-2", "tunnel-entrance-sealed-3"}}) do
		e.destructible = false
	end

	storage.train_stop_clones = storage.train_stop_clones or {}
	for _, stop in ipairs(s.find_entities_filtered{type = "train-stop"}) do
		if stop.name ~= "subway-stop" then create_fake_stops(stop) end
	end
end

for i, s in pairs(storage.subsurfaces) do
	local depth = get_subsurface_depth(s)
	local effect = game.get_surface(i).global_effect or {}
	effect.productivity = (effect.productivity or 0) + 0.05 * depth
	effect.speed = (effect.speed or 0) + 0.05 * depth
	effect.consumption = (effect.consumption or 0) + 0.1 * depth
	effect.pollution = (effect.pollution or 0) + 0.1 * depth
	effect.quality = (effect.quality or 0) + 0.1 * depth
	s.global_effect = effect

	local mgs = s.map_gen_settings
	mgs.property_expression_names["subsurface_seed"] = math.random(2^16)
	s.map_gen_settings = mgs
end
