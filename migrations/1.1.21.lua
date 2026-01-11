for _, s in pairs(storage.subsurfaces) do
	for _, f in pairs(game.forces) do
		s.set_default_cover_tile(f, "out-of-map", "caveground")
	end
end
