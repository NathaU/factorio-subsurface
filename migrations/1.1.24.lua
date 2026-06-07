for _, s in pairs(script.active_mods["Prospector"] and {} or storage.prospectors) do
	storage.selection_indicators[s.combinator.unit_number] = {rendering.draw_circle{
		color = {r = 0.1, g = 0.1, b = 0, a = 0.15},
		radius = 64 * s.combinator.quality.range_multiplier,
		filled = true,
		target = s.combinator,
		surface = s.combinator.surface,
		draw_on_ground = true,
		visible = false,
	}}
	s.remote_render = rendering.draw_circle{
		color = {r = 0.25, g = 0.25, b = 0, a = 0.1},
		radius = 64 * s.combinator.quality.range_multiplier,
		filled = true,
		target = s.combinator,
		surface = s.combinator.surface,
		render_mode = "chart",
		visible = false,
	}
end
