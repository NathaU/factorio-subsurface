require "util"
require "circuit-connector-generated-definitions"

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

local subsurface_walls = table.deepcopy(data.raw["simple-entity"]["rock-big"])
subsurface_walls.name = "subsurface-wall"
subsurface_walls.resistances = {
	{type = "physical", percent = 100},
	{type = "impact", percent = 100},
	{type = "explosion", percent = 100},
	{type = "fire", percent = 100},
	{type = "laser", percent = 100}
}
subsurface_walls.flags = {"placeable-neutral", "not-on-map", "not-deconstructable"}
subsurface_walls.count_as_rock_for_filtered_deconstruction = false
subsurface_walls.minable = {
	mining_particle = "stone-particle",
	mining_time = 1,
	results = {{name = "stone", amount_min = 10, amount_max = 30}}
}
subsurface_walls.selection_box = {{-0.9, -0.9}, {0.9, 0.9}}
subsurface_walls.collision_box = {{-0.9, -0.9}, {0.9, 0.9}}
for _,p in ipairs(data.raw["simple-entity"]["rock-huge"].pictures) do
	table.insert(subsurface_walls.pictures, p)
end

local rock_explosives = table.deepcopy(data.raw.projectile["cliff-explosives"])
rock_explosives.name = "rock-explosives"
rock_explosives.animation.filename = "__Subsurface__/graphics/entities/rock-explosives.png"
rock_explosives.animation.hr_version.filename = "__Subsurface__/graphics/entities/hr-rock-explosives.png"
table.insert(rock_explosives.action[1].action_delivery.target_effects, {type = "script", effect_id = "rock-explosives"})

local blank_image = {
	filename = "__core__/graphics/empty.png",
	priority = "high",
	width = 1,
	height = 1
}

local ccd = circuit_connector_definitions.create(universal_connector_template, {
	{ variation = 17, main_offset = util.by_pixel(-36, 17), shadow_offset = util.by_pixel(12.5, 4), show_shadow = false }, -- N
	{ variation = 17, main_offset = util.by_pixel(-38, 5), shadow_offset = util.by_pixel(7, 1), show_shadow = false }, -- E
	{ variation = 17, main_offset = util.by_pixel(-37, 9), shadow_offset = util.by_pixel(10, 5), show_shadow = false }, -- S
	{ variation = 17, main_offset = util.by_pixel(-39, 14), shadow_offset = util.by_pixel(4.5, 7), show_shadow = false } -- W
})

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
	pictures = {
	  filename = "__Subsurface__/graphics/entities/entrance.png",
	  priority = "extra-high",
	  width = 100,
	  height = 71,
	  direction_count = 1,
	  --shift = util.by_pixel(1, -51),
	  hr_version =
	  {
		filename = "__Subsurface__/graphics/entities/entrance-hr.png",
		priority = "extra-high",
		width = 189,
		height = 134,
		direction_count = 1,
		--shift = util.by_pixel(0, -51),
		scale = 0.5
	  }
	},
	connection_points =
	{
	  {
		shadow =
		{
		  copper = {-0.7, -0.4},
		  green = {-0.3, -0.5},
		  red = {-1.0, -0.3}
		},
		wire =
		{
		  copper = {-0.7, -0.4},
		  green = {-0.3, -0.5},
		  red = {-1.0, -0.3}
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
	  collision_box = {{-1.4, -0.8}, {1.4, 1}},
	  selection_box = {{0, 0}, {0, 0}},
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
	pictures = {
	  filename = "__Subsurface__/graphics/entities/exit.png",
	  priority = "extra-high",
	  width = 70,
	  height = 150,
	  direction_count = 1,
	  shift = util.by_pixel(0, -32),
	  hr_version =
	  {
		filename = "__Subsurface__/graphics/entities/exit-hr.png",
		priority = "extra-high",
		width = 125,
		height = 268,
		direction_count = 1,
		shift = util.by_pixel(0, -32),
		scale = 0.5
	  }
	},
	connection_points =
	{
	  {
		shadow =
		{
		  copper = {0.6, -0.9},
		  green = {0.8, -0.8},
		  red = {0.3, -0.9}
		},
		wire =
		{
		  copper = {0.6, -0.9},
		  green = {0.8, -0.8},
		  red = {0.3, -0.9}
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
	  collision_box = {{-1, 0}, {1, 0.7}},
	  selection_box = {{0, 0}, {0, 0}},
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
	type = "mining-drill",
	name = "surface-drill",
	icon = "__base__/graphics/icons/burner-mining-drill.png",
	icon_size = 64, icon_mipmaps = 4,
	flags = {"placeable-player", "player-creation"},
	resource_categories = {"subsurface-hole"},
	minable = {hardness = 0.2, mining_time = 2, result = "surface-drill"},
	max_health = 300,
	corpse = "burner-mining-drill-remnants",
	dying_explosion = "burner-mining-drill-explosion",
	collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
	selection_box = {{-2.2, -2.2}, {2.2, 2.2}},
	damaged_trigger_effect = data.raw["mining-drill"]["burner-mining-drill"].damaged_trigger_effect,
	mining_speed = 0.1,
	energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = 5},
	energy_usage = "2MW",
	open_sound = data.raw["mining-drill"]["burner-mining-drill"].open_sound,
	close_sound = data.raw["mining-drill"]["burner-mining-drill"].close_sound,
	vehicle_impact_sound =  data.raw["mining-drill"]["burner-mining-drill"].vehicle_impact_sound,
	working_sound = data.raw["mining-drill"]["burner-mining-drill"].working_sound,
	resource_searching_radius = 0.49,
	vector_to_place_result = {-1, -2.6},
	animations = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"].animations),
	circuit_wire_connection_points = ccd.points,
	circuit_connector_sprites = ccd.sprites,
	circuit_wire_max_distance = default_circuit_wire_max_distance,
  },
  {
	type = "assembling-machine",
	name = "surface-drill-placer",
	icon = "__base__/graphics/icons/burner-mining-drill.png",
	icon_size = 64, icon_mipmaps = 4,
	flags = {"placeable-player", "player-creation"},
	max_health = 300,
	collision_box = {{-2.1, -2.2}, {2.2, 2.2}},
	selection_box = {{-2.2, -2.2}, {2.2, 2.2}},
	animation = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"].animations),
	energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = 5},
	energy_usage = "2MW",
	crafting_speed = 1,
	crafting_categories = {"crafting"},
  },
  {
	type = "resource",
	name = "subsurface-hole",
	icon = "__base__/graphics/icons/stone.png",
	icon_size = 64, icon_mipmaps = 4,
	category = "subsurface-hole",
	minable = {mining_time = 1, result = "stone", count = 20},
	stages = {blank_image},
	stage_counts = {0},
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
  
  {
	type = "assembling-machine",
	name = "prospector",
	icon = "__Subsurface__/graphics/icons/prospector.png",
	icon_size = 64, icon_mipmaps = 4,
	flags = {"placeable-player", "player-creation"},
	minable = {mining_time = 0.1, result = "prospector"},
	max_health = 250,
	corpse = "radar-remnants",
	dying_explosion = "radar-explosion",
	resistances = {
	  {type = "fire", percent = 70},
	  {type = "impact", percent = 30}
	},
	collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
	selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	energy_source = {
	  type = "electric",
	  usage_priority = "secondary-input"
	},
	energy_usage = "1MW",
	animation =
	{
	  layers =
	  {
		{
		  filename = "__Subsurface__/graphics/entities/prospector.png",
		  priority = "low",
		  width = 98,
		  height = 128,
		  frame_count = 64,
		  line_length = 8,
		  shift = util.by_pixel(1, -16),
		  hr_version =
		  {
			filename = "__Subsurface__/graphics/entities/hr-prospector.png",
			priority = "low",
			width = 196,
			height = 254,
			frame_count = 64,
			line_length = 8,
			shift = util.by_pixel(1, -16),
			scale = 0.5
		  }
		},
		{
		  filename = "__Subsurface__/graphics/entities/prospector-shadow.png",
		  priority = "low",
		  width = 172,
		  height = 94,
		  frame_count = 64,
		  line_length = 8,
		  shift = util.by_pixel(39,3),
		  draw_as_shadow = true,
		  hr_version =
		  {
			filename = "__Subsurface__/graphics/entities/hr-prospector-shadow.png",
			priority = "low",
			width = 343,
			height = 186,
			frame_count = 64,
			line_length = 8,
			shift = util.by_pixel(39.25,3),
			draw_as_shadow = true,
			scale = 0.5
		  }
		}
	  }
	},
	working_sound = table.deepcopy(data.raw.radar.radar.working_sound),
	crafting_speed = 1,
	crafting_categories = {"prospecting"},
	fixed_recipe = "prospecting"
  },
  
  {
	type = "electric-pole",
	name = "wooden-support",
	icon = "__Subsurface__/graphics/icons/wooden-support.png",
	icon_size = 64, icon_mipmaps = 4,
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.1, result = "wooden-support"},
	max_health = 100,
	corpse = "small-electric-pole-remnants",
	dying_explosion = "small-electric-pole-explosion",
	collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
	selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
	collision_mask = {"item-layer", "object-layer", "player-layer", "water-tile", "ground-tile"},
	damaged_trigger_effect = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].damaged_trigger_effect),
	drawing_box = {{-0.5, -2.6}, {0.5, 0.5}},
	maximum_wire_distance = 7.5,
	supply_area_distance = 3.5,
	vehicle_impact_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].vehicle_impact_sound),
	open_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].open_sound),
	close_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].close_sound),
	track_coverage_during_build_by_moving = true,
	pictures = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].pictures),
	connection_points = {
	  {
		shadow =
		{
		  copper = util.by_pixel(97, -0.5),
		  red = util.by_pixel(98.5, -0.5),
		  green = util.by_pixel(95.5, -0.5)
		},
		wire =
		{
		  copper = util.by_pixel(9.5, -70),
		  red = util.by_pixel(11, -70),
		  green = util.by_pixel(8.0, -70)
		}
	  },
	  {
		shadow =
		{
		  copper = util.by_pixel(76, 1),
		  red = util.by_pixel(77.5, 2.5),
		  green = util.by_pixel(74.5, -0.5)
		},
		wire =
		{
		  copper = util.by_pixel(-9.5, -73),
		  red = util.by_pixel(-7, -73),
		  green = util.by_pixel(-11.0, -73)
		}
	  },
	  {
		shadow =
		{
		  copper = util.by_pixel(83, 1),
		  red = util.by_pixel(83, -0.5),
		  green = util.by_pixel(83, 2.5)
		},
		wire =
		{
		  copper = util.by_pixel(-1, -74),
		  red = util.by_pixel(1.0, -74),
		  green = util.by_pixel(-3.5, -74)
		}
	  },
	  {
		shadow =
		{
		  copper = util.by_pixel(81.5, 3.5),
		  red = util.by_pixel(80, 3.5),
		  green = util.by_pixel(83, 3.5)
		},
		wire =
		{
		  copper = util.by_pixel(-0.5, -66),
		  red = util.by_pixel(-3, -66),
		  green = util.by_pixel(2, -66)
		}
	  }
	},
	radius_visualisation_picture = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].radius_visualisation_picture),
  },
  
  item_elevator_input,
  item_elevator_output,
  fluid_elevator_input,
  fluid_elevator_output,
  subsurface_walls,
  rock_explosives
})

data.raw["mining-drill"]["surface-drill"].animations.north.layers[1].scale = 2
data.raw["mining-drill"]["surface-drill"].animations.north.layers[1].hr_version.scale = 1
data.raw["mining-drill"]["surface-drill"].animations.north.layers[2].scale = 2
data.raw["mining-drill"]["surface-drill"].animations.north.layers[2].hr_version.scale = 1
data.raw["mining-drill"]["surface-drill"].animations.west.layers[1].scale = 2
data.raw["mining-drill"]["surface-drill"].animations.west.layers[1].hr_version.scale = 1
data.raw["mining-drill"]["surface-drill"].animations.west.layers[2].scale = 2
data.raw["mining-drill"]["surface-drill"].animations.west.layers[2].hr_version.scale = 1
data.raw["mining-drill"]["surface-drill"].animations.south.layers[1].scale = 2
data.raw["mining-drill"]["surface-drill"].animations.south.layers[1].hr_version.scale = 1
data.raw["mining-drill"]["surface-drill"].animations.south.layers[2].scale = 2
data.raw["mining-drill"]["surface-drill"].animations.south.layers[2].hr_version.scale = 1
data.raw["mining-drill"]["surface-drill"].animations.east.layers[1].scale = 2
data.raw["mining-drill"]["surface-drill"].animations.east.layers[1].hr_version.scale = 1
data.raw["mining-drill"]["surface-drill"].animations.east.layers[2].scale = 2
data.raw["mining-drill"]["surface-drill"].animations.east.layers[2].hr_version.scale = 1

data.raw["assembling-machine"]["surface-drill-placer"].animation.north.layers[1].scale = 2
data.raw["assembling-machine"]["surface-drill-placer"].animation.north.layers[1].hr_version.scale = 1
data.raw["assembling-machine"]["surface-drill-placer"].animation.north.layers[2].scale = 2
data.raw["assembling-machine"]["surface-drill-placer"].animation.north.layers[2].hr_version.scale = 1
data.raw["assembling-machine"]["surface-drill-placer"].animation.west.layers[1].scale = 2
data.raw["assembling-machine"]["surface-drill-placer"].animation.west.layers[1].hr_version.scale = 1
data.raw["assembling-machine"]["surface-drill-placer"].animation.west.layers[2].scale = 2
data.raw["assembling-machine"]["surface-drill-placer"].animation.west.layers[2].hr_version.scale = 1
data.raw["assembling-machine"]["surface-drill-placer"].animation.south.layers[1].scale = 2
data.raw["assembling-machine"]["surface-drill-placer"].animation.south.layers[1].hr_version.scale = 1
data.raw["assembling-machine"]["surface-drill-placer"].animation.south.layers[2].scale = 2
data.raw["assembling-machine"]["surface-drill-placer"].animation.south.layers[2].hr_version.scale = 1
data.raw["assembling-machine"]["surface-drill-placer"].animation.east.layers[1].scale = 2
data.raw["assembling-machine"]["surface-drill-placer"].animation.east.layers[1].hr_version.scale = 1
data.raw["assembling-machine"]["surface-drill-placer"].animation.east.layers[2].scale = 2
data.raw["assembling-machine"]["surface-drill-placer"].animation.east.layers[2].hr_version.scale = 1

data.raw["electric-pole"]["wooden-support"].pictures.layers[1].filename = "__Subsurface__/graphics/entities/wooden-support/wooden-support.png"
data.raw["electric-pole"]["wooden-support"].pictures.layers[1].hr_version.filename = "__Subsurface__/graphics/entities/wooden-support/hr-wooden-support.png"
data.raw["electric-pole"]["wooden-support"].pictures.layers[2].filename = "__Subsurface__/graphics/entities/wooden-support/wooden-support-shadow.png"
data.raw["electric-pole"]["wooden-support"].pictures.layers[2].hr_version.filename = "__Subsurface__/graphics/entities/wooden-support/hr-wooden-support-shadow.png"