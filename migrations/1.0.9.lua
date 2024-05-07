for _,v in ipairs(global.air_vents) do
	v.operable = true
end

-- mapgen manipulation in games that had an older version of this mod and adaption to new clear_subsurface mechanics
for _,s in pairs(game.surfaces) do
	if is_subsurface(s) then
		local top = get_oversurface(s)
		local mgs = {
			seed = top.map_gen_settings.seed,
			width = top.map_gen_settings.width,
			height = top.map_gen_settings.height,
			autoplace_controls = make_autoplace_controls(top.name, get_subsurface_depth(s)),
			autoplace_settings = {
			  tile = {treat_missing_as_default = false, settings = {
				["caveground"] = {},
				["out-of-map"] = {},
			  }},
			},
			property_expression_names = {
				["tile:caveground:probability"] = 0, -- basic floor
			}
		}
		s.map_gen_settings = mgs
		
		local new_tiles = {}
		for _,t in ipairs(s.find_tiles_filtered{name="grass-1"}) do
			table.insert(new_tiles, {name = "out-of-map", position = {t.position.x, t.position.y}})
		end
		s.set_tiles(new_tiles)
		for _,t in ipairs(s.find_tiles_filtered{name="out-of-map"}) do
			if (math.abs(t.position.x) < s.map_gen_settings.width / 2 and math.abs(t.position.y) < s.map_gen_settings.height / 2)
			or (remote.interfaces["space-exploration"] and math.sqrt(t.position.x^2 + t.position.y^2) < remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = s.index}).radius - 3) then
				s.set_hidden_tile(t.position, "caveground")
			end
		end
	else
		manipulate_autoplace_controls(s)
	end
end
