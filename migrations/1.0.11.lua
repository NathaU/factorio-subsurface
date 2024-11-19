for _,s in pairs(storage.subsurfaces) do
	local mgs = s.map_gen_settings
	mgs.property_expression_names["probability"] = "random-value-0-1"
	s.map_gen_settings = mgs
end
