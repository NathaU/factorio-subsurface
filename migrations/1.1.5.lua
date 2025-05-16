for _, s in pairs(game.surfaces) do
	local mgs = s.map_gen_settings
	mgs.property_expression_names["subsurface_level"] = get_subsurface_depth(s)
	s.map_gen_settings = mgs
end

for _, force in pairs(game.forces) do
	force.recipes["prospector"].enabled = force.technologies["surface-drilling"].researched
end
