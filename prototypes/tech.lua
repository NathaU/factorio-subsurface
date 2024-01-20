data:extend(
{
  {
    type = "technology",
    name = "surface-drilling",
    icon = "__base__/graphics/icons/electric-mining-drill.png",
	icon_size = 32,
    effects =
    {
      {type = "unlock-recipe", recipe = "surface-driller"},
    },
    prerequisites = {},
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1}
      },
      time = 30
    },
    order = "c-g-b-z-a",
  },
  {
    type = "technology",
    name = "inter-surface-transport",
    icon = "__base__/graphics/icons/electric-mining-drill.png",
	icon_size = 32,
    effects =
    {
      {type = "unlock-recipe", recipe = "item-elevator-input"},
	  {type = "unlock-recipe", recipe = "item-elevator-output"},
	  {type = "unlock-recipe", recipe = "fluid-elevator-input"},
	  {type = "unlock-recipe", recipe = "fluid-elevator-output"}
    },
    prerequisites = {"surface-drilling"},
    unit = {
      count = 500,
      ingredients = {
        {"automation-science-pack", 1},
		{"logistic-science-pack", 1},
      },
      time = 20
    },
    order = "c-g-b-z-b",
  },
  {
    type = "technology",
    name = "air-vents",
    icon = "__Subsurface__/graphics/icons/air_vent_22_icon.png",
    icon_size = 32,
    effects =
    {
      {type = "unlock-recipe", recipe = "air-vent"},
	  {type = "unlock-recipe", recipe = "active-air-vent"},
    },
    prerequisites = {"surface-drilling"},
    unit = {
      count = 50,
      ingredients = {
        {"automation-science-pack", 1},
      },
      time = 60
    },
    order = "c-g-b-z-b",
  },
})