function handle_enemies(tick)
	
	-- randomly burrow enemies to exposed chunks beneath (worms and biters)
	if tick >= storage.next_burrowing then
		local tries = 5
		repeat
			local rnd_surface = math.random(math.max(table_size(storage.subsurfaces), 1))
			local i = 1
			for si,ss in pairs(storage.subsurfaces) do
				if i == rnd_surface and #storage.enemies_above_exposed_underground[si] > 0 then
					local rnd_base = math.random(#storage.enemies_above_exposed_underground[si])
					local base = storage.enemies_above_exposed_underground[si][rnd_base]
					if base.valid then
						if base.type == "turret" then
							if ss.can_place_entity{name = base.name, position = base.position} then
								local new_enemy = base.clone{position = base.position, surface = ss, force = base.force}
								table.remove(storage.enemies_above_exposed_underground[si], rnd_base)
								base.destroy()
								new_enemy.spawn_decorations()
								tries = 0
							end
						elseif #base.units > 0 then
							local enemy = base.units[1]
							local pos = ss.find_non_colliding_position(enemy.name, enemy.position, 20, 0.1)
							if pos then
								local new_enemy = enemy.clone{position = pos, surface = ss, force = enemy.force}
								if new_enemy then
									enemy.destroy()
									ss.build_enemy_base(new_enemy.position, 1)
									tries = 0
								end
							end
						end
					else
						table.remove(storage.enemies_above_exposed_underground[si], rnd_base)
					end
					break
				end
				i = i + 1
			end
			tries = tries - 1
		until(tries <= 0)
		
		storage.next_burrowing = tick + (math.random(game.map_settings.enemy_expansion.min_expansion_cooldown,  game.map_settings.enemy_expansion.max_expansion_cooldown) / table_size(storage.subsurfaces)) -- try again in 4-60 min per surface
	end
end

-- if underground is exposed beneath the built base, add it to the list
script.on_event(defines.events.on_biter_base_built, function(event)
	local subsurface = get_subsurface(event.entity.surface, false)
	if subsurface then
		local tile = subsurface.get_tile(event.entity.position)
		if tile.valid and tile.name ~= "out-of-map" then
			table.insert(storage.enemies_above_exposed_underground[event.entity.surface.index], event.entity)
		end
	end
end)

function init_enemies_global()
	storage.enemies_above_exposed_underground = {}
	for i,ss in pairs(storage.subsurfaces) do
		storage.enemies_above_exposed_underground[i] = {}
		local s = game.get_surface(i)
		for _,e in ipairs(s.find_entities_filtered{type = {"unit-spawner", "turret"}, force = game.forces.enemy}) do
			local tile = ss.get_tile(e.position)
			if tile.valid and tile.name ~= "out-of-map" then
				table.insert(storage.enemies_above_exposed_underground[i], e)
			end
		end
	end
end
function find_enemies_above(subsurface, position, radius)
	local s = get_oversurface(subsurface)
	for _,e in ipairs(s.find_entities_filtered{type = {"unit-spawner", "turret"}, position = position, radius=radius, force = game.forces.enemy}) do
		table.insert(storage.enemies_above_exposed_underground[s.index], e)
	end
end
