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
  },
  
  {
	type = "sprite",
	name = "placement-indicator-1",
	filename = "__Subsurface__/graphics/indicator-1.png",
	width = 85, height = 85
  },
  {
	type = "sprite",
	name = "placement-indicator-2",
	filename = "__Subsurface__/graphics/indicator-2.png",
	width = 85, height = 85
  },
  {
	type = "sprite",
	name = "placement-indicator-3",
	filename = "__Subsurface__/graphics/indicator-3.png",
	width = 85, height = 85
  },
  {
	type = "sprite",
	name = "placement-indicator-4",
	filename = "__Subsurface__/graphics/indicator-4.png",
	width = 85, height = 85
  },
})
