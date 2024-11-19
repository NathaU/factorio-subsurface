-- as fluid elevator type changed, they have new unit numbers which means the whole storage.fluid_elevators is useless
storage.fluid_elevators = {}
storage.item_elevators = nil
local linked_endpoints = {}

for _,s in pairs(game.surfaces) do
	for _,top in ipairs(s.find_entities_filtered{name="fluid-elevator-input"}) do
		-- since the outer for loop is sorted by surface index, we automatically have the top endpoint first
		if get_subsurface(s, false) then
			local bottom = get_subsurface(s, false).find_entity("fluid-elevator-output", top.position)
			if bottom and not linked_endpoints[top.unit_number] then
				table.insert(storage.fluid_elevators, {top, bottom})
				linked_endpoints[top.unit_number] = true
			end
		end
	end
	for _,top in ipairs(s.find_entities_filtered{name="fluid-elevator-output"}) do
		-- since the outer for loop is sorted by surface index, we automatically have the top endpoint first
		if get_subsurface(s, false) then
			local bottom = get_subsurface(s, false).find_entity("fluid-elevator-input", top.position)
			if bottom and not linked_endpoints[top.unit_number] then
				table.insert(storage.fluid_elevators, {bottom, top})
				linked_endpoints[top.unit_number] = true
			end
		end
	end
	for _,top in ipairs(s.find_entities_filtered{name="item-elevator-1"}) do
		-- since the outer for loop is sorted by surface index, we automatically have the top endpoint first
		if get_subsurface(s, false) then
			local bottom = get_subsurface(s, false).find_entity("item-elevator-1", top.position)
			if bottom and not linked_endpoints[top.unit_number] then
				bottom.linked_belt_type = "output"
				top.connect_linked_belts(bottom)
				linked_endpoints[top.unit_number] = true
			end
		end
	end
end

-- Support lamps
for _,s in pairs(game.surfaces) do
	for _,support in ipairs(s.find_entities_filtered{name="wooden-support"}) do
		rendering.get_object_by_id(storage.support_lamps[support.unit_number]).destroy()
		storage.support_lamps[support.unit_number] = s.create_entity{name="support-lamp", position=support.position}
	end
end