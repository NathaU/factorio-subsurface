local collision_mask_util = require("collision-mask-util")

for _,e in pairs(data.raw["rocket-silo"]) do
	local collisions = collision_mask_util.get_mask(e)
	collision_mask_util.add_layer(collisions, "layer-50")
	e.collision_mask = collisions
end