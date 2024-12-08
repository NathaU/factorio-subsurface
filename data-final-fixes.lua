local collision_mask_util = require("collision-mask-util")
require "scripts.crc32"

if settings.startup["pollution-trains"].value then
	local exclude_prototypes = {}
	for p in string.gmatch(settings.startup["pollution-trains-excludes"].value, "[^%s,]+") do
		if p == "" then exclude_prototypes[p] = true end
	end
	for _,e in pairs(data.raw["locomotive"]) do
		if not exclude_prototypes[e.name] and e.burner then
			e.burner.emissions_per_minute = e.burner.emissions_per_minute or {pollution = 10}
		end
	end
end

table.insert(data.raw.projectile["cliff-explosives"].action[1].action_delivery.target_effects, {type = "script", effect_id = "cliff-explosives"})

function is_parameter(function_prototypes, name)
	for i, proto in ipairs(function_prototypes) do
		for _, p in ipairs(proto.parameters or {}) do
			if p == name then return i end
		end
	end
	return false
end
function local_expression(function_prototypes, name)
	for i, proto in ipairs(function_prototypes) do
		if (proto.local_expressions or {})[name] then return proto.local_expressions[name] end
	end
	return nil
end
function local_function(function_prototypes, name)
	for i, proto in ipairs(function_prototypes) do
		if (proto.local_functions or {})[name] then return proto.local_functions[name] end
	end
	return nil
end
function ind(n)
	local str = ""
	for i=1, n, 1 do
		str = str .. " "
	end
	return str
end
-- Resources that are not dependent from x and y (e.g. aluminium-rock from PY Raw Ores), are not placed in "ore fields", they have the same probability everywhere.
-- Since map seed of subsurfaces is the same as their oversurfaces, that would result in such resources being placed at the same spot
-- This function returns true if either x or y is found, which are not named arguments or parameters
-- TODO: maybe ignore random_penalty?
function crawl_expression(expr, parent_function_protos, indent)
	if type(expr) == "string" then
		if not parent_function_protos then parent_function_protos = {} end
		if not indent then indent = 0 end
		--log(ind(indent).."crawling expression: " .. expr)
		
		local identifier_pattern = "([a-zA-Z_][a-zA-Z0-9_:]*)"
		local offset = 1
		local _, a1, identifier = string.find(expr, identifier_pattern) -- a1 is the index of the last character
		while identifier do
			local do_next_search = true -- since there is no continue statement in Lua, this is a workaround when it comes to var() function
			local msg = ind(indent)..'identifier "' .. identifier .. '": '
			-- if an identifier is found, first check if it is not a function argument name (followed by =)
			local b0, b1 = string.find(expr, "[ \n\r\t]*=[ \n\r\t]*[^=]", a1 + 1)
			-- then check if it is a function call (followed by ( or {)
			local c0, c1 = string.find(expr, "[ \n\r\t]*[%(%{]", a1 + 1)
			if (b0 or 0) == a1 + 1 then
				a1 = b1 - 1 -- continue after =, but remind that we also have the next character
				--log(msg .. "argument name")
			elseif (c0 or 0) == a1 + 1 then
				-- if this is a local or custom function, check it's expression, but be aware that it can have x or y named parameters
				-- if x or y are used as function arguments,they will be found later in this string
				if identifier == "var" then
					_, a1, identifier = string.find(expr, "[%\"%\']([^%\"%\']+)[%\"%\']%)", c1 + 1)
					do_next_search = false
				elseif local_function(parent_function_protos, identifier) then
					--log(msg .. "local function")
					local f = local_function(parent_function_protos, identifier)
					local nt = table.deepcopy(parent_function_protos)
					table.insert(nt, 1, f)
					if crawl_expression(f.expression, nt, indent+1) then return true end
				elseif data.raw["noise-function"][identifier] then
					--log(msg .. "global function")
					local nt = table.deepcopy(parent_function_protos)
					table.insert(nt, 1, data.raw["noise-function"][identifier])
					if crawl_expression(data.raw["noise-function"][identifier].expression, nt, indent+1) then return true end
				end
				if do_next_search then a1 = c1 end
			elseif is_parameter(parent_function_protos, identifier) then
				--log(msg .. "parameter name ("..is_parameter(parent_function_protos, identifier)..". parent)")
			elseif local_expression(parent_function_protos, identifier) then
				--log(msg .. "local expression")
				if crawl_expression(local_expression(parent_function_protos, identifier), parent_function_protos, indent+1) then return true end
			elseif data.raw["noise-expression"][identifier] then
				--log(msg .. "global expression")
				if identifier ~= "tier_from_start" then
					if crawl_expression(data.raw["noise-expression"][identifier].expression, parent_function_protos, indent+1) then return true end
				end
			else
				-- the identifier is not an argument name, not a function call, not a named noise expression
				-- so it has to be a built-in variable or constant
				--log(msg .. "variable/constant")
				if identifier == "x" or identifier == "y" then
					--log(ind(indent).."FOUND " .. identifier)
					return true
				end
			end
			offset = a1 + 1
			if do_next_search then
				_, a1, identifier = string.find(expr, identifier_pattern, offset)
			end
		end
	end
	return false
end
for name,dt in pairs(data.raw["resource"]) do
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
			table.insert(data.raw[type][name].surface_conditions, {property = "subsurface-level", min = 1})
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
