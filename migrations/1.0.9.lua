for _,v in ipairs(global.air_vents) do
	v.operable = true
end

-- Autoplace manipulation in games that had an older version of this mod
for _,s in pairs(game.surfaces) do
	if is_subsurface(s) then
		local top = get_oversurface(s)
		local mgs = s.map_gen_settings
		mgs.seed = top.map_gen_settings.seed
		mgs.autoplace_controls = make_autoplace_controls(top.name, get_subsurface_depth(s))
		s.map_gen_settings = mgs
	else
		manipulate_autoplace_controls(s)
	end
end
