for _, force in pairs(game.forces) do
	force.recipes["prospector"].enabled = false
end

storage.fluid_elevators = nil
