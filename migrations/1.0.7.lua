for index, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes
	
	recipes["fluid-elevator"].enabled = technologies["inter-surface-transport"].researched
	recipes["item-elevator"].enabled = technologies["inter-surface-transport"].researched
end