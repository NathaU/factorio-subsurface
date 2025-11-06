for _, s in pairs(storage.subsurfaces) do
	local effect = s.global_effect
	effect.quality = nil
	effect.pollution = nil
	s.global_effect = effect
	if settings.global["enable-challenges"].value then s.global_effect = nil end
end
