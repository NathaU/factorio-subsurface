data:extend(
{
  {
	type = "tile",
	name = "caveground",
	needs_correction = false,
	mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
	collision_mask = {layers={ground_tile=true}},
	walking_speed_modifier = 1.4,
	autoplace = {probability_expression = "-10000"},
	layer = 61,
	absorptions_per_second = {pollution = 0},
	variants =
	{
	  material_background =
	  {
		picture = "__Subsurface__/graphics/terrain/underground-dirt.png",
		count = 4,
		scale = 8
	  },
	  transition =
      {
        overlay_layout =
        {
		  inner_corner =
		  {
			spritesheet = "__Subsurface__/graphics/terrain/underground-dirt-inner-corner.png",
			count = 1
		  },
		  outer_corner =
		  {
			spritesheet = "__Subsurface__/graphics/terrain/underground-dirt-outer-corner.png",
			count = 1
		  },
		  side =
		  {
			spritesheet = "__Subsurface__/graphics/terrain/underground-dirt-side.png",
			count = 4
		  },
		  u_transition =
		  {
			spritesheet = "__Subsurface__/graphics/terrain/underground-dirt-u.png",
			count = 1
		  },
		  o_transition =
		  {
			spritesheet = "__Subsurface__/graphics/terrain/underground-dirt-o.png",
			count = 1
		  }
		}
	  }
	},
	walking_sound =
	{
	  {
		filename = "__base__/sound/walking/dirt-02.ogg",
		volume = 0.8
	  },
	  {
		filename = "__base__/sound/walking/dirt-03.ogg",
		volume = 0.8
	  },
	  {
		filename = "__base__/sound/walking/dirt-04.ogg",
		volume = 0.8
	  }
	},
	map_color={r=0.5, g=0.332, b=0.144}
  }
})
