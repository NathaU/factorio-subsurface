require("prototypes.entities")
require("prototypes.items")
require("prototypes.items-groups")
require("prototypes.recipes")
require("prototypes.tech")
require("prototypes.tiles")

data:extend({
  {
	type = "custom-input",
	name = "subsurface-position",
	key_sequence = "",
	linked_game_control = "place-ping"
  },
  {
	type = "custom-input",
	name = "subsurface-rotate",
	key_sequence = "",
	linked_game_control = "rotate"
  },
  {
	type = "resource-category",
	name = "subsurface-hole"
  }
})
