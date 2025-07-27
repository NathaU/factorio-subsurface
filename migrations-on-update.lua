return {
	["1.1.8"] = function()
		function old_richness_formula(level)
			return (math.log(level + 1) / math.log(2)) + 0.1
		end
		for _, s in pairs(game.surfaces) do
			local mgs = s.map_gen_settings
			for control_name, data in pairs(mgs.autoplace_controls or {}) do
				if prototypes.autoplace_control[control_name].category == "resource" and data.richness then
					mgs.autoplace_controls[control_name].richness = data.richness / old_richness_formula(get_subsurface_depth(s))
				end
			end
			mgs.property_expression_names["subsurface_level"] = get_subsurface_depth(s)
			s.map_gen_settings = mgs
		end
	end,
}
