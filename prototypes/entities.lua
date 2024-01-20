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
fluid_elevator_input.fluid_box.pipe_connections[1]["type"] = "input"
fluid_elevator_input.fluid_box.pipe_connections[2]["type"] = "input"
fluid_elevator_input.fluid_box.pipe_connections[3]["type"] = "input"
fluid_elevator_input.fluid_box.pipe_connections[4]["type"] = "input"
fluid_elevator_input.fluid_box.hide_connection_info = false
fluid_elevator_input.two_direction_only = false

local fluid_elevator_output = table.deepcopy(data.raw["storage-tank"]["storage-tank"])
fluid_elevator_output.name = "fluid-elevator-output"
fluid_elevator_output.minable.result = "fluid-elevator-output"
fluid_elevator_output.fluid_box.pipe_connections[1]["type"] = "output"
fluid_elevator_output.fluid_box.pipe_connections[2]["type"] = "output"
fluid_elevator_output.fluid_box.pipe_connections[3]["type"] = "output"
fluid_elevator_output.fluid_box.pipe_connections[4]["type"] = "output"
fluid_elevator_output.fluid_box.hide_connection_info = false
fluid_elevator_output.two_direction_only = false

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
	minable = {mining_time = 1},
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
	  {type = "fire", percent = 100}
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
	minable = {mining_time = 1},
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
	  {type = "fire", percent = 100}
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
	type = "wall",
	name = "subsurface-wall",
	icon = "__base__/graphics/icons/wall.png",
	icon_size = 64, icon_mipmaps = 4,
	minable = {mining_time = 1, result = "stone",count = 20},
	flags = {"placeable-neutral", "not-on-map"},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
	--collision_mask = {"player-layer"}, -- these walls are just for the visuals, only players collide
	max_health = 350,
	corpse = "wall-remnants",
	repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
	mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
	vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
	order = "z",
	resistances =
	{
	  { type = "physical", percent = 100 },
	  { type = "impact", percent = 100 },
	  { type = "explosion", percent = 100 },
	  { type = "fire", percent = 100 },
	  { type = "laser", percent = 100 }
	},
	pictures =
	{
	  single = {layers = {{filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1, shift = {0, 0}}}},
	  straight_vertical = {{layers = {{filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1, shift = {0, 0}}}}},
	  straight_horizontal = {{layers = {{filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1, shift = {0, 0}}}}},
	  corner_right_down = {layers = {{filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1, shift = {0, 0}}}},
	  corner_left_down = {layers = {{filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1, shift = {0, 0}}}},
	  t_up = {layers = {{filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1, shift = {0, 0}}}},
	  ending_right = {layers = {{filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1, shift = {0, 0}}}},
	  ending_left = {layers = {{filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1, shift = {0, 0}}}},
	}
  },
  {
	type = "resource",
	name = "subsurface-wall-resource",
	icon = "__base__/graphics/icons/wall.png",
	icon_size = 64, icon_mipmaps = 3,
	flags = {"placeable-neutral", "not-on-map"},
	order = "z",
	map_color = {r=0.35, g=0.10, b=0.10},
	minable = {mining_time = 1, result = "stone",count = 20},
	--collision_mask = {"item-layer", "object-layer", "player-layer", "resource-layer"},
	collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	stage_counts = {1},
	stages = {blank_image},
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
  
  --[[{
	type = "car",
	name = "mobile-borer",
	icon = "__base__/graphics/icons/car.png",
	icon_size = 64, icon_mipmaps = 4,
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 1, result = "mobile-borer"},
	max_health = 1500,
	corpse = "medium-remnants",
	dying_explosion = "medium-explosion",
	energy_per_hit_point = 0.2,
	order="z",
	crash_trigger = {
	  type = "play-sound",
	  sound =
	  {
		{
		  filename = "__base__/sound/car-crash.ogg",
		  volume = 0.25
		},
	  }
	},
	resistances =
	{
	  {
		type = "impact",
		percent = 30,
		decrease = 30
	  }
	},
	collision_box = {{-0.7, -1}, {0.7, 1}},
	selection_box = {{-0.7, -1}, {0.7, 1}},
	effectivity = 1,
	braking_power = "1500kW",
	burner =
	{
	  effectivity = 0.70,
	  fuel_inventory_size = 3,
	  smoke =
	  {
		{
		  name = "car-smoke",
		  deviation = {0.25, 0.25},
		  frequency = 200,
		  position = {0, 1.5},
		  starting_frame = 0,
		  starting_frame_deviation = 60
		}
	  }
	},
	consumption = "1500kW",
	friction = 5e-2,
	light =
	{
	  {
		type = "oriented",
		minimum_darkness = 0.3,
		picture =
		{
		  filename = "__core__/graphics/light-cone.png",
		  priority = "medium",
		  scale = 2,
		  width = 200,
		  height = 200
		},
		shift = {-0.6, -14},
		size = 2,
		intensity = 0.6
	  },
	  {
		type = "oriented",
		minimum_darkness = 0.3,
		picture =
		{
		  filename = "__core__/graphics/light-cone.png",
		  priority = "medium",
		  scale = 2,
		  width = 200,
		  height = 200
		},
		shift = {0.6, -14},
		size = 2,
		intensity = 0.6
	  }
	},
	animation =
	{
	  layers =
	  {
		{
		  width = 102,
		  height = 86,
		  frame_count = 2,
		  direction_count = 64,
		  shift = {0, -0.1875},
		  animation_speed = 8,
		  max_advance = 0.2,
		  stripes =
		  {
			{
			 filename = "__base__/graphics/entity/car/car-1.png",
			 width_in_frames = 2,
			 height_in_frames = 22,
			},
			{
			 filename = "__base__/graphics/entity/car/car-2.png",
			 width_in_frames = 2,
			 height_in_frames = 22,
			},
			{
			 filename = "__base__/graphics/entity/car/car-3.png",
			 width_in_frames = 2,
			 height_in_frames = 20,
			},
		  }
		},
		{
		  width = 100,
		  height = 75,
		  frame_count = 2,
		  apply_runtime_tint = true,
		  direction_count = 64,
		  max_advance = 0.2,
		  line_length = 2,
		  shift = {0, -0.171875},
		  stripes = util.multiplystripes(2,
		  {
			{
			  filename = "__base__/graphics/entity/car/car-mask-1.png",
			  width_in_frames = 1,
			  height_in_frames = 22,
			},
			{
			  filename = "__base__/graphics/entity/car/car-mask-2.png",
			  width_in_frames = 1,
			  height_in_frames = 22,
			},
			{
			  filename = "__base__/graphics/entity/car/car-mask-3.png",
			  width_in_frames = 1,
			  height_in_frames = 20,
			},
		  })
		},
		{
		  width = 114,
		  height = 76,
		  frame_count = 2,
		  draw_as_shadow = true,
		  direction_count = 64,
		  shift = {0.28125, 0.25},
		  max_advance = 0.2,
		  stripes = util.multiplystripes(2,
		  {
		   {
			filename = "__base__/graphics/entity/car/car-shadow-1.png",
			width_in_frames = 1,
			height_in_frames = 22,
		   },
		   {
			filename = "__base__/graphics/entity/car/car-shadow-2.png",
			width_in_frames = 1,
			height_in_frames = 22,
		   },
		   {
			filename = "__base__/graphics/entity/car/car-shadow-3.png",
			width_in_frames = 1,
			height_in_frames = 20,
		   },
		  })
		}
	  }
	},
	sound_no_fuel =
	{
	  {
		filename = "__base__/sound/fight/car-no-fuel-1.ogg",
		volume = 0.6
	  },
	},
	stop_trigger_speed = 0.2,
	stop_trigger =
	{
	  {
		type = "play-sound",
		sound =
		{
		  {
			filename = "__base__/sound/car-breaks.ogg",
			volume = 0.6
		  },
		}
	  },
	},
	sound_minimum_speed = 0.2;
	vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	working_sound =
	{
	  sound =
	  {
		filename = "__base__/sound/car-engine.ogg",
		volume = 0.6
	  },
	  activate_sound =
	  {
		filename = "__base__/sound/car-engine-start.ogg",
		volume = 0.6
	  },
	  deactivate_sound =
	  {
		filename = "__base__/sound/car-engine-stop.ogg",
		volume = 0.6
	  },
	  match_speed_to_activity = true,
	},
	open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
	close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
	rotation_speed = 0.001,
	weight = 35000,
	tank_driving = true,
	inventory_size = 30
  },

  {
	type = "simple-entity",
	name = "boring-in-progress",
	flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
	icon = "__Subsurface__/graphics/icons/green-asterisk.png",
	icon_size = 32, icon_mipmaps = 1,
	subgroup = "grass",
	order = "b[decorative]-b[asterisk]-b[green]",
	collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selectable_in_game = false,
	render_layer = "entity-info-icon",
	pictures =
	{
	  {
		filename = "__Subsurface__/graphics/entities/digging-in-progress.png",
		width = 64,
		height = 55,
	  }
	}
  },

  

  
  

  {
	type = "simple-entity",
	name = "selection-marker",
	flags = {"not-on-map"},
	icon = "__Subsurface__/graphics/entities/selection-marker.png",
	icon_size = 32, icon_mipmaps = 1,
	collision_mask = {"ghost-layer"},
	subgroup = "grass",
	order = "b[decorative]-b[selection-marker]",
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selectable_in_game = false,
	render_layer = "selection-box",
	pictures =
	{
	  {
		filename = "__Subsurface__/graphics/entities/selection-marker.png",
		width = 32,
		height = 32,
		priority = "high",
	  }
	}
  },
  {
	type = "simple-entity",
	name = "digging-marker",
	flags = {},
	icon = "__Subsurface__/graphics/entities/marked-for-digging.png",
	icon_size = 32, icon_mipmaps = 1,
	collision_mask = { "ghost-layer"},
	subgroup = "grass",
	order = "b[decorative]-b[m2k-dbg-overlay-blue]",
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selectable_in_game = false,
	render_layer = "floor",
	pictures =
	{
	  {
		filename = "__Subsurface__/graphics/entities/marked-for-digging.png",
		width = 32,
		height = 32,
		priority = "high",
	  }
	}
  },
  {
	type = "simple-entity",
	name = "pending-digging",
	flags = {},
	icon = "__Subsurface__/graphics/entities/pending-digging.png",
	icon_size = 32, icon_mipmaps = 1,
	collision_mask = { "ghost-layer"},
	subgroup = "grass",
	order = "b[decorative]-b[m2k-dbg-overlay-blue]",
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selectable_in_game = false,
	render_layer = "floor",
	pictures =
	{
	  {
		filename = "__Subsurface__/graphics/entities/pending-digging.png",
		width = 32,
		height = 32,
		priority = "high",
	  }
	}
  },




  {
	type = "assembling-machine",
	name = "digging-robots-deployment-center",
	icon = "__base__/graphics/icons/assembling-machine-3.png",
	icon_size = 64, icon_mipmaps = 4,
	flags = {"placeable-player", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "digging-robots-deployment-center"},
	max_health = 200,
	corpse = "big-remnants",
	dying_explosion = "massive-explosion",
	crafting_categories = {"deploy-entity"},
	ingredient_count = 2,
	fixed_recipe = "deploy-digging-robots",
	collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
	selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	animation =
	{
	  filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3.png",
	  priority = "high",
	  width = 108,
	  height = 119,
	  frame_count = 32,
	  line_length = 8,
	  shift = {0.84, -0.09}
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
  },]]
  
  item_elevator_input,
  item_elevator_output,
  fluid_elevator_input,
  fluid_elevator_output
})