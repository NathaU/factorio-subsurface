-- 2.0 update

for i,elevators in ipairs(storage.fluid_elevators or {}) do
	elevators[1].fluidbox.add_linked_connection(1, elevators[2], 1)
end

for _,s in ipairs(storage.subsurfaces) do
	local _, _, topname, depth = string.find(s.name, "(.+)_subsurface_([0-9]+)$")
	s.localised_name = {"subsurface.subsurface-name", game.get_surface(topname).localised_name or topname, depth}
end
