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
	energy_required = 10,
	ingredients =
	{
	  {type = "item", name = "electric-mining-drill", amount = 5},
	},
	results = {{type = "item", name = "surface-drill", amount = 1}}
  },
  {
	type = "recipe",
	name = "surface-drilling-dummy",
	hidden = true,
	icon = "__core__/graphics/empty.png",
	category = "venting",
  },
  
  {
	type = "recipe",
	name = "prospector",
	enabled = false,
	ingredients =
	{
	  {type = "item", name = "radar", amount = 5},
	},
	results = {{type = "item", name = "prospector", amount = 1}}
  },
  
  {
	type = "recipe",
	name = "fluid-elevator",
	enabled = false,
	energy_required = 2,
	ingredients =
	{
	  {type = "item", name = "pipe", amount = 10},
	  {type = "item", name = "pump", amount = 2},
	},
	results = {{type = "item", name = "fluid-elevator", amount = 2}}
  },
  {
	type = "recipe",
	name = "heat-elevator",
	enabled = false,
	energy_required = 2,
	ingredients =
	{
	  {type = "item", name = "heat-pipe", amount = 10},
	},
	results = {{type = "item", name = "heat-elevator", amount = 2}}
  },
  
  {
	type = "recipe",
	name = "air-vent",
	enabled = false,
	ingredients =
	{
	  {type = "item", name = "iron-plate", amount = 10},
	  {type = "item", name = "steel-plate", amount = 5},
	},
	results = {{type = "item", name = "air-vent", amount = 1}}
  }, 
  {
	type = "recipe",
	name = "active-air-vent",
	enabled = false,
	ingredients =
	{
	  {type = "item", name = "iron-stick", amount = 10},
	  {type = "item", name = "steel-plate", amount = 5},
	  {type = "item", name = "iron-gear-wheel", amount = 5},
	  {type = "item", name = "electronic-circuit", amount = 2},
	},
	results = {{type = "item", name = "active-air-vent", amount = 1}}
  },
  {
	type = "recipe",
	name = "cave-sealing",
	enabled = false,
	energy_required = 20,
	ingredients =
	{
	  {type = "item", name = "stone", amount = 200},
	},
	results = {{type = "item", name = "cave-sealing", amount = 1}}
  },
  
  {
	type = "recipe",
	name = "venting",
	icon = "__core__/graphics/empty.png",
	hidden = true,
	category = "venting",
	energy_required = 60,
  },
  {
	type = "recipe",
	name = "wooden-support",
	enabled = false,
	ingredients =
	{
	  {type = "item", name = "small-electric-pole", amount = 1},
	  {type = "item", name = "small-lamp", amount = 1},
	},
	results = {{type = "item", name = "wooden-support", amount = 1}}
  },
  {
	type = "recipe",
	name = "steel-support",
	enabled = false,
	ingredients =
	{
	  {type = "item", name = "medium-electric-pole", amount = 1},
	  {type = "item", name = "small-lamp", amount = 1},
	},
	results = {{type = "item", name = "steel-support", amount = 1}}
  },

  {
	type = "recipe",
	name = "subway",
	enabled = false,
	ingredients =
	{
	  {type = "item", name = "rail", amount  =  6},
	  {type = "item", name = "refined-concrete", amount  =  600},
	},
	energy_required = 30,
	results  =  {{type = "item", name = "subway", amount = 2}}
  },
})
