for _, e in pairs(storage.pole_links) do
	e.destructible = false
end
for _, e in pairs(storage.car_links) do
	e.destructible = false
end

for _, s in pairs(game.surfaces) do
	for _, e in ipairs(s.find_entities_filtered{name = {"subsurface-wall-map-border", "tunnel-entrance-sealed-0", "tunnel-entrance-sealed-1", "tunnel-entrance-sealed-2", "tunnel-entrance-sealed-3"}}) do
		e.destructible = false
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
end
