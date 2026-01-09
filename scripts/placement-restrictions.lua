-- for modders: add entities to data.subsurface_entity_restrictions in the format: {[name] = type}
data.subsurface_entity_restrictions["rsc-silo-stage1"] = "assembling-machine"
data.subsurface_entity_restrictions["rsc-silo-stage1-serlp"] = "assembling-machine"
data.subsurface_entity_restrictions["rsc-silo-stage-sesprs"] = "assembling-machine"
data.subsurface_entity_restrictions["railgun-turret"] = "ammo-turret"

-- index by type, give name of entities that are ignored
type_restrictions = {
	["electric-pole"] = {
		"wooden-support",
		"steel-support",
		"tunnel-entrance-cable",
		"tunnel-exit-cable",
		"factory-circuit-connector",
		"factory-power-pole",
		"glutenfree-aai-signal-transmission-preview-laptop",
		"or_pole",
	},
	["rocket-silo"] = {},
	["cargo-landing-pad"] = {},
	["rail-ramp"] = {},
	["rail-support"] = {},
	["artillery-turret"] = {},
	["artillery-wagon"] = {},
}

-- collect the data into the table
for type, name_arr in pairs(type_restrictions) do
	for name, _ in pairs(data.raw[type]) do
		local ignore = false
		for _, ign in ipairs(name_arr) do
			if name == ign then ignore = true end
		end
		if not ignore then data.subsurface_entity_restrictions[name] = type end
	end
end

-- now make the mod-data structure
data:extend{{
	type = "mod-data",
	name = "subsurface_placement_restrictions",
	data = data.subsurface_entity_restrictions
}}
