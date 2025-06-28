local i = 1
for t, _ in pairs(data.raw["transport-belt"]) do

	local b = data.raw["transport-belt"][t].related_underground_belt
	if not b then break end
	
	if b == "se-space-underground-belt"
	or b == "se-deep-space-underground-belt"
	or b == "se-deep-space-underground-belt-black"
	or b == "se-deep-space-underground-belt-white"
	or b == "se-deep-space-underground-belt-red"
	or b == "se-deep-space-underground-belt-yellow"
	or b == "se-deep-space-underground-belt-green"
	or b == "se-deep-space-underground-belt-cyan"
	or b == "se-deep-space-underground-belt-blue"
	or b == "se-deep-space-underground-belt-magenta"
	then break end
	
	local item_elevator = table.deepcopy(data.raw["linked-belt"]["linked-belt"])
	item_elevator.name = "item-elevator-" .. i
	item_elevator.localised_name = {"entity-name.item-elevator", {"entity-name."..t}}
	item_elevator.localised_description  = {"entity-description.item-elevator"}
	
	if data.raw["underground-belt"][b].icons then
		item_elevator.icons = table.deepcopy(data.raw["underground-belt"][b].icons)
	else
		item_elevator.icons = {
		  {
			icon = data.raw["underground-belt"][b].icon,
			icon_size = data.raw["underground-belt"][b].icon_size
		  }
		}
	end
	table.insert(item_elevator.icons, {
		icon = "__Subsurface__/graphics/icons/elevator.png",
		icon_size = 32,
	})
	
	item_elevator.minable.result = "item-elevator-" .. i
	item_elevator.fast_replaceable_group = "item-elevators"
	item_elevator.next_upgrade = "item-elevator-" .. (i+1)
	item_elevator.belt_animation_set = data.raw["underground-belt"][b].belt_animation_set
	item_elevator.speed = data.raw["underground-belt"][b].speed
	
	data:extend({
	  item_elevator,
	  {
		type = "item",
		name = "item-elevator-" .. i,
		localised_name = {"entity-name.item-elevator", {"entity-name."..t}},
		localised_description  = {"item-description.item-elevator"},
		icons = table.deepcopy(item_elevator.icons),
		subgroup = "inter-surface-transport",
		order = "c-a" .. i,
		place_result = "item-elevator-" .. i,
		stack_size = 10
	  },
	  {
		type = "recipe",
		name = "item-elevator-" .. i,
		enabled = false,
		energy_required = 2,
		ingredients =
		{
		  {type = "item", name = b, amount = 2},
		  {type = "item", name = "iron-gear-wheel", amount = 10},
		  {type = "item", name = "electronic-circuit", amount = 10},
		},
		results = {{type = "item", name = "item-elevator-" .. i, amount = 2}}
	  },
	})
	table.insert(data.raw.technology["inter-surface-transport"].effects, {type = "unlock-recipe", recipe = "item-elevator-" .. i})
	
	i = i + 1
end
data.raw["linked-belt"]["item-elevator-"..(i-1)].next_upgrade = nil
