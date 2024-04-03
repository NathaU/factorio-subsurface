data:extend(
{
  {
	type = "recipe-category",
	name = "venting"
  },
  {
	type = "recipe-category",
	name = "prospecting"
  },
  
  {
	type = "recipe",
	name = "surface-drill",
	enabled = false,
	energy_required = 10,
	ingredients =
	{
	  {"electric-mining-drill", 5},
	},
	result = "surface-drill"
  },
  
  {
	type = "recipe",
	name = "prospector",
	enabled = false,
	ingredients =
	{
	  {"radar", 5},
	},
	result = "prospector"
  },
  
  {
	type = "recipe",
	name = "fluid-elevator",
	enabled = false,
	energy_required = 2,
	ingredients =
	{
	  {"pipe", 10},
	  {"pump", 2},
	},
	result = "fluid-elevator",
	result_count = 2
  },
  {
	type = "recipe",
	name = "item-elevator",
	enabled = false,
	energy_required = 2,
	ingredients =
	{
	  {"underground-belt", 2},
	  {"iron-gear-wheel", 10},
	  {"electronic-circuit", 10},
	},
	result = "item-elevator",
	result_count = 2
  },
  {
	type = "recipe",
	name = "air-vent",
	enabled = false,
	ingredients =
	{
	  {"iron-plate", 10},
	  {"steel-plate", 5},
	},
	result = "air-vent"
  }, 
  {
	type = "recipe",
	name = "active-air-vent",
	enabled = false,
	ingredients =
	{
	  {"plastic-bar", 10},
	  {"steel-plate", 5},
	  {"iron-gear-wheel", 5},
	  {"advanced-circuit", 10},
	},
	result = "active-air-vent"
  },
  {
	type = "recipe",
	name = "rock-explosives",
	enabled = false,
	energy_required = 8,
	ingredients =
	{
	  {"cliff-explosives", 10},
	},
	result = "rock-explosives"
  },
  
  {
	type = "recipe",
	name = "venting",
	icon = "__core__/graphics/empty.png",
	icon_size = 1,
	subgroup = "inter-surface-transport",
	enabled = true,
	hidden = true,
	category = "venting",
	energy_required = 1,
	ingredients = {},
	results = {}
  },
  {
	type = "recipe",
	name = "prospecting",
	icon = "__core__/graphics/empty.png",
	icon_size = 1,
	subgroup = "inter-surface-transport",
	enabled = true,
	hidden = true,
	category = "prospecting",
	energy_required = 100,
	ingredients = {},
	results = {}
  },
  {
	type = "recipe",
	name = "wooden-support",
	enabled = false,
	ingredients =
	{
	  {"small-electric-pole", 1},
	  {"small-lamp", 1},
	},
	result = "wooden-support"
  },
})
