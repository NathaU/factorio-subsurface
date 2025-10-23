require "scripts.lib"

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

if settings.startup["pollution-trains"].value then
	local exclude_prototypes = {}
	for p in string.gmatch(settings.startup["pollution-trains-excludes"].value, "[^%s,]+") do
		if p == "" then exclude_prototypes[p] = true end
	end
	for _, e in pairs(data.raw["locomotive"]) do
		if not exclude_prototypes[e.name] and e.burner then
			e.burner.emissions_per_minute = e.burner.emissions_per_minute or {pollution = 10}
		end
	end
end

table.insert(data.raw.projectile["cliff-explosives"].action[1].action_delivery.target_effects, {type = "script", effect_id = "cliff-explosives"})

-- Resources that are not dependent from x and y (e.g. aluminium-rock from PY Raw Ores), are not placed in "ore fields", they have the same probability everywhere.
-- Since map seed of subsurfaces is the same as their oversurfaces, that would result in such resources being placed at the same spot when mirrored
for name, dt in pairs(data.raw["resource"]) do
	if dt.autoplace and dt.autoplace.probability_expression then
		if not crawl_expression(dt.autoplace.probability_expression) then
			log("Resource " .. name .. " autoplace is independent from x and y. Create noise expression to place it randomly.")
			data:extend({
			  {
				type = "noise-expression",
				name = name.."-probability",
				expression = "random_penalty(x, y, 1000000, subsurface_seed ~ "..simple_hash(name)..", 1000000) / 1000000",
			  }
			})
		end
	end
end


data.subsurface_entity_restrictions = data.subsurface_entity_restrictions or {}
require "scripts.placement-restrictions"

-- apply the restriction (surface condition for DLC owners, item description for non-owners)
for entity_name, type in pairs(data.subsurface_entity_restrictions) do
	if data.raw[type][entity_name] then
		if feature_flags["space_travel"] then
			data.raw[type][entity_name].surface_conditions = data.raw[type][entity_name].surface_conditions or {}
			table.insert(data.raw[type][entity_name].surface_conditions, {property = "subsurface-level", max = 0})
		else
			data.raw[type][entity_name].custom_tooltip_fields = data.raw[type][entity_name].custom_tooltip_fields or {}
			table.insert(data.raw[type][entity_name].custom_tooltip_fields, {name = "", value = {"item-description.placement-restriction"}, order = 0})
		end
	end
end

-----------------------
-- MOD COMPATIBILITY --
-----------------------

data.raw.resource["subsurface-hole"].infinite = false
data.raw["straight-rail"]["subway-rail"].next_upgrade = nil
data.raw["straight-rail"]["subway-rail"].fast_replaceable_group = nil
