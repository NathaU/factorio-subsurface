require "util"
require("prototypes.entities")
require("prototypes.items")
require("prototypes.items-groups")
require("prototypes.recipes")
require("prototypes.tech")
require("prototypes.tiles")

local smoke = table.deepcopy(data.raw["trivial-smoke"]["smoke-building"])
smoke.name = "subsurface-smoke"
smoke.duration = 120
smoke.render_layer = "smoke"
smoke.fade_away_duration = 120
smoke.color = {0.25, 0.25, 0.25, 0.375}

data:extend({
  smoke,
  
  {
	type = "custom-input",
	name = "subsurface-pin",
	key_sequence = "",
	linked_game_control = "pin"
  },
  {
	type = "custom-input",
	name = "subsurface-rotate",
	key_sequence = "",
	linked_game_control = "rotate"
  },
  {
	type = "custom-input",
	name = "subsurface-driving",
	key_sequence = "",
	linked_game_control = "toggle-driving"
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
  {
	type = "sprite",
	name = "placement-indicator-5",
	filename = "__Subsurface__/graphics/indicator-5.png",
	width = 85, height = 85
  },
  {
	type = "sprite",
	name = "placement-indicator-6",
	filename = "__Subsurface__/graphics/indicator-6.png",
	width = 85, height = 85
  },
  {
	type = "sprite",
	name = "placement-indicator-subway-n",
	filename = "__Subsurface__/graphics/indicator-subway-n.png",
	width = 256, height = 512,
	shift = {1, -1}
  },
  {
	type = "sprite",
	name = "placement-indicator-subway-e",
	filename = "__Subsurface__/graphics/indicator-subway-e.png",
	width = 512, height = 256,
	shift = {2, -0.5},
	scale = 0.9
  },
  {
	type = "sprite",
	name = "placement-indicator-subway-s",
	filename = "__Subsurface__/graphics/indicator-subway-s.png",
	width = 256, height = 512,
	shift = {1, 0.5}
  },
  {
	type = "sprite",
	name = "placement-indicator-subway-w",
	filename = "__Subsurface__/graphics/indicator-subway-w.png",
	width = 512, height = 256,
	shift = {0, -0.5},
	scale = 0.9
  },
  {
	type = "sprite",
	name = "placement-indicator-up",
	filename = "__Subsurface__/graphics/indicator-subway-up.png",
	width = 35, height = 35
  },
  {
	type = "sprite",
	name = "placement-indicator-down",
	filename = "__Subsurface__/graphics/indicator-subway-down.png",
	width = 35, height = 35
  },
  {
	type = "sprite",
	name = "elevator",
	filename = "__Subsurface__/graphics/icons/elevator-sprite.png",
	width = 32, height = 32
  },
  
  {
	type = "noise-expression",
	name = "subsurface_random",
	expression = "random_penalty(x, y, 1000000, subsurface_seed, 1000000) / 1000000",
  },
  {
	type = "noise-expression",
	name = "subsurface_richness_multiplier",
	expression = "if(distance > 130, log2(subsurface_level + 1) + 0.1, subsurface_level == 0)",
  },
  {
	type = "noise-expression",
	name = "surface_stone_probability_multiplier",
	expression = "if(distance > 130, 0, 1)",
  },

  {
	type = "surface-property",
	name = "subsurface-level",
	default_value = 0,
	localised_unit_key = "description.rocket-capacity-value-short"
  },
})
