for _, force in pairs(game.forces) do
	if force.technologies["surface-drilling"].researched then
		force.technologies["subsurface-exploration"].researched = true
	end
end

for _, s in pairs(storage.subsurfaces) do
	local mgs = s.map_gen_settings
	mgs.autoplace_controls = mgs.autoplace_controls or {}
	mgs.autoplace_settings.entity.settings = mgs.autoplace_settings.entity.settings or {}
	copy_resource_data(mgs, get_top_surface(s), get_subsurface_depth(s))
	s.map_gen_settings = mgs
end
