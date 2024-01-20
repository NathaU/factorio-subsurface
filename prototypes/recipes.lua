data:extend(
{
  {
	type = "recipe",
	name = "surface-driller",
	enabled = true,
	ingredients =
	{
	  {"electric-mining-drill", 5},
	},
	result = "surface-driller"
  },
  {
	type = "recipe",
	name = "drilling",
	enabled = true,
	hidden = true,
	category = "digging",
	energy_required = 5,
	ingredients = {},
	results = {{type="item", name="stone", amount=50}}
  },
  
  {
	type = "recipe",
	name = "fluid-elevator-input",
	enabled = true,
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
	enabled = true,
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
	enabled = true,
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
	enabled = true,
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
	enabled = true,
	ingredients =
	{
	  {"plastic-bar", 10},
	  {"steel-plate", 5},
	  {"iron-gear-wheel", 5},
	  {"advanced-circuit", 10},
	},
	result = "air-vent"
  }, 
  {
	type = "recipe",
	name = "active-air-vent",
	enabled = true,
	ingredients =
	{
	  {"iron-plate", 10},
	  {"steel-plate", 5},
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
})