function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         --if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function get_surface_object(param)
	if type(param) == "string" or type(param) == "number" then return game.get_surface(param)
	else return param end
end

function iarea(area)
	local leftTop = area[1]
	if not leftTop then leftTop = {area.left_top.x, area.left_top.y} end
	local RightBottom = area[2]
	if not RightBottom then RightBottom = {area.right_bottom.x, area.right_bottom.y} end
	local _x = leftTop[1]
	local _y = leftTop[2]
	local reachedEnd = false
	return function()
		if reachedEnd then return nil end
		local x = _x
		local y = _y
		_x = _x + 1
		if _x > RightBottom[1] then
			_x = leftTop[1]
			_y = _y + 1
			if _y > RightBottom[2] then
				reachedEnd = true
			end
		end
		return x, y
	end
end

function get_area(pos, size) -- cannot use math2d.bounding_box.create_from_centre because of floor and ceil
	pos = math2d.position.ensure_xy(pos)
	return {left_top = {x = math.floor(pos.x - size), y = math.floor(pos.y - size)}, right_bottom = {x = math.ceil(pos.x + size), y = math.ceil(pos.y + size)}}
end

function get_area_positions(area)
	local arr = {}
	for y = area.left_top.y,area.right_bottom.y,1 do
		for x = area.left_top.x,area.right_bottom.x,1 do
			table.insert(arr, {x, y})
		end
	end
	return arr
end

function get_safe_position(entity_position, player_position)
	local distance_modifier = 1.5
	return {x = entity_position.x + (player_position.x - entity_position.x) * distance_modifier, y= entity_position.y + (player_position.y - entity_position.y) * distance_modifier}
end

function get_chunk_positions(poss)
	pos = math2d.position.ensure_xy(poss)
	return get_area_positions({left_top = {x = math.floor(pos.x/32)*32, y = math.floor(pos.y/32)*32}, right_bottom = {x = (math.floor(pos.x/32)*32)+31, y = (math.floor(pos.y/32)*32)+31}})
end

function get_position_index_in_chunk(pos)
	local p = {bit32.band(pos.x or pos[1], 0x1F), bit32.band(pos.y or pos[2], 0x1F)}
	return p[2]*32 + p[1] + 1
end

function spiral(pos)
	--https://web.archive.org/web/20141202041502/https://danpearcymaths.wordpress.com/2012/09/30/infinity-programming-in-geogebra-and-failing-miserably/
	local p = {table.unpack(pos)}
	local a = math.max(math.abs(p[1]), math.abs(p[2]))
	local dist = 0
	
	local i = 0
	while p[2] > p[1] or p[2] >= -p[1] do -- rotate by 90° (multiply by -i) until values are in the top triangle
		p = {-p[2], p[1]}
		dist = dist + 2*a
		i = i + 1
		if i == 5 then break end
	end
	dist = dist + a - p[1]
	return dist + ((a*2)-1)^2
end

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
				a1 = b1 - 1 -- continue after =, but -1 because we also have the next character
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

function simple_hash(text)
	local hash = 0
	for i = 1, string.len(text), 4 do
		local number = bit32.lshift(string.byte(text, i + 3) or 0, 24) + bit32.lshift(string.byte(text, i + 2) or 0, 16) + bit32.lshift(string.byte(text, i + 1) or 0, 8) + (string.byte(text, i) or 0)
		hash = bit32.bxor(hash, number)
	end
	return bit32.lrotate(hash, string.byte(text, string.len(text)))
end
