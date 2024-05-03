require "util"
require "circuit-connector-generated-definitions"

local blank_image = {filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1}

local cave_sealing = table.deepcopy(data.raw.projectile["cliff-explosives"])
cave_sealing.name = "cave-sealing"
cave_sealing.animation = blank_image
cave_sealing.action[1].action_delivery.target_effects = {
	{type = "script", effect_id = "cave-sealing"},
	{type = "play-sound", sound = table.deepcopy(data.raw.tile["stone-path"].build_sound.large)}
}

for i=0,3,1 do
	local sealed_entrance = table.deepcopy(data.raw["simple-entity"]["rock-big"])
	sealed_entrance.name = "tunnel-entrance-sealed-"..i
	sealed_entrance.resistances = {
		{type = "physical", percent = 100},
		{type = "impact", percent = 100},
		{type = "explosion", percent = 100},
		{type = "fire", percent = 100},
		{type = "laser", percent = 100}
	}
	sealed_entrance.flags = {"placeable-neutral", "not-deconstructable", "hidden", "placeable-off-grid"}
	sealed_entrance.count_as_rock_for_filtered_deconstruction = false
	sealed_entrance.minable = nil
	sealed_entrance.selection_box = {{0, 0}, {0, 0}}
	sealed_entrance.collision_box = {{-1.4, -0.8}, {1.4, 1}}
	if i == 3 then
		sealed_entrance.collision_mask = {"water-tile"}
		sealed_entrance.render_layer = "ground-patch"
	end
	sealed_entrance.pictures = {
	  sheet = {
		filename = "__Subsurface__/graphics/entrance-sealed-"..i..".png",
		width = 100, height = 71,
		hr_version = {
		  filename = "__Subsurface__/graphics/hr-entrance-sealed-"..i..".png",
		  width = 189, height = 134,
		  scale = 0.5
		}
	  }
	}
	data:extend({sealed_entrance})
end

local ccd = circuit_connector_definitions.create(universal_connector_template, {
	{ variation = 17, main_offset = util.by_pixel(-36, 17), shadow_offset = util.by_pixel(12.5, 4), show_shadow = false }, -- N
	{ variation = 17, main_offset = util.by_pixel(-38, 5), shadow_offset = util.by_pixel(7, 1), show_shadow = false }, -- E
	{ variation = 17, main_offset = util.by_pixel(-37, 9), shadow_offset = util.by_pixel(10, 5), show_shadow = false }, -- S
	{ variation = 17, main_offset = util.by_pixel(-39, 14), shadow_offset = util.by_pixel(4.5, 7), show_shadow = false } -- W
})

local cliff_pics = table.deepcopy(data.raw["simple-entity"]["rock-big"].pictures)
for _,p in ipairs(data.raw["simple-entity"]["rock-huge"].pictures) do table.insert(cliff_pics, p) end
local cliff_collision_box = {{-0.9, -0.9}, {0.9, 0.9}}

data:extend(
{
  cave_sealing,
  
  {
	type = "cliff",
	name = "subsurface-wall",
	flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
	icon = table.deepcopy(data.raw["simple-entity"]["rock-huge"].icon),
	icon_size = table.deepcopy(data.raw["simple-entity"]["rock-huge"].icon_size),
	icon_mipmaps = table.deepcopy(data.raw["simple-entity"]["rock-huge"].icon_mipmaps),
	orientations = {
	  west_to_east = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  north_to_south = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  east_to_west  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  south_to_north  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  west_to_north  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  north_to_east  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  east_to_south  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  south_to_west  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  west_to_south  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  north_to_west  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  east_to_north  = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  south_to_east   = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  west_to_none   = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  none_to_east   = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  north_to_none   = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  none_to_south   = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  east_to_none   = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  none_to_west   = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  south_to_none   = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	  none_to_north    = {pictures = cliff_pics, collision_bounding_box = cliff_collision_box, fill_volume = 0},
	},
	grid_size = {1, 1},
	grid_offset = {0, 0},
	cliff_explosive = "cliff-explosives",
	selection_box = {{-0.9, -0.9}, {0.9, 0.9}},
	minable = {mining_particle = "stone-particle", mining_time = 1, results = {{name = "stone", amount_min = 10, amount_max = 30}}}
  },
  {
	type = "simple-entity",
	name = "subsurface-wall-map-border",
	localised_name = {"entity-name.subsurface-wall"},
	icon = table.deepcopy(data.raw["simple-entity"]["rock-huge"].icon),
	icon_size = table.deepcopy(data.raw["simple-entity"]["rock-huge"].icon_size),
	icon_mipmaps = table.deepcopy(data.raw["simple-entity"]["rock-huge"].icon_mipmaps),
	flags = {"placeable-neutral", "not-on-map", "placeable-off-grid", "not-deconstructable"},
	resistances = {
	  {type = "physical", percent = 100},
	  {type = "impact", percent = 100},
	  {type = "explosion", percent = 100},
	  {type = "fire", percent = 100},
	  {type = "laser", percent = 100}
	},
	count_as_rock_for_filtered_deconstruction = true,
	collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
	pictures = cliff_pics
  },
  
  {
	type = "electric-pole",
	name = "tunnel-entrance-cable",
	icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
	icon_size = 32,
	max_health = 250,
	flags = {"placeable-off-grid"},
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
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
	connection_points = {
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
	resistances = {
	  {type = "physical", percent = 100},
	  {type = "impact", percent = 100},
	  {type = "explosion", percent = 100},
	  {type = "fire", percent = 100},
	  {type = "laser", percent = 100}
	},
	open_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].open_sound),
	close_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].close_sound),
	circuit_wire_max_distance = 7.5,
	maximum_wire_distance = 5,
	supply_area_distance = 0,
  },
  {
	type = "car",
	name = "tunnel-entrance",
	icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
	icon_size = 32,
	flags = {"placeable-neutral", "placeable-off-grid"},
	collision_box = {{-1.4, -0.8}, {1.4, 1}},
	selection_box = {{0, 0}, {0, 0}},
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
	resistances = {
	  {type = "physical", percent = 100},
	  {type = "impact", percent = 100},
	  {type = "explosion", percent = 100},
	  {type = "fire", percent = 100},
	  {type = "laser", percent = 100}
	},
	braking_power = "200kW",
	energy_source = {type = "void"},
	consumption = "150kW",
	effectivity = 0.5,
	energy_per_hit_point = 1,
	friction = 0.9,
	inventory_size = 0,
	rotation_speed = 0.00,
	selectable_in_game = false,
	weight = 700,
	minimap_representation = {
	  filename = "__Subsurface__/graphics/icons/marker-entrance.png",
	  flags = {"icon"},
	  width = 32, height = 32
	},
	selected_minimap_representation = blank_image,
  },
  {
	type = "electric-pole",
	name = "tunnel-exit-cable",
	icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
	icon_size = 32,
	max_health = 250,
	flags = {"placeable-off-grid"},
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
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
	connection_points = {
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
	resistances = {
	  {type = "physical", percent = 100},
	  {type = "impact", percent = 100},
	  {type = "explosion", percent = 100},
	  {type = "fire", percent = 100},
	  {type = "laser", percent = 100}
	},
	open_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].open_sound),
	close_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].close_sound),
	circuit_wire_max_distance = 7.5,
	maximum_wire_distance = 5,
	supply_area_distance = 0,
  },
  {
	type = "car",
	name = "tunnel-exit",
	icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
	icon_size = 32,
	flags = {"placeable-neutral", "placeable-off-grid"},
	collision_box = {{-1, 0}, {1, 0.7}},
	selection_box = {{0, 0}, {0, 0}},
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
	resistances = {
	  {type = "physical", percent = 100},
	  {type = "impact", percent = 100},
	  {type = "explosion", percent = 100},
	  {type = "fire", percent = 100},
	  {type = "laser", percent = 100}
	},
	braking_power = "200kW",
	energy_source = {type = "void"},
	consumption = "150kW",
	effectivity = 0.5,
	energy_per_hit_point = 1,
	friction = 0.9,
	inventory_size = 0,
	rotation_speed = 0.00,
	selectable_in_game = false,
	weight = 700,
	minimap_representation = {
	  filename = "__Subsurface__/graphics/icons/marker-exit.png",
	  flags = {"icon"},
	  width = 32, height = 32
	},
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
	-- this dummy is needed to allow placement everywhere, not only over resources
	type = "assembling-machine",
	name = "surface-drill-placer",
	icon = "__base__/graphics/icons/burner-mining-drill.png",
	icon_size = 64, icon_mipmaps = 4,
	minable = {hardness = 0.2, mining_time = 2, result = "surface-drill"},
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
	flags = {"placeable-neutral", "not-on-map", "player-creation"},
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
  {
	type = "lamp",
	name = "support-lamp",
	icon = "__base__/graphics/icons/small-lamp.png",
	icon_size = 64, icon_mipmaps = 4,
	picture_on = blank_image,
	picture_off = blank_image,
	energy_source = {type = "electric", usage_priority = "lamp"},
	energy_usage_per_tick = "2KW",
	light = {intensity = 0.7, size = 15, color = {r=1.0, g=1.0, b=0.75}}
  },
  
  {
	type = "pump",
	name = "fluid-elevator-input",
	icon = "__Subsurface__/graphics/icons/fluid_elevator_mk1_icon.png",
	icon_size = 32, icon_mipmaps = 1,
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.2, result = "fluid-elevator"},
	max_health = 180,
	corpse = "small-remnants",
	dying_explosion = "medium-explosion",
	collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	working_sound = table.deepcopy(data.raw.pump.pump.working_sound),
	--damaged_trigger_effect = hit_effects.entity(),
	resistances = {
	  {type = "fire", percent = 80},
	  {type = "impact", percent = 30}
	},
	fluid_box = {
	  height = 4,
	  pipe_covers = pipecoverspictures(),
	  pipe_connections = {
		{position = {0, -1}, type="input"},
	  }
	},
	energy_source = {
	  type = "electric",
	  usage_priority = "secondary-input",
	  drain = "500W"
	},
	energy_usage = "14.5kW",
	pumping_speed = 100,
	vehicle_impact_sound = table.deepcopy(data.raw.pump.pump.vehicle_impact_sound),
	open_sound = table.deepcopy(data.raw.pump.pump.open_sound),
	close_sound = table.deepcopy(data.raw.pump.pump.close_sound),
	animations = {
	  north = {
		filename = "__Subsurface__/graphics/entities/fluid-elevator/up.png",
		width = 46,
		height = 52,
		frame_count = 8,
		shift = {0.09375, 0.03125},
		animation_speed = 0.5
	  },
	  east = {
		filename = "__Subsurface__/graphics/entities/fluid-elevator/right.png",
		width = 51,
		height = 56,
		frame_count = 8,
		shift = {0.265625, -0.21875},
		animation_speed = 0.5
	  },
	  south = {
		filename = "__Subsurface__/graphics/entities/fluid-elevator/down.png",
		width = 61,
		height = 58,
		frame_count = 8,
		shift = {0.421875, -0.125},
		animation_speed = 0.5
	  },
	  west = {
		filename = "__Subsurface__/graphics/entities/fluid-elevator/left.png",
		width = 56,
		height = 44,
		frame_count = 8,
		shift = {0.3125, 0.0625},
		animation_speed = 0.5
	  }
	},
  },
  {
	type = "pump",
	name = "fluid-elevator-output",
	icon = "__Subsurface__/graphics/icons/fluid_elevator_mk1_icon.png",
	icon_size = 32, icon_mipmaps = 1,
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.2, result = "fluid-elevator"},
	max_health = 180,
	corpse = "small-remnants",
	dying_explosion = "medium-explosion",
	create_ghost_on_death = false,
	collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	working_sound = table.deepcopy(data.raw.pump.pump.working_sound),
	--damaged_trigger_effect = hit_effects.entity(),
	resistances = {
	  {type = "fire", percent = 80},
	  {type = "impact", percent = 30}
	},
	fluid_box = {
	  height = 4,
	  pipe_covers = pipecoverspictures(),
	  pipe_connections = {
		{position = {0, -1}, type="output"},
	  }
	},
	energy_source = {type = "void"},
	energy_usage = "14.5kW",
	pumping_speed = 100,
	vehicle_impact_sound = table.deepcopy(data.raw.pump.pump.vehicle_impact_sound),
	open_sound = table.deepcopy(data.raw.pump.pump.open_sound),
	close_sound = table.deepcopy(data.raw.pump.pump.close_sound),
	animations = {
	  north = {
		filename = "__Subsurface__/graphics/entities/fluid-elevator/up.png",
		width = 46,
		height = 52,
		frame_count = 8,
		shift = {0.09375, 0.03125},
		animation_speed = 0.5
	  },
	  east = {
		filename = "__Subsurface__/graphics/entities/fluid-elevator/right.png",
		width = 51,
		height = 56,
		frame_count = 8,
		shift = {0.265625, -0.21875},
		animation_speed = 0.5
	  },
	  south = {
		filename = "__Subsurface__/graphics/entities/fluid-elevator/down.png",
		width = 61,
		height = 58,
		frame_count = 8,
		shift = {0.421875, -0.125},
		animation_speed = 0.5
	  },
	  west = {
		filename = "__Subsurface__/graphics/entities/fluid-elevator/left.png",
		width = 56,
		height = 44,
		frame_count = 8,
		shift = {0.3125, 0.0625},
		animation_speed = 0.5
	  }
	},
  },
  
  {
	type = "heat-interface",
	name = "heat-elevator",
	icons = {
	  {
		icon = data.raw["heat-pipe"]["heat-pipe"].icon,
		icon_size = data.raw["heat-pipe"]["heat-pipe"].icon_size,
		icon_mipmaps = data.raw["heat-pipe"]["heat-pipe"].icon_mipmaps
	  },
	  {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	  }
	},
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.5, result = "heat-elevator"},
	max_health = 200,
	corpse = "heat-pipe-remnants",
	dying_explosion = "heat-pipe-explosion",
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	resistances = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"].resistances),
	heat_buffer =
	{
	  max_temperature = 1000,
	  specific_heat = "5MJ",
	  max_transfer = "1GW",
	  default_temperature = 15,
	  min_working_temperature = 15,
	  connections =
	  {
		{position = {0, 0}, direction = defines.direction.north},
		{position = {0, 0}, direction = defines.direction.east},
		{position = {0, 0}, direction = defines.direction.south},
		{position = {0, 0}, direction = defines.direction.west}
	  }
	},
	picture = table.deepcopy(data.raw["heat-interface"]["heat-interface"].picture),
	working_sound = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"].working_sound),
  }
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
