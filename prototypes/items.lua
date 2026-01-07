data:extend(
{
  {
	type = "item",
	name = "surface-drill",
	icons = {
	  {
		icon = "__base__/graphics/icons/burner-mining-drill.png"
	  },
	  {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	  }
	},
	subgroup = "extraction-machine",
	order = "ca",
	place_result = "surface-drill-placer",
	stack_size = 5
  },
  {
	type = "item",
	name = "prospector",
	icon = "__Subsurface__/graphics/icons/prospector.png",
	subgroup = "production-machine",
	order = "z",
	place_result = "prospector",
	stack_size = 50
  },
  
  {
	type = "item",
	name = "fluid-elevator",
	localised_name = {"item-name.fluid-elevator"},
	icons = {
	  {
		icon = data.raw["pipe-to-ground"]["pipe-to-ground"].icon
	  },
	  {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	  }
	},
	subgroup = "inter-surface-transport",
	order = "c-b",
	place_result = "fluid-elevator-input",
	stack_size = 10
  },
  {
	type = "item",
	name = "heat-elevator",
	icons = {
	  {
		icon = data.raw.item["heat-pipe"].icon
	  },
	  {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	  }
	},
	subgroup = "inter-surface-transport",
	order = "c-c",
	place_result = "heat-elevator",
	stack_size = 10
  },
  
  {
	type = "item",
	name = "air-vent",
	icon = "__Subsurface__/graphics/icons/air_vent_11_icon.png",
	icon_size = 32,
	subgroup = "inter-surface-transport",
	order = "b-a",
	place_result = "air-vent",
	stack_size = 50
  }, 
  {
	type = "item",
	name = "active-air-vent",
	icon = "__Subsurface__/graphics/icons/air_vent_22_icon.png",
	icon_size = 32,
	subgroup = "inter-surface-transport",
	order = "b-b",
	place_result = "active-air-vent",
	stack_size = 50
  },
  {
	type = "capsule",
	name = "cave-sealing",
	icon = "__base__/graphics/icons/big-rock.png",
	flags = {"hide-from-bonus-gui"},
	capsule_action =
	{
	  type = "throw",
	  attack_parameters =
	  {
		type = "projectile",
		activation_type = "throw",
		ammo_category = "grenade",
		cooldown = 30,
		projectile_creation_distance = 0.6,
		range = 5,
		ammo_type =
		{
		  category = "grenade",
		  target_type = "direction",
		  action =
		  {
			type = "direct",
			action_delivery =
			{
			  type = "projectile",
			  projectile = "cave-sealing",
			  starting_speed = 0.3
			}
		  }
		}
	  }
	},
	subgroup = "terrain",
	order = "d[rock-explosives]z",
	stack_size = 10
  },
  
  {
	type = "item",
	name = "wooden-support",
	icon = "__Subsurface__/graphics/icons/wooden-support.png",
	subgroup = "inter-surface-transport",
	order = "a-a",
	place_result = "wooden-support",
	stack_size = 50
  },
  {
	type = "item",
	name = "steel-support",
	icon = "__Subsurface__/graphics/icons/steel-support.png",
	subgroup = "inter-surface-transport",
	order = "a-b",
	place_result = "steel-support",
	stack_size = 50
  },

  {
	type = "item",
	name = "subway",
	icons = {
		{
		  icon = data.raw["straight-rail"]["straight-rail"].icon
		},
		{
		  icon = "__Subsurface__/graphics/icons/elevator.png",
		  icon_size = 32,
		}
	  },
	subgroup = "inter-surface-transport",
	order = "c-d",
	place_result = "subway",
	stack_size = 2
  },

  {
	type = "item",
	name = "caveground",
	localised_name = {"tile-name.caveground"},
	icon = "__Subsurface__/graphics/terrain/underground-dirt.png",
	icon_size = 32,
	flags = {"not-stackable"},
	stack_size = 1,
	place_as_tile = {result = "caveground", condition = {layers = {}}, condition_size = 1},
  }
})