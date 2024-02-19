--[[ shorthand definitions possible for:
 surfaces: index or name
 positions: array with two elements
]]
remote.add_interface("subsurface", {
	
	expose = function(surface, pos, radius, clearing_radius)
		clear_subsurface(get_surface_object(surface), get_position(pos), radius, clearing_radius)
	end,
	expose_patches = function(surface, resource, position, radius)
		local surface = get_surface_object(surface)
		local pos = get_area_positions(get_area(position, radius))
		local calcresult = surface.calculate_tile_properties({"entity:"..resource..":richness"}, pos)
		for i,v in ipairs(calcresult["entity:"..resource..":richness"] or {}) do
			if v > 0 then
				clear_subsurface(surface, {x=pos[i][1], y=pos[i][2]}, 1)
			end
		end
	end,
})
