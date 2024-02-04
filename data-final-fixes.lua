local collision_mask_util = require("collision-mask-util")

for _,e in pairs(data.raw["locomotive"]) do
	if e.name ~= "electric-locomotive" and e.name ~= "deg-electric-locomotive" then
		e.burner.emissions_per_minute = 10
	end
end


-- prevent entities from placing in subsurfaces

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