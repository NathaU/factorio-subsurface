require("prototypes.entities")
require("prototypes.items")
require("prototypes.items-groups")
require("prototypes.recipes")
require("prototypes.tech")
require("prototypes.tiles")
require("prototypes.categories")

data:extend({
  {
	type = "custom-input",
	name = "subsurface-position",
	key_sequence = "",
	linked_game_control = "place-ping"
  },
})

table.insert(data.raw.projectile["cliff-explosives"].action[1].action_delivery.target_effects, {
	type = "script",
	effect_id = "cliff-explosives"
})
data.raw.capsule["cliff-explosives"].capsule_action.type = "throw"
data.raw.cliff.cliff.cliff_explosive = nil
