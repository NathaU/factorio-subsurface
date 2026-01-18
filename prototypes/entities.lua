require "circuit-connector-generated-definitions"
local collision_mask_util = require "collision-mask-util"

local blank_image = {filename = "__core__/graphics/empty.png", priority = "high", width = 1, height = 1}

local gravity_condition = function() return feature_flags["space_travel"] and {{property = "gravity", min = 0.1}} or nil end

local cave_sealing = table.deepcopy(data.raw.projectile["cliff-explosives"])
cave_sealing.name = "cave-sealing"
cave_sealing.animation = blank_image
cave_sealing.action[1].action_delivery.target_effects = {
	{type = "script", effect_id = "cave-sealing"},
	{type = "play-sound", sound = table.deepcopy(data.raw.tile["stone-path"].build_sound.large)}
}

for i = 0, 3 do
	local sealed_entrance = table.deepcopy(data.raw["simple-entity"]["big-rock"])
	sealed_entrance.name = "tunnel-entrance-sealed-"..i
	sealed_entrance.flags = {"placeable-neutral", "not-deconstructable", "placeable-off-grid"}
	sealed_entrance.count_as_rock_for_filtered_deconstruction = false
	sealed_entrance.autoplace = nil
	sealed_entrance.minable = nil
	sealed_entrance.hidden = true
	sealed_entrance.selection_box = {{0, 0}, {0, 0}}
	sealed_entrance.collision_box = {{-1.4, -0.8}, {1.4, 1}}
	if i == 3 then
		sealed_entrance.collision_mask = {layers = {doodad = true}}
		sealed_entrance.render_layer = "ground-patch"
	end
	sealed_entrance.pictures = {
	  sheet = {
		filename = "__Subsurface__/graphics/entrance-sealed-"..i..".png",
		width = 189, height = 134,
		scale = 0.5
	  }
	}
	data:extend({sealed_entrance})
end

local ccd = circuit_connector_definitions.create_vector(universal_connector_template, {
	{ variation = 17, main_offset = util.by_pixel(-36, 17), shadow_offset = util.by_pixel(12.5, 4), show_shadow = false }, -- N
	{ variation = 17, main_offset = util.by_pixel(-38, 5), shadow_offset = util.by_pixel(7, 1), show_shadow = false }, -- E
	{ variation = 17, main_offset = util.by_pixel(-37, 9), shadow_offset = util.by_pixel(10, 5), show_shadow = false }, -- S
	{ variation = 17, main_offset = util.by_pixel(-39, 14), shadow_offset = util.by_pixel(4.5, 7), show_shadow = false } -- W
})

local cliff_pics = table.deepcopy(data.raw["simple-entity"]["big-rock"].pictures)
for _, p in ipairs(data.raw["simple-entity"]["huge-rock"].pictures) do table.insert(cliff_pics, p) end
local cliff_collision_box = {{-0.9, -0.9}, {0.9, 0.9}}

local drill_remnants = table.deepcopy(data.raw.corpse["burner-mining-drill-remnants"])
drill_remnants.name = "surface-drill-remnants"
drill_remnants.animation[1].scale = 1

local subway_rail = table.deepcopy(data.raw["straight-rail"]["straight-rail"])
subway_rail.name = "subway-rail"
subway_rail.localised_name = {"entity-name.straight-rail"}
subway_rail.collision_mask = {layers = {floor = true, rail = true}}
subway_rail.hidden = true

data:extend(
{
  cave_sealing,
  drill_remnants,
  subway_rail,
  
  {
	type = "cliff",
	name = "subsurface-wall",
	flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
	icon = table.deepcopy(data.raw["simple-entity"]["huge-rock"].icon),
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
	minable = {
		mining_particle = "stone-particle",
		mining_time = 1,
		results = {{type = "item", name = "stone", amount_min = 10, amount_max = 30}},
		mining_trigger = {type = "direct", action_delivery = {type = "instant", target_effects = table.deepcopy(data.raw["simple-entity"]["big-rock"].dying_trigger_effect)}}
	}
  },
  {
	type = "simple-entity",
	name = "subsurface-wall-map-border",
	localised_name = {"entity-name.subsurface-wall"},
	icon = table.deepcopy(data.raw["simple-entity"]["huge-rock"].icon),
	flags = {"placeable-neutral", "not-on-map", "placeable-off-grid", "not-deconstructable"},
	hidden = true,
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
	hidden = true,
	hidden_in_factoriopedia = false,
	factoriopedia_description = {"", {"entity-description.tunnel-entrance-cable"}, "\n\n", {"additional-description.tunnel-entrance"}},
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
	pictures = {
	  filename = "__Subsurface__/graphics/entities/entrance.png",
	  priority = "extra-high",
	  width = 189,
	  height = 134,
	  direction_count = 1,
	  --shift = util.by_pixel(0, -51),
	  scale = 0.5
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
	hidden = true,
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
	hidden = true,
	factoriopedia_alternative = "tunnel-entrance-cable",
	collision_box = {{0, 0}, {0, 0}},
	selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
	pictures = {
	  filename = "__Subsurface__/graphics/entities/exit.png",
	  priority = "extra-high",
	  width = 125,
	  height = 268,
	  direction_count = 1,
	  shift = util.by_pixel(0, -32),
	  scale = 0.5
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
	hidden = true,
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
	icons = {
	  {
		icon = "__base__/graphics/icons/burner-mining-drill.png"
	  },
	  {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	  }
	},
	flags = {"placeable-player", "player-creation"},
	resource_categories = {"subsurface-hole"},
	minable = {hardness = 0.2, mining_time = 2, result = "surface-drill"},
	placeable_by = {item = "surface-drill", count = 1},
	collision_mask = util.merge{collision_mask_util.get_default_mask("mining-drill"), {layers = {surface_drill = true}}},
	max_health = 300,
	corpse = "burner-mining-drill-remnants",
	dying_explosion = "burner-mining-drill-explosion",
	collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
	selection_box = {{-2.2, -2.2}, {2.2, 2.2}},
	damaged_trigger_effect = data.raw["mining-drill"]["burner-mining-drill"].damaged_trigger_effect,
	mining_speed = 0.1,
	energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = {pollution = 5}},
	energy_usage = "2MW",
	module_slots = 3,
	quality_affects_module_slots = true,
	allowed_effects = {"speed", "consumption", "pollution"},
	surface_conditions = gravity_condition(),
	open_sound = data.raw["mining-drill"]["burner-mining-drill"].open_sound,
	close_sound = data.raw["mining-drill"]["burner-mining-drill"].close_sound,
	vehicle_impact_sound =  data.raw["mining-drill"]["burner-mining-drill"].vehicle_impact_sound,
	working_sound = data.raw["mining-drill"]["burner-mining-drill"].working_sound,
	resource_searching_radius = 0.49,
	drops_full_belt_stacks = feature_flags["space_travel"],
	vector_to_place_result = {-1, -2.6},
	graphics_set = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"].graphics_set),
	circuit_connector = ccd,
	circuit_wire_max_distance = default_circuit_wire_max_distance,
	uses_force_mining_productivity_bonus = false,
  },
  {
	-- this dummy is needed to allow placement everywhere, not only over resources
	type = "assembling-machine",
	name = "surface-drill-placer",
	localised_name = {"entity-name.surface-drill"},
	icons = {
	  {
		icon = "__base__/graphics/icons/burner-mining-drill.png"
	  },
	  {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	  }
	},
	flags = {"placeable-player", "player-creation"},
	hidden = true,
	factoriopedia_alternative = "surface-drill",
	factoriopedia_description = {"", {"entity-description.surface-drill"}, "\n\n", {"additional-description.surface-drill"}},
	collision_mask = util.merge{collision_mask_util.get_default_mask("mining-drill"), {layers = {surface_drill = true}}},
	max_health = 300,
	corpse = "surface-drill-remnants",
	collision_box = {{-2.1, -2.2}, {2.2, 2.2}},
	selection_box = {{-2.2, -2.2}, {2.2, 2.2}},
	graphics_set = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"].graphics_set),
	energy_source = {type = "electric", usage_priority = "secondary-input", emissions_per_minute = {pollution = 5}, drain = "0W"},
	energy_usage = "2MW",
	surface_conditions = gravity_condition(),
	crafting_speed = 0.1,
	crafting_categories = {"venting"},
	fixed_recipe = "surface-drilling-dummy",
	module_slots = 3,
	quality_affects_module_slots = true,
	allowed_effects = {"speed", "consumption", "pollution"},
  },
  {
	type = "resource",
	name = "subsurface-hole",
	icon = "__base__/graphics/icons/stone.png",
	category = "subsurface-hole",
	hidden = true,
	minable = {mining_time = 1, result = "stone", count = 20},
	stages = {blank_image},
	stage_counts = {0},
  },
  
  {
	type = "assembling-machine",
	name = "active-air-vent",
	icon = "__Subsurface__/graphics/icons/air_vent_22_icon.png",
	icon_size = 32,
	flags = {"placeable-player", "player-creation"},
	minable = {hardness = 0.2, mining_time = 0.5, result = "active-air-vent"},
	surface_conditions = gravity_condition(),
	max_health = 200,
	crafting_categories = {"venting"},
	fixed_recipe = "venting",
	ingredient_count = 0,
	collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
	selection_box = {{-1, -1}, {1, 1}},
	graphics_set = {animation = {
	  filename = "__Subsurface__/graphics/entities/air_vent22_sheet.png",
	  priority = "high",
	  width = 96,
	  height = 96,
	  frame_count = 16,
	  line_length = 4,
	  shift = {0.45, -0.1},
	  animation_speed = 0.5,
	}},
	match_animation_speed_to_activity = false,
	crafting_speed = 10,
	allowed_effects = {"speed", "consumption"},
	module_slots = 2,
	effect_receiver = {uses_beacon_effects = false, uses_surface_effects = false},
    impact_category = "metal",
    open_sound = data.raw["assembling-machine"]["assembling-machine-1"].open_sound,
    close_sound = data.raw["assembling-machine"]["assembling-machine-1"].close_sound,
	working_sound = data.raw["furnace"]["electric-furnace"].working_sound,
	energy_source =
	{
	  type = "electric",
	  usage_priority = "secondary-input",
	  emissions = 0,
	  drain = "0W",
	},
	energy_usage = "2kW",
  },
  {
	type = "simple-entity",
	name = "air-vent",
	flags = {"placeable-neutral", "not-on-map", "player-creation"},
	collision_mask = {layers = {item = true, object = true, player = true, water_tile = true}},
	icon = "__Subsurface__/graphics/icons/air_vent_11_icon.png",
	icon_size = 32,
	minable = {mining_time = 1, result = "air-vent"},
	surface_conditions = gravity_condition(),
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
	type = "constant-combinator",
	name = "prospector-combinator",
	localised_name = {"entity-name.prospector"},
	localised_description = {"entity-description.prospector"},
	icon = "__Subsurface__/graphics/icons/prospector.png",
	flags = {"player-creation", "not-blueprintable", "not-on-map", "placeable-off-grid", "not-rotatable"},
	minable = {mining_time = 0.1, result = "prospector"},
	surface_conditions = gravity_condition(),
	placeable_by = {item = "prospector", count = 1},
	factoriopedia_alternative = "prospector",
	hidden = true,
	max_health = 250,
	corpse = "radar-remnants",
	dying_explosion = "radar-explosion",
	resistances = {
	  {type = "fire", percent = 70},
	  {type = "impact", percent = 30}
	},
	selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	activity_led_light_offsets = {{0,0}, {0,0}, {0,0}, {0,0}},
	activity_led_sprites = {filename = "__core__/graphics/empty.png", size = 1},
	circuit_wire_max_distance = 9,
	circuit_wire_connection_points = {table.deepcopy(data.raw.radar["radar"].circuit_connector.points), table.deepcopy(data.raw.radar["radar"].circuit_connector.points), table.deepcopy(data.raw.radar["radar"].circuit_connector.points), table.deepcopy(data.raw.radar["radar"].circuit_connector.points)},
	open_sound = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"].open_sound),
	close_sound = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"].close_sound),
  },
  {
	type = "electric-energy-interface",
	name = "prospector",
	icon = "__Subsurface__/graphics/icons/prospector.png",
	flags = {"placeable-player", "player-creation", "not-rotatable"},
	selectable_in_game = false,
	collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
	selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	energy_source = {
	  type = "electric",
	  usage_priority = "secondary-input",
	  buffer_capacity = "3333.33J",
	},
	energy_usage = "200kW",
	working_sound = table.deepcopy(data.raw.radar.radar.working_sound),
	animation = {layers = {
	  {
		filename = "__Subsurface__/graphics/entities/prospector.png",
		priority = "high",
		width = 196,
		height = 254,
		frame_count = 64,
		line_length = 8,
		shift = util.by_pixel(1, -16),
		scale = 0.5,
		animation_speed = 0.0002
	  },
	  {
		filename = "__Subsurface__/graphics/entities/prospector-shadow.png",
		priority = "low",
		width = 343,
		height = 186,
		frame_count = 64,
		line_length = 8,
		shift = util.by_pixel(39.25, 3),
		draw_as_shadow = true,
		scale = 0.5
	  }
	}},
  },
  
  {
	type = "electric-pole",
	name = "wooden-support",
	localised_description = {"entity-description.support"},
	icon = "__Subsurface__/graphics/icons/wooden-support.png",
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.1, result = "wooden-support"},
	surface_conditions = feature_flags["space_travel"] and {{property = "subsurface-level", min = 1}} or nil,
	max_health = 100,
	fast_replaceable_group = "supports",
	next_upgrade = "steel-support",
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
		shadow = {copper = util.by_pixel(97, -0.5), red = util.by_pixel(98.5, -0.5), green = util.by_pixel(95.5, -0.5)},
		wire = {copper = util.by_pixel(9.5, -70), red = util.by_pixel(11, -70), green = util.by_pixel(8.0, -70)}
	  },
	  {
		shadow = {copper = util.by_pixel(76, 1), red = util.by_pixel(77.5, 2.5), green = util.by_pixel(74.5, -0.5)},
		wire = {copper = util.by_pixel(-9.5, -73), red = util.by_pixel(-7, -73), green = util.by_pixel(-11.0, -73)}
	  },
	  {
		shadow = {copper = util.by_pixel(83, 1), red = util.by_pixel(83, -0.5), green = util.by_pixel(83, 2.5)},
		wire = {copper = util.by_pixel(-1, -74), red = util.by_pixel(1.0, -74), green = util.by_pixel(-3.5, -74)}
	  },
	  {
		shadow = {copper = util.by_pixel(81.5, 3.5), red = util.by_pixel(80, 3.5), green = util.by_pixel(83, 3.5)},
		wire = {copper = util.by_pixel(-0.5, -66), red = util.by_pixel(-3, -66), green = util.by_pixel(2, -66)}
	  }
	},
	radius_visualisation_picture = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].radius_visualisation_picture),
  },
  {
	type = "electric-pole",
	name = "steel-support",
	icon = "__Subsurface__/graphics/icons/steel-support.png",
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.1, result = "steel-support"},
	surface_conditions = feature_flags["space_travel"] and {{property = "subsurface-level", min = 1}} or nil,
	fast_replaceable_group = "supports",
	max_health = 200,
	resistances = {
	  {type = "fire", percent = 100},
	},
	corpse = "small-electric-pole-remnants",
	dying_explosion = "small-electric-pole-explosion",
	collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
	selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
	damaged_trigger_effect = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].damaged_trigger_effect),
	drawing_box = {{-0.5, -2.6}, {0.5, 0.5}},
	maximum_wire_distance = 9.5,
	supply_area_distance = 4.5,
	vehicle_impact_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].vehicle_impact_sound),
	open_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].open_sound),
	close_sound = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].close_sound),
	track_coverage_during_build_by_moving = true,
	pictures = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].pictures),
	connection_points = {
	  {
		shadow = {copper = util.by_pixel(97, -0.5), red = util.by_pixel(98.5, -0.5), green = util.by_pixel(95.5, -0.5)},
		wire = {copper = util.by_pixel(9.5, -70), red = util.by_pixel(11, -70), green = util.by_pixel(8.0, -70)}
	  },
	  {
		shadow = {copper = util.by_pixel(76, 1), red = util.by_pixel(77.5, 2.5), green = util.by_pixel(74.5, -0.5)},
		wire = {copper = util.by_pixel(-9.5, -73), red = util.by_pixel(-7, -73), green = util.by_pixel(-11.0, -73)}
	  },
	  {
		shadow = {copper = util.by_pixel(83, 1), red = util.by_pixel(83, -0.5), green = util.by_pixel(83, 2.5)},
		wire = {copper = util.by_pixel(-1, -74), red = util.by_pixel(1.0, -74), green = util.by_pixel(-3.5, -74)}
	  },
	  {
		shadow = {copper = util.by_pixel(81.5, 3.5), red = util.by_pixel(80, 3.5), green = util.by_pixel(83, 3.5)},
		wire = {copper = util.by_pixel(-0.5, -66), red = util.by_pixel(-3, -66), green = util.by_pixel(2, -66)}
	  }
	},
	radius_visualisation_picture = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"].radius_visualisation_picture),
  },
  {
	type = "lamp",
	name = "support-lamp",
	icons = {
	  {
		icon = "__Subsurface__/graphics/icons/wooden-support.png"
	  },
	  {
		icon = data.raw.lamp["small-lamp"].icon,
		scale = 0.25,
		shift = {8, -8}
	  }
	},
	hidden = true,
	flags = {"placeable-off-grid"},
	picture_on = blank_image,
	picture_off = blank_image,
	selectable_in_game = false,
	selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
	energy_source = {type = "electric", usage_priority = "lamp"},
	energy_usage_per_tick = "2kW",
	light = {intensity = 0.7, size = 15, color = {r = 1.0, g = 1.0, b = 0.75}}
  },
  
  {
	type = "pump",
	name = "fluid-elevator-input",
	localised_description = {"entity-description.fluid-elevator"},
	hidden_in_factoriopedia = true,
	icons = {
	  {
		icon = data.raw["pipe-to-ground"]["pipe-to-ground"].icon
	  },
	  {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	  }
	},
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.2, result = "fluid-elevator"},
	max_health = 180,
	corpse = "small-remnants",
	dying_explosion = "medium-explosion",
	collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	working_sound = table.deepcopy(data.raw.pump.pump.working_sound),
	resistances = {
	  {type = "fire", percent = 80},
	  {type = "impact", percent = 30}
	},
	fluid_box = {
	  volume = 200,
	  pipe_covers = pipecoverspictures(),
	  pipe_connections = {
		{flow_direction = "input", connection_type = "normal", position = {0, 0}, direction = defines.direction.north},
		{flow_direction = "output", connection_type = "linked", linked_connection_id = 1},
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
	localised_description = {"entity-description.fluid-elevator"},
	hidden_in_factoriopedia = true,
	icons = {
	  {
		icon = data.raw["pipe-to-ground"]["pipe-to-ground"].icon
	  },
	  {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	  }
	},
	flags = {"placeable-neutral", "player-creation"},
	minable = {mining_time = 0.2, result = "fluid-elevator"},
	placeable_by = {item = "fluid-elevator", count = 1},
	max_health = 180,
	corpse = "small-remnants",
	dying_explosion = "medium-explosion",
	collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	working_sound = table.deepcopy(data.raw.pump.pump.working_sound),
	resistances = {
	  {type = "fire", percent = 80},
	  {type = "impact", percent = 30}
	},
	fluid_box = {
	  volume = 200,
	  pipe_covers = pipecoverspictures(),
	  pipe_connections = {
		{flow_direction = "output", connection_type = "normal", position = {0, 0}, direction = defines.direction.north},
		{flow_direction = "input", connection_type = "linked", linked_connection_id = 1},
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
		icon = data.raw["heat-pipe"]["heat-pipe"].icon
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
  },

  {
	type = "simple-entity-with-owner",
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
	minable = {mining_time = 5, result = "subway"},
	flags = {"placeable-neutral"},
	selection_box = {{-2, -6}, {2, 5}},
	collision_box = {{-1.9, -7}, {1.9, 4.9}},
	tile_width = 2,
	tile_height = 2,
	build_grid_size = 2,
	max_health = 1000,
	map_color = data.raw["utility-constants"]["default"].chart.rail_ramp_color,
	render_layer = "train-stop-top",
	picture = {
	  north = {
		filename = "__Subsurface__/graphics/entities/subway/N.png",
		width = 256,
		height = 512,
		shift = {1, -1},
	  },
	  east = {
		filename = "__Subsurface__/graphics/entities/subway/E.png",
		width = 512,
		height = 256,
		scale = 0.9,
		shift = {2, -0.5},
	  },
	  south = {
		filename = "__Subsurface__/graphics/entities/subway/S.png",
		width = 256,
		height = 512,
		shift = {1, 0.5},
	  },
	  west = {
		filename = "__Subsurface__/graphics/entities/subway/W.png",
		width = 512,
		height = 256,
		scale = 0.9,
		shift = {0, -0.5},
	  },
	},
  },
  {
	type = "train-stop",
	name = "subway-stop",
	icon = "__Subsurface__/graphics/icons/Tunnels-icon.png", icon_size = 32,
	animation_ticks_per_frame = 600,
	chart_name = false,
	collision_mask = {layers = {}},
	selectable_in_game = false,
	tile_width = 2,
	tile_height = 2,
	hidden = true,
	alert_icon_scale = 0,
  }
})

for _, o in ipairs({"north", "west", "south", "east"}) do
	data.raw["mining-drill"]["surface-drill"].graphics_set.animation[o].layers[1].scale = 1
	data.raw["mining-drill"]["surface-drill"].graphics_set.animation[o].layers[2].scale = 1
	data.raw["assembling-machine"]["surface-drill-placer"].graphics_set.animation[o].layers[1].scale = 1
	data.raw["assembling-machine"]["surface-drill-placer"].graphics_set.animation[o].layers[2].scale = 1
end

data.raw["electric-pole"]["wooden-support"].pictures.layers[1].filename = "__Subsurface__/graphics/entities/support/wooden-support.png"
data.raw["electric-pole"]["wooden-support"].pictures.layers[2].filename = "__Subsurface__/graphics/entities/support/wooden-support-shadow.png"
data.raw["electric-pole"]["steel-support"].pictures.layers[1].filename = "__Subsurface__/graphics/entities/support/steel-support.png"
data.raw["electric-pole"]["steel-support"].pictures.layers[2].filename = "__Subsurface__/graphics/entities/support/wooden-support-shadow.png"

data.raw["assembling-machine"]["active-air-vent"].working_sound.sound.volume = 0.3
