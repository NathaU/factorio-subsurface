data:extend({
  {
	type = "tips-and-tricks-item-category",
	name = "subsurface",
	order = "-a"
  },
  {
	type ="tips-and-tricks-item",
	name = "subsurface",
	localised_name = "Subsurface",
	category ="subsurface",
	order = "a",
	tag = "[entity=huge-rock]",
	is_title = true,
	trigger = {type = "research", technology = "surface-drilling"},
	simulation = {
		mods = {"Subsurface"},
		save = "__Subsurface__/simulations/tips-and-tricks-default.zip",
		init_update_count = 60,
		init = [[
			local surface = game.get_surface(2)
			game.simulation.camera_surface_index = 2
			surface.daytime = 0.5
			remote.call("subsurface", "expose", surface, {0, 0.5}, 4)

			local tunnel = surface.find_entity("tunnel-exit-cable", {3.5, 0.5})
			local pole = surface.create_entity{name = "wooden-support", position = {-1, 0}, raise_built = true}
			pole.get_wire_connector(defines.wire_connector_id.pole_copper, true).connect_to(tunnel.get_wire_connector(defines.wire_connector_id.pole_copper, true))
			pole.get_wire_connector(defines.wire_connector_id.circuit_red, true).connect_to(tunnel.get_wire_connector(defines.wire_connector_id.circuit_red, true))
			pole.get_wire_connector(defines.wire_connector_id.circuit_green, true).connect_to(tunnel.get_wire_connector(defines.wire_connector_id.circuit_green, true))
		]]
	}
  },
  {
	type ="tips-and-tricks-item",
	name = "clear-subsurface-deconstruction",
	category ="subsurface",
	order = "b",
	tag = "[item=deconstruction-planner]",
	indent = 1,
	dependencies = {"subsurface"},
	trigger = {type = "research", technology = "construction-robotics"},
	simulation = {
		mods = {"Subsurface"},
		save = "__Subsurface__/simulations/tips-and-tricks-default.zip",
		init = [[
			require("__core__/lualib/story")
			
			local surface = game.get_surface(2)
			remote.call("subsurface", "expose", surface, {0, 0}, 5)
			remote.call("subsurface", "expose", surface, {-5, 0}, 5)

			surface.create_entities_from_blueprint_string{
				string = "0eNqVkcsOgjAQRf9l1sUIiLH8ijEGcNQmMINt8RHSf3eKRheycdW0ufecyXSEuh2wt4Y8lCOYhslBuR3BmRNVbXyjqkMowXLNPVsPQYGhA96hTMNOAZI33uCrNV0eexq6Gq0E1E9bQc9OCkyRLZBEQo94CNfiZUDn90fTerQuJhw2MfzCf70hqB9b9rHdmA9IiRv6eWe6KCbpclHMgfIPyHm21QmT5ixjzc3+BmUC+m982Zzx2Inj+wEKrlKb8MU60yuti02aa71chfAEA5SO9g==",
				position = {-0.5, 0},
			}
			local port = surface.find_entity("roboport", {-1, -1})
			port.insert({name = "construction-robot", count = 10})

			local player = game.simulation.create_test_player{name = ""}
			player.teleport({-8, 0}, game.get_surface(2))
			game.simulation.camera_surface_index = 2
			game.simulation.camera_player = player
			game.simulation.camera_position = {-12, 0}
			game.simulation.camera_player_cursor_position = player.position

			tip_story_init{{
			  {
				condition = function() return game.simulation.move_cursor{position = {-18, -3}, speed = 0.2} end,
				action = function() game.simulation.control_press{control = "give-deconstruction-planner", notify = false} end
			  },
			  {
				init = function() game.simulation.control_down{control = "select-for-cancel-deconstruct", notify = true} end,
				condition = function() return game.simulation.move_cursor{position = {-9, 2}, speed = 0.1} end,
				action = function() game.simulation.control_up{control = "select-for-cancel-deconstruct"} end
			  },
			}}
		]]
	},
  },
  {
	type ="tips-and-tricks-item",
	name = "inter-surface-transport",
	category ="subsurface",
	order = "c",
	tag = "[technology=inter-surface-transport]",
	indent = 1,
	dependencies = {"subsurface"},
	trigger = {type = "research", technology = "inter-surface-transport"},
	simulation = {
		mods = {"Subsurface"},
		save = "__Subsurface__/simulations/tips-and-tricks-default.zip",
		init = [[
			require("__core__/lualib/story")
			
			local surface = game.get_surface(2)
			local build_pos = {-4.5, -0.5}
			remote.call("subsurface", "expose", surface, {0, 0}, 5)
			remote.call("subsurface", "expose", surface, build_pos, 4)

			local player = game.simulation.create_test_player{name = ""}
			game.simulation.camera_player = player

			local entities_cycle = {
				{"item-elevator-1", "item-elevator-1", "item-elevator-1"},
				{"fluid-elevator", "fluid-elevator-output", "fluid-elevator-input"},
				{"heat-elevator", "heat-elevator", "heat-elevator"},
			}
			local i = 1
			
			tip_story_init{{
			  {
				name = "start",
			 	init = function()
					player.cursor_stack.set_stack{name = entities_cycle[i][1], count = 2}
					game.simulation.camera_player_cursor_position = player.position
				end,
			 	condition = function() return game.simulation.move_cursor{position = build_pos, speed = 0.2} end,
				action = function() player.build_from_cursor{position = game.simulation.camera_player_cursor_position} end
			  },
			  {
				condition = story_elapsed_check(1),
				action = function()
					player.teleport(player.position, surface)
					game.simulation.camera_surface_index = 2
					game.simulation.camera_player_cursor_position = player.position
					player.cursor_stack.set_stack{name = entities_cycle[i][1], count = 1}
				end
			  },
			  {
				condition = function() return game.simulation.move_cursor{position = build_pos, speed = 0.2} end,
				action = function()
					player.build_from_cursor{position = game.simulation.camera_player_cursor_position}
					player.clear_cursor()
					player.update_selected_entity(game.simulation.camera_player_cursor_position)
				end
			  },
			  {
				condition = story_elapsed_check(1),
				action = function()
					if i == 3 then story_jump_to(storage.story, "reset")
					else game.simulation.control_press{control = "rotate", notify = true}
					end
				end
			  },
			  {
				condition = story_elapsed_check(1),
				action = function() 
					player.update_selected_entity(game.simulation.camera_player_cursor_position)
					game.simulation.control_press{control = "rotate", notify = true} end
			  },
			  {
				condition = story_elapsed_check(2),
				action = function() game.simulation.control_press{control = "reverse-rotate", notify = true} end
			  },
			  {
				condition = story_elapsed_check(1),
				action = function() game.simulation.control_press{control = "reverse-rotate", notify = true} end
			  },
			  {
				name = "reset",
			 	condition = story_elapsed_check(3),
				action = function()
					surface.find_entity(entities_cycle[i][2], build_pos).destroy()
					game.get_surface(1).find_entity(entities_cycle[i][3], build_pos).destroy()
					i = (i % 3) + 1
					player.teleport(player.position, game.get_surface(1))
					story_jump_to(storage.story, "start")
				end
			  },
			}}
		]]
	},
  }
})
