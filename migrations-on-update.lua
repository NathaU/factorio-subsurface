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
	["1.1.11"] = function()
		game.print("Subsurface 1.1.11 split the setting 'Disable challenges' into 'Enable resource generation' and 'Enable challenges'. If you had resources and challenges disabled in the previous version, please check your settings!", {sound = defines.print_sound.always, color = {1, 1, 0}})
	end,
	["1.1.12"] = function(config)
		if config.mod_changes["Subsurface"].old_version ~= "1.1.11" then
			settings.global["enable-challenges"] = {value = not settings.global["generate-resources-underground"].value}
			settings.global["generate-resources-underground"] = {value = not settings.global["generate-resources-underground"].value}
		end
	end
}
