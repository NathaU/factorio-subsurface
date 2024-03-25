for index, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes

	recipes["wooden-support"].enabled = technologies["surface-drilling"].researched
	recipes["surface-drill"].enabled = technologies["surface-drilling"].researched
	recipes["prospector"].enabled = technologies["surface-drilling"].researched
end