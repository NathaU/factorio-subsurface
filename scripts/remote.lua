--[[ shorthand definitions possible for:
 surfaces: index or name
 positions: array with two elements
]]
remote.add_interface("subsurface", {
	
	expose = function(surface, pos, radius, clearing_radius)
		clear_subsurface(get_surface_object(surface), get_position(pos), radius, clearing_radius)
	end,
})
