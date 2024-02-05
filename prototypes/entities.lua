require "util"

local item_elevator_input = table.deepcopy(data.raw.container["steel-chest"])
item_elevator_input.name = "item-elevator-input"
item_elevator_input.inventory_size = 1
item_elevator_input.minable.result = "item-elevator-input"
item_elevator_input.fast_replaceable_group = nil

local item_elevator_output = table.deepcopy(data.raw.container["steel-chest"])
item_elevator_output.name = "item-elevator-output"
item_elevator_output.inventory_size = 1
item_elevator_output.minable.result = "item-elevator-output"
item_elevator_output.fast_replaceable_group = nil

local fluid_elevator_input = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_elevator_input.name = "fluid-elevator-input"
fluid_elevator_input.minable.result = "fluid-elevator-input"
fluid_elevator_input.fluid_box.base_area = 10
fluid_elevator_input.fluid_box.pipe_connections[1]["type"] = "input"
fluid_elevator_input.fluid_box.pipe_connections[2]["type"] = "input"
fluid_elevator_input.fluid_box.pipe_connections[3]["type"] = "input"
fluid_elevator_input.fluid_box.pipe_connections[4]["type"] = "input"
fluid_elevator_input.fluid_box.hide_connection_info = false
fluid_elevator_input.two_direction_only = false

local fluid_elevator_output = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_elevator_output.name = "fluid-elevator-output"
fluid_elevator_output.minable.result = "fluid-elevator-output"
fluid_elevator_output.fluid_box.base_area = 10
fluid_elevator_output.fluid_box.pipe_connections[1]["type"] = "output"
fluid_elevator_output.fluid_box.pipe_connections[2]["type"] = "output"
fluid_elevator_output.fluid_box.pipe_connections[3]["type"] = "output"
fluid_elevator_output.fluid_box.pipe_connections[4]["type"] = "output"
fluid_elevator_output.fluid_box.hide_connection_info = false
fluid_elevator_output.two_direction_only = false

--[[local subsurface_walls = table.deepcopy(data.raw["simple-entity"]["rock-big"])
subsurface_walls.name = "subsurface-wall"
subsurface_walls.resistances = {
	{type = "physical", percent = 100},
	{type = "impact", percent = 100},
	{type = "explosion", percent = 100},
	{type = "fire", percent = 100},
	{type = "laser", percent = 100}
}
subsurface_walls.flags = {"placeable-neutral", "not-on-map"}
subsurface_walls.minable = {
	mining_particle = "stone-particle",
	mining_time = 1,
	results = {{name = "stone", amount_min = 10, amount_max = 30}}
}
subsurface_walls.selection_box = {{-1.0, -1.0}, {1.0, 1.0}}
subsurface_walls.collision_box = {{-1.1, -1.1}, {1.1, 1.1}}
for _,p in ipairs(data.raw["simple-entity"]["rock-huge"].pictures) do
	table.insert(subsurface_walls.pictures, p)
end
for _,p in ipairs(data.raw["optimized-decorative"]["rock-medium"].pictures) do
	table.insert(subsurface_walls.pictures, p)
end]]
local wall_pictures = table.deepcopy(data.raw["simple-entity"]["rock-big"].pictures)
for _,p in ipairs(data.raw["simple-entity"]["rock-huge"].pictures) do
	table.insert(wall_pictures, p)
end
--[[for _,p in ipairs(data.raw["optimized-decorative"]["rock-medium"].pictures) do
	table.insert(wall_pictures, p)
end]]
local subsurface_walls = {
	type = "cliff",
	name = "subsurface-wall",
    icon = "__base__/graphics/icons/rock-huge.png",
    icon_size = 64, icon_mipmaps = 4,
	flags = {"placeable-neutral", "not-on-map"},
	minable = {
		mining_particle = "stone-particle",
		mining_time = 1,
		results = {{name = "stone", amount_min = 10, amount_max = 30}}
	},
	selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
	collision_box = {{-1.1, -1.1}, {1.1, 1.1}},
	mined_sound = data.raw.cliff.cliff.mined_sound,
	vehicle_impact_sound = data.raw.cliff.cliff.vehicle_impact_sound,
    cliff_explosive = "cliff-explosives",
	grid_offset = {0, 0},
	grid_size = {1, 1},
	orientations = {
		west_to_east   = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		north_to_south = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		east_to_west   = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		south_to_north = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		west_to_north  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		north_to_east  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		east_to_south  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		south_to_west  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		west_to_south  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		north_to_west  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		east_to_north  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		south_to_east  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		west_to_none   = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		none_to_east   = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		north_to_none  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		none_to_south  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		east_to_none   = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		none_to_west   = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		south_to_none  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
		none_to_north  = {pictures = wall_pictures, collision_bounding_box = {{-1.1, -1.1}, {1.1, 1.1}}, fill_volume = 0},
	}
}

local blank_image = {
	filename = "__core__/graphics/empty.png",
	priority = "high",
	width = 1,
	height = 1
}

data:extend(
{
  {
	type = "electric-pole",
	name = "tunnel-entrance-cable",
	icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
	icon_size = 32,
	max_health = 250,
	corpse = "big-remnants",
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
	render_layer = "object",
	order="zzz",
	pictures =
	{
	  layers =
	  {
		{
		  filename = "__base__/graphics/entity/big-electric-pole/big-electric-pole.png",
		  priority = "extra-high",
		  width = 76,
		  height = 156,
		  direction_count = 1,
		  shift = util.by_pixel(1, -51),
		  hr_version =
		  {
			filename = "__base__/graphics/entity/big-electric-pole/hr-big-electric-pole.png",
			priority = "extra-high",
			width = 148,
			height = 312,
			direction_count = 1,
			shift = util.by_pixel(0, -51),
			scale = 0.5
		  }
		},
		{
		  filename = "__base__/graphics/entity/big-electric-pole/big-electric-pole-shadow.png",
		  priority = "extra-high",
		  width = 188,
		  height = 48,
		  direction_count = 1,
		  shift = util.by_pixel(60, 0),
		  draw_as_shadow = true,
		  hr_version =
		  {
			filename = "__base__/graphics/entity/big-electric-pole/hr-big-electric-pole-shadow.png",
			priority = "extra-high",
			width = 374,
			height = 94,
			direction_count = 1,
			shift = util.by_pixel(60, 0),
			draw_as_shadow = true,
			scale = 0.5
		  }
		}
	  }
	},
	connection_points =
	{
	  {
		shadow =
		{
		  copper = {1.2, 0},
		  green = {1.2, 0.6},
		  red = {1.2, -0.6}
		},
		wire =
		{
		  copper = {1.2, 0},
		  green = {1.2, 0.6},
		  red = {1.2, -0.6}
		}
	  }
	},
	radius_visualisation_picture =
	{
	  filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
	  width = 12,
	  height = 12,
	  priority = "extra-high-no-scale"
	},
	resistances =
	{
	  {type = "physical", percent = 100},
	  {type = "impact", percent = 100},
	  {type = "explosion", percent = 100},
	  {type = "fire", percent = 100},
	  {type = "laser", percent = 100}
	},
	circuit_wire_max_distance = 7.5,
	maximum_wire_distance = 5,
	supply_area_distance = 2,
  },
  {
	  type = "car",
	  name = "tunnel-entrance",
	  icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
	  icon_size = 32,
	  collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	  selection_box = {{0, 0}, {0, 0}},
	  collision_mask = {},
	  has_belt_immunity = true,
	  animation = {
		layers = {
		  {
			animation_speed = 1,
			direction_count = 1,
			filename = "__core__/graphics/empty.png",
			frame_count = 1,
			height = 1,
			width = 1
		  },
		}
	  },
	  braking_power = "200kW",
	  burner = {
		effectivity = 1,
		fuel_category = "chemical",
		fuel_inventory_size = 0,
		render_no_power_icon = false
	  },
	  consumption = "150kW",
	  effectivity = 0.5,
	  energy_per_hit_point = 1,
	  flags = {"placeable-neutral", "placeable-off-grid"},
	  friction = 0.9,
	  inventory_size = 0,
	  max_health = 45000,
	  open_sound = {
		filename = "__base__/sound/car-door-open.ogg",
		volume = 0.7
	  },
	  close_sound = {
		filename = "__base__/sound/car-door-close.ogg",
		volume = 0.7
	  },
	  render_layer = "object",
	  rotation_speed = 0.00,
	  order = "zz",
	  selectable_in_game = false,
	  weight = 700,
	  minimap_representation = blank_image,
	  selected_minimap_representation = blank_image,
  },
  {
	type = "electric-pole",
	name = "tunnel-exit-cable",
	icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
	icon_size = 32,
	max_health = 250,
	corpse = "big-remnants",
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
	render_layer = "object",
	order="zzz",
	pictures =
	{
	  layers =
	  {
		{
		  filename = "__base__/graphics/entity/big-electric-pole/big-electric-pole.png",
		  priority = "extra-high",
		  width = 76,
		  height = 156,
		  direction_count = 1,
		  shift = util.by_pixel(1, -51),
		  hr_version =
		  {
			filename = "__base__/graphics/entity/big-electric-pole/hr-big-electric-pole.png",
			priority = "extra-high",
			width = 148,
			height = 312,
			direction_count = 1,
			shift = util.by_pixel(0, -51),
			scale = 0.5
		  }
		},
		{
		  filename = "__base__/graphics/entity/big-electric-pole/big-electric-pole-shadow.png",
		  priority = "extra-high",
		  width = 188,
		  height = 48,
		  direction_count = 1,
		  shift = util.by_pixel(60, 0),
		  draw_as_shadow = true,
		  hr_version =
		  {
			filename = "__base__/graphics/entity/big-electric-pole/hr-big-electric-pole-shadow.png",
			priority = "extra-high",
			width = 374,
			height = 94,
			direction_count = 1,
			shift = util.by_pixel(60, 0),
			draw_as_shadow = true,
			scale = 0.5
		  }
		}
	  }
	},
	connection_points =
	{
	  {
		shadow =
		{
		  copper = {1.2, -3},
		  green = {1.2, -3.6},
		  red = {1.2, -2.4}
		},
		wire =
		{
		  copper = {1.2, -3},
		  green = {1.2, -3.6},
		  red = {1.2, -2.4}
		}
	  }
	},
	radius_visualisation_picture =
	{
	  filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
	  width = 12,
	  height = 12,
	  priority = "extra-high-no-scale"
	},
	resistances =
	{
	  {type = "physical", percent = 100},
	  {type = "impact", percent = 100},
	  {type = "explosion", percent = 100},
	  {type = "fire", percent = 100},
	  {type = "laser", percent = 100}
	},
	circuit_wire_max_distance = 7.5,
	maximum_wire_distance = 5,
	supply_area_distance = 2,
  },
  {
	  type = "car",
	  name = "tunnel-exit",
	  icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
	  icon_size = 32,
	  collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	  selection_box = {{0, 0}, {0, 0}},
	  collision_mask = {},
	  has_belt_immunity = true,
	  animation = {
		layers = {
		  {
			animation_speed = 1,
			direction_count = 1,
			filename = "__core__/graphics/empty.png",
			frame_count = 1,
			height = 1,
			width = 1
		  },
		}
	  },
	  braking_power = "200kW",
	  burner = {
		effectivity = 1,
		fuel_category = "chemical",
		fuel_inventory_size = 0,
		render_no_power_icon = false
	  },
	  consumption = "150kW",
	  effectivity = 0.5,
	  energy_per_hit_point = 1,
	  flags = {"placeable-neutral", "placeable-off-grid"},
	  friction = 0.9,
	  inventory_size = 0,
	  max_health = 45000,
	  open_sound = {
		filename = "__base__/sound/car-door-open.ogg",
		volume = 0.7
	  },
	  close_sound = {
		filename = "__base__/sound/car-door-close.ogg",
		volume = 0.7
	  },
	  render_layer = "object",
	  rotation_speed = 0.00,
	  order = "zz",
	  selectable_in_game = false,
	  weight = 700,
	  minimap_representation = blank_image,
	  selected_minimap_representation = blank_image,
  },
  {
	type = "assembling-machine",
	name = "surface-driller",
	icon = "__base__/graphics/icons/assembling-machine-1.png",
	icon_size = 64, icon_mipmaps = 4,
	flags = {"placeable-player", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "surface-driller"},
	max_health = 200,
	corpse = "big-remnants",
	dying_explosion = "massive-explosion",
	crafting_categories = {"digging"},
	ingredient_count = 0,
	fixed_recipe = "drilling",
	collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
	selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
	animation =
	{
	  filename = "__Subsurface__/graphics/entities/big-assembly.png",
	  priority="high",
	  width = 165,
	  height = 170,
	  frame_count = 32,
	  line_length = 8,
	  shift = {0.417, -0.167}
	},
	crafting_speed = 1,
	energy_source =
	{
	  type = "electric",
	  usage_priority = "secondary-input",
	  emissions = 0.05 / 1.5
	},
	energy_usage = "50kW",
	open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
	close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	working_sound =
	{
	  sound = { filename = "__base__/sound/oil-refinery.ogg" },
	  idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
	  apparent_volume = 2.5,
	},
  },
	
  {
	type = "assembling-machine",
	name = "active-air-vent",
	icon = "__Subsurface__/graphics/icons/air_vent_22_icon.png",
	icon_size = 32, icon_mipmaps = 1,
	flags = {"placeable-player", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "active-air-vent"},
	max_health = 200,
	crafting_categories = {"venting"},
	fixed_recipe = "venting",
	ingredient_count = 0,
	collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
	selection_box = {{-1, -1}, {1, 1}},
	animation =
	{
	  filename = "__Subsurface__/graphics/entities/air_vent22_sheet.png",
	  priority="high",
	  width = 96,
	  height = 96,
	  frame_count = 16,
	  line_length = 4,
	  shift = {0.45,-0.1},
	  animation_speed = 2,
	},
	crafting_speed = 1,
	energy_source =
	{
	  type = "electric",
	  usage_priority = "secondary-input",
	  emissions = 0
	},
	energy_usage = "50kW",
  },

  {
	type = "simple-entity",
	name = "air-vent",
	flags = {"placeable-neutral", "not-on-map"},
	collision_mask = { "item-layer", "object-layer", "player-layer", "water-tile"},
	icon = "__Subsurface__/graphics/icons/air_vent_11_icon.png",
	icon_size = 32, icon_mipmaps = 1,
	minable = {mining_time = 1, result = "air-vent"},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	render_layer = "decorative",
	max_health = 350,
	order = "z",
	pictures =
	{
	  {
		filename = "__Subsurface__/graphics/entities/air_vent_11.png",
		width = 64,
		height = 64,
	  }
	},
  },  
  item_elevator_input,
  item_elevator_output,
  fluid_elevator_input,
  fluid_elevator_output,
  subsurface_walls
})