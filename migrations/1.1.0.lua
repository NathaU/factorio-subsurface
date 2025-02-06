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
