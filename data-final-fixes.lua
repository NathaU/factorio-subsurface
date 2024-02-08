local collision_mask_util = require("collision-mask-util")

for _,e in pairs(data.raw["locomotive"]) do
	if e.name ~= "electric-locomotive" and e.name ~= "deg-electric-locomotive" and e.burner then
		e.burner.emissions_per_minute = e.burner.emissions_per_minute or 10
	end
end


-- prevent entities from being placed in subsurfaces

for _,e in pairs(data.raw["rocket-silo"]) do
	local collisions = collision_mask_util.get_mask(e)
	collision_mask_util.add_layer(collisions, "layer-50")
	e.collision_mask = collisions
end

local assemblers = {"rsc-silo-stage1", "rsc-silo-stage1-sesprs", "rsc-silo-stage1-serlp"}
for _,a in ipairs(assemblers) do
	if data.raw["assembling-machine"][a] then
		local collisions = collision_mask_util.get_mask(data.raw["assembling-machine"][a])
		collision_mask_util.add_layer(collisions, "layer-50")
		data.raw["assembling-machine"][a].collision_mask = collisions
	end
end


-- remove cliff explosives from all cliffs
table.insert(data.raw.projectile["cliff-explosives"].action[1].action_delivery.target_effects, {
	type = "script",
	effect_id = "cliff-explosives"
})
data.raw.capsule["cliff-explosives"].capsule_action.type = "throw"
for _,c in pairs(data.raw.cliff) do
	c.cliff_explosive = nil
end
