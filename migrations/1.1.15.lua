storage.prospectors = {}
for _, s in pairs(game.surfaces) do
	for _, p in ipairs(s.find_entities_filtered{name = "prospector"}) do
		local combinator = s.create_entity{name = "prospector-combinator", position = p.position, force = p.force, quality = p.quality}
		storage.prospectors[combinator.unit_number] = {energy_interface = p, combinator = combinator}
		script.register_on_object_destroyed(combinator)
	end
end
