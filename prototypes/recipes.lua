data:extend(
{
  {
    type = "recipe-category",
    name = "venting"
  },
  
  {
	type = "recipe",
	name = "surface-drill",
	enabled = false,
	ingredients =
	{
	  {"electric-mining-drill", 5},
	},
	result = "surface-drill"
  },
  
  {
	type = "recipe",
	name = "fluid-elevator-input",
	enabled = false,
	ingredients =
	{
	  {"storage-tank", 1},
	  {"pipe", 10},
	  {"pump", 2},
	},
	result = "fluid-elevator-input"
  },
  {
	type = "recipe",
	name = "fluid-elevator-output",
	enabled = false,
	ingredients =
	{
	  {"storage-tank", 1},
	  {"pipe", 10},
	  {"pump", 2},
	},
	result = "fluid-elevator-output"
  },
  {
	type = "recipe",
	name = "item-elevator-input",
	enabled = false,
	ingredients =
	{
	  {"underground-belt", 4},
	  {"iron-gear-wheel", 10},
	  {"electronic-circuit", 10},
	},
	result = "item-elevator-input"
  },
  {
	type = "recipe",
	name = "item-elevator-output",
	enabled = false,
	ingredients =
	{
	  {"underground-belt", 4},
	  {"iron-gear-wheel", 10},
	  {"electronic-circuit", 10},
	},
	result = "item-elevator-output"
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
	name = "rock-explosives",
	enabled = false,
	energy_required = 8,
	ingredients =
	{
	  {"cliff-explosives", 10},
	},
	result = "rock-explosives"
  },
})