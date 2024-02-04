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