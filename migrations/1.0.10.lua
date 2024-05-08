for _,s in pairs(global.subsurfaces) do
	local mgs = s.map_gen_settings
	mgs.autoplace_settings.tile.settings = {
		["caveground"] = {},
		["mineral-brown-dirt-2"] = {},
		["grass-4"] = {},
		["out-of-map"] = {},
	}
	mgs.property_expression_names = {
		["tile:caveground:probability"] = 0, -- basic floor
		["tile:mineral-brown-dirt-2:probability"] = -1, -- alternative if alienbiomes is active
		["tile:grass-4:probability"] = -1, -- 2nd alternative
		["decorative:rock-small:probability"] = 0.1,
		["decorative:rock-tiny:probability"] = 0.7
	}
	
	s.map_gen_settings = mgs
end
