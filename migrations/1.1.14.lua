for _, s in pairs(storage.subsurfaces) do
	local effect = s.global_effect
	effect.quality = nil
	s.global_effect = effect
end
