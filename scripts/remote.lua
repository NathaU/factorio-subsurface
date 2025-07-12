--[[ shorthand definitions possible for:
 surfaces: index or name
 positions: array with two elements
]]
remote.add_interface("subsurface", {
	
	expose = function(surface, pos, radius, clearing_radius)
		clear_subsurface(get_surface_object(surface), math2d.position.ensure_xy(pos), radius, clearing_radius)
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

	on_unit_change_mode = function(data) return aai_on_unit_change_mode(data.unit, data.new_mode, data.old_mode) end,
	on_unit_given_order = function(data) return aai_on_unit_given_order(data.unit, data.order) end,

	blacklist_surface = function(name) table.insert(blacklist, name) end
})

--[[
Events:
Mods that want to register to specific events have to implement a remote function in their own interface.

remote.add_interface(interface_name, {
	subsurface_make_autoplace_controls = function(res_table, topname, depth)
		-- return the manipulated res_table (format is {[resource-name] = {frequency = x, size = x, richness = x}})
		-- topname is the topmost surface name
		-- depth is the subsurface depth this autoplace controls are generated for
	end
})

]]
