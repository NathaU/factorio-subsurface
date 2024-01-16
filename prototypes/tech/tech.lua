data:extend(
{
  {
    type = "technology",
    name = "tunnel-entrance",
    icon = "__base__/graphics/icons/electric-mining-drill.png",
	icon_size = 32,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "surface-driller"
      },
	  {
        type = "unlock-recipe",
        recipe = "air-vent"
      },
	  {
        type = "unlock-recipe",
        recipe = "active-air-vent"
      },
	  {
        type = "unlock-recipe",
        recipe = "mobile-borer"
      },
	  {
        type = "unlock-recipe",
        recipe = "fluid-elevator-mk1"
      }
    },
    prerequisites = {},
    unit = {
      count = 5,
      ingredients = {
        {"automation-science-pack", 1}
      },
      time = 1
    },
    order = "c-g-b-z-a",
  },
  {
    type = "technology",
    name = "automated-boring",
    icon = "__base__/graphics/icons/electric-mining-drill.png",
	icon_size = 32,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "digging-robots-deployment-center"
      },
	  {
        type = "unlock-recipe",
        recipe = "assemble-digging-robots"
      },
	  {
        type = "unlock-recipe",
        recipe = "deploy-digging-robots"
      },
	  {
        type = "unlock-recipe",
        recipe = "digging-planner"
      }
    },
    prerequisites = {"mining-productivity-1"},
    unit = {
      count = 10,
      ingredients = {
        {"automation-science-pack", 1},
		{"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
      },
      time = 2
    },
    order = "c-g-b-z-b",
  }
})