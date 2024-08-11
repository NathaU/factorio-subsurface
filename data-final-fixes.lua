local collision_mask_util = require("collision-mask-util")
require "scripts.crc32"

if settings.startup["pollution-trains"].value then
	local exclude_prototypes = {}
	for p in string.gmatch(settings.startup["pollution-trains-excludes"].value, "[^%s,]+") do
		if p == "" then exclude_prototypes[p] = true end
	end
	for _,e in pairs(data.raw["locomotive"]) do
		if not exclude_prototypes[e.name] and e.burner then
			e.burner.emissions_per_minute = e.burner.emissions_per_minute or 10
		end
	end
end

table.insert(data.raw.projectile["cliff-explosives"].action[1].action_delivery.target_effects, {type = "script", effect_id = "cliff-explosives"})

local tne = noise.to_noise_expression
for name,dt in pairs(data.raw["resource"]) do
	if dt.autoplace and dt.autoplace.probability_expression then
		local serialized_expression = serpent.line(dt.autoplace.probability_expression)
		if string.find(serialized_expression, 'variable_name = "x"') == nil and string.find(serialized_expression, 'variable_name = "y"') == nil then
			log("Resource " .. name .. " autoplace is independent from x and y. Replace it with spot noise expression")
			data:extend({
			  {
				type = "noise-expression",
				name = name.."-probability",
				expression = tne(noise.var("random-value-0-1") + (tne{
				  type = "function-application",
				  function_name = "random-penalty",
				  arguments = {
					x = noise.var("x"),
					y = noise.var("y"),
					source = tne(9999),
					amplitude = tne(10000),
					seed = tne(bit32.band(hash(name), 0xFFFF))
				  }
				} / 10000) - noise.floor(noise.var("random-value-0-1") + (tne{
				  type = "function-application",
				  function_name = "random-penalty",
				  arguments = {
					x = noise.var("x"),
					y = noise.var("y"),
					source = tne(9999),
					amplitude = tne(10000),
					seed = tne(bit32.band(hash(name), 0xFFFF))
				  }
				} / 10000)))
			  }
			})
		end
	end
end

for _,d in pairs(data.raw["electric-pole"]) do
	if d.name ~= "wooden-support" and data.raw.item[d.name] then
		data.raw.item[d.name].localised_description =  {"item-description.placement-restriction"}
	end
end
