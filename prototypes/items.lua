data:extend(
{
  {
	type = "item",
	name = "surface-drill",
	icon = "__base__/graphics/icons/burner-mining-drill.png",
	icon_size = 64, icon_mipmaps = 4,
	subgroup = "production-machine",
	order = "a",
	place_result = "surface-drill-placer",
	stack_size = 5
  },
  {
	type = "item",
	name = "surface-drill-dummy",
	icon = "__base__/graphics/icons/burner-mining-drill.png",
	icon_size = 64, icon_mipmaps = 4,
	flags = {"hidden", "hide-from-bonus-gui"},
	subgroup = "production-machine",
	order = "a",
	place_result = "surface-drill",
	stack_size = 5
  },
  {
	type = "item",
	name = "prospector",
	icon = "__Subsurface__/graphics/icons/prospector.png",
	icon_size = 64, icon_mipmaps = 4,
	subgroup = "production-machine",
	order = "a",
	place_result = "prospector",
	stack_size = 50
  },
  {
	type = "item",
	name = "item-elevator-input",
	icon = "__Subsurface__/graphics/icons/items-elevator-icon.png",
	icon_size = 32, icon_mipmaps = 1,
	subgroup = "inter-surface-transport",
	order = "c[transport-belt]-c[items-elevator-mk1]",
	place_result = "item-elevator-input",
	stack_size = 10
  },
  {
	type = "item",
	name = "item-elevator-output",
	icon = "__Subsurface__/graphics/icons/items-elevator-icon.png",
	icon_size = 32, icon_mipmaps = 1,
	subgroup = "inter-surface-transport",
	order = "c[transport-belt]-c[items-elevator-mk1]",
	place_result = "item-elevator-output",
	stack_size = 10
  },
  {
	type = "item",
	name = "fluid-elevator-input",
	icon = "__Subsurface__/graphics/icons/fluid_elevator_mk1_icon.png",
	icon_size = 32, icon_mipmaps = 1,
	subgroup = "inter-surface-transport",
	order = "d[fluid]-a[fluid-elevator]",
	place_result = "fluid-elevator-input",
	stack_size = 10
  },
  {
	type = "item",
	name = "fluid-elevator-output",
	icon = "__Subsurface__/graphics/icons/fluid_elevator_mk1_icon.png",
	icon_size = 32, icon_mipmaps = 1,
	subgroup = "inter-surface-transport",
	order = "d[fluid]-a[fluid-elevator]",
	place_result = "fluid-elevator-output",
	stack_size = 10
  },
  {
	type = "item",
	name = "air-vent",
	icon = "__Subsurface__/graphics/icons/air_vent_11_icon.png",
	icon_size = 32, icon_mipmaps = 1,
	subgroup = "inter-surface-transport",
	order = "a[air-vent-passive]",
	place_result = "air-vent",
	stack_size = 50
  }, 
  {
	type = "item",
	name = "active-air-vent",
	icon = "__Subsurface__/graphics/icons/air_vent_22_icon.png",
	icon_size = 32, icon_mipmaps = 1,
	subgroup = "inter-surface-transport",
	order = "b[air-vent-active]",
	place_result = "active-air-vent",
	stack_size = 50
  },
  {
	type = "capsule",
	name = "rock-explosives",
	icon = "__Subsurface__/graphics/icons/rock-explosives.png",
	icon_size = 64, icon_mipmaps = 4,
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
		range = 10,
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
			  projectile = "rock-explosives",
			  starting_speed = 0.3
			}
		  }
		}
	  }
	},
	subgroup = "terrain",
	order = "d[rock-explosives]",
	stack_size = 10
  },
  {
	type = "item",
	name = "wooden-support",
	icon = "__Subsurface__/graphics/icons/wooden-support.png",
	icon_size = 64, icon_mipmaps = 4,
	subgroup = "inter-surface-transport",
	order = "b[air-vent-active]",
	place_result = "wooden-support",
	stack_size = 50
  },
})