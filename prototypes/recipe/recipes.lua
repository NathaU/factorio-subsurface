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
      {"underground-belt", 2},
    },
    result = "item-elevator-input"
  },
  {
    type = "recipe",
    name = "item-elevator-output",
    enabled = true,
    ingredients =
    {
      {"underground-belt", 2},
    },
    result = "item-elevator-output"
  },  
  {
    type = "recipe",
    name = "air-vent",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "air-vent"
  }, 
  {
    type = "recipe",
    name = "active-air-vent",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 2},
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
  
 --[[ {
    type = "recipe",
    name = "mobile-borer",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "mobile-borer"
  },  
  
  
  
  
    

  {
    type = "recipe",
    name = "digging-robots-deployment-center",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "digging-robots-deployment-center"
  },

  {
    type = "recipe",
    name = "assemble-digging-robots",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "assembled-digging-robots"
  },

  {
    type = "recipe",
    name = "deploy-digging-robots",
    enabled = true,
    hidden = true,
    category = "deploy-entity",
    ingredients =
    {
      {"assembled-digging-robots", 1},
    },
    result = "prepared-digging-robots"
  },

  {
    type = "recipe",
    name = "digging-planner",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 2}
    },
    result = "digging-planner"
  },]]



})