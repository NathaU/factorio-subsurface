data:extend(
{
  {
	type = "technology",
	name = "surface-drilling",
	icon = "__Subsurface__/graphics/technology/surface-drilling.png",
	icon_size = 256,
	effects =
	{
	  {type = "unlock-recipe", recipe = "surface-drill"},
	},
	prerequisites = {"automation-2", "logistics-2"},
	unit = {
	  count = 200,
	  ingredients = {
		{"automation-science-pack", 1},
		{"logistic-science-pack", 1}
	  },
	  time = 30
	},
  },
  {
	type = "technology",
	name = "subsurface-exploration",
	icon = "__Subsurface__/graphics/technology/intersurface-logistics.png",
	icon_size = 256,
	effects =
	{
	  {type = "unlock-recipe", recipe = "wooden-support"},
	  {type = "unlock-recipe", recipe = "steel-support"},
	  {type = "unlock-recipe", recipe = "cave-sealing"},
	  {type = "unlock-recipe", recipe = "prospector"},
	},
	prerequisites = {"surface-drilling"},
	research_trigger = {
		type = "scripted",
		trigger_description = {"technology-trigger.subsurface-exploration"},
		icon = "__Subsurface__/graphics/icons/marker-entrance.png",
		icon_size = 32
	},
  },
  {
	type = "technology",
	name = "inter-surface-transport",
	icon = "__Subsurface__/graphics/technology/transport-tech.png",
	icon_size = 256,
	effects =
	{
	  {type = "unlock-recipe", recipe = "fluid-elevator"},
	  {type = "unlock-recipe", recipe = "heat-elevator"},
	  {type = "unlock-recipe", recipe = "subway"},
	},
	prerequisites = {"subsurface-exploration", "fluid-handling", "railway"},
	unit = {
	  count = 500,
	  ingredients = {
		{"automation-science-pack", 1},
		{"logistic-science-pack", 1},
	  },
	  time = 30
	},
  },
  {
	type = "technology",
	name = "ventilation",
	icon = "__Subsurface__/graphics/technology/ventilation.png",
	icon_size = 256,
	effects =
	{
	  {type = "unlock-recipe", recipe = "air-vent"},
	  {type = "unlock-recipe", recipe = "active-air-vent"},
	  {type = "unlock-recipe", recipe = "active-air-vent-2"},
	},
	prerequisites = {"subsurface-exploration"},
	research_trigger = {
		type = "scripted",
		trigger_description = {"technology-trigger.ventilation"},
		icon = "__Subsurface__/graphics/icons/pollution.png",
		icon_size = 64
	},
  },

  {
	type = "sprite",
	name = "pollution",
	filename = "__core__/graphics/icons/mip/side-map-menu-buttons.png",
	priority = "high",
	size = 64,
	mipmap_count = 2,
	y = 3 * 64,
	flags = {"gui-icon"}
  }
})