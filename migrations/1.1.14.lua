for _, s in pairs(storage.subsurfaces) do
	local effect = s.global_effect
	effect.quality = nil
	effect.pollution = nil
	s.global_effect = effect
	if settings.global["enable-challenges"].value then s.global_effect = nil end

	s.set_property("pressure", get_top_surface(s).get_property("pressure") * 1.1 ^ get_subsurface_depth(s))
end
