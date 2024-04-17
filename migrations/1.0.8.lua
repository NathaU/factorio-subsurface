for index, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes

	recipes["cave-sealing"].enabled = technologies["surface-drilling"].researched
end
