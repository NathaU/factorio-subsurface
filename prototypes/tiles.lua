data:extend(
{
  {
    type = "tile",
    name = "caveground",
    needs_correction = false,
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = {"ground-tile"},
    walking_speed_modifier = 1.4,
    layer = 61,
	pollution_absorption_per_second = 0,
    variants =
    {
      main =
      {
        {
          picture = "__Subsurface__/graphics/terrain/underground-dirt.png",
          count = 4,
          size = 1
        }
      },
      inner_corner =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt-inner-corner.png",
        count = 1
      },
      outer_corner =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt-outer-corner.png",
        count = 1
      },
      side =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt-side.png",
        count = 4
      },
      u_transition =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt-u.png",
        count = 1
      },
      o_transition =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt-o.png",
        count = 1
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