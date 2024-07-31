require "util"
noise = require("noise")
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
	type = "noise-expression",
	name = "random-value-0-1",
	expression = noise.to_noise_expression{
	  type = "function-application",
	  function_name = "random-penalty",
	  arguments = {
		x = noise.var("x"),
		y = noise.var("y"),
		source = noise.to_noise_expression(100),
		amplitude = noise.to_noise_expression(100),
		seed = noise.var("map_seed")
	  }
	} / 100
  },
})
