data:extend({
  {
	type = "bool-setting",
	setting_type = "startup",
	name = "pollution-trains",
	default_value = true
  },
  {
	type = "string-setting",
	setting_type = "startup",
	name = "pollution-trains-excludes",
	default_value = "electric-locomotive,deg-electric-locomotive",
	allow_blank = true,
	auto_traim = true
  },
  {
	type = "int-setting",
	setting_type = "runtime-global",
	name = "subsurface-limit",
	default_value = 20,
	minimum_value = 1
  },
})
