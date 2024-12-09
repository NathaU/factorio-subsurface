for _, r in pairs(storage.air_vent_lights) do
	if type(r) == "number" then
		rendering.get_object_by_id(r).destroy()
	else
		r.destroy()
	end
end

storage.air_vent_lights = nil

for _, s in pairs(storage.subsurfaces) do
	s.set_property("subsurface-level", get_subsurface_depth(s))
end
