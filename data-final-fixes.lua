local collision_mask_util = require("collision-mask-util")
require "scripts.lib"
require "scripts.crc32"

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
			log("Resource " .. name .. " autoplace is independent from x and y. Replace it with spot noise expression")
			data:extend({
			  {
				type = "noise-expression",
				name = name.."-probability",
				expression = "var('random-value-0-1') + (random_penalty(x, y, 9999, "..hash(name).."&0xffff, 10000) / 10000) - floor(var('random-value-0-1') + (random_penalty(x, y, 9999, "..hash(name).."&0xffff, 10000) / 10000))",
			  }
			})
		end
	end
end

data.subsurface_entity_restrictions = data.subsurface_entity_restrictions or {}
require "scripts.placement-restrictions"

-- first, collect the data from the previous file
for type, name_arr in pairs(type_restrictions) do
	for name, _ in pairs(data.raw[type]) do
		local ignore = false
		for _, ign in ipairs(name_arr) do
			if name == ign then ignore = true end
		end
		if not ignore then data.subsurface_entity_restrictions[name] = type end
	end
end

-- then apply the restriction (surface condition for DLC owners, item description for non-owners)
if feature_flags["space_travel"] then
	for name, type in pairs(data.subsurface_entity_restrictions) do
		if data.raw[type][name] then
			data.raw[type][name].surface_conditions = data.raw[type][name].surface_conditions or {}
			table.insert(data.raw[type][name].surface_conditions, {property = "subsurface-level", max = 0})
		end
	end
else
	local crawl_entities = function(item_data)
		for entity_name, _ in pairs(data.subsurface_entity_restrictions) do
			if item_data.place_result == entity_name then
				data.raw[item_data.type][item_data.name].localised_description = {"", {"item-description.placement-restriction"}, {"?", {"", "\n", item_data.localised_description or {"nil"}}, ""}}
			end
		end
	end
	-- set localised_description on items that place this entity
	for _, item_data in pairs(data.raw.item) do crawl_entities(item_data) end
	for _, item_data in pairs(data.raw["item-with-entity-data"]) do crawl_entities(item_data) end
end
