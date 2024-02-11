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
})