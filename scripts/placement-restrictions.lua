-- for modders: add entities to data.subsurface_entity_restrictions in the format: {[name] = type}
data.subsurface_entity_restrictions["rsc-silo-stage1"] = "assembling-machine"
data.subsurface_entity_restrictions["rsc-silo-stage1-serlp"] = "assembling-machine"
data.subsurface_entity_restrictions["rsc-silo-stage-sesprs"] = "assembling-machine"
data.subsurface_entity_restrictions["railgun-turret"] = "ammo-turret"

-- index by type, give name of entities that are ignored
type_restrictions = {
	["electric-pole"] = {"wooden-support"},
	["rocket-silo"] = {},
	["cargo-landing-pad"] = {},
	["rail-ramp"] = {},
	["rail-support"] = {},
	["artillery-turret"] = {},
	["artillery-wagon"] = {},
}
