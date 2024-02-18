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

function get_position(pos)
	return {x = pos.x or pos[1], y = pos.y or pos[2]}
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

function get_area(pos, size)
	pos = get_position(pos)
	return {left_top={x=math.floor(pos.x - size), y=math.floor(pos.y - size)}, right_bottom={x=math.ceil(pos.x + size), y=math.ceil(pos.y + size)}}
end

function get_area_positions(area)
	local arr = {}
	for x=area.left_top.x,area.right_bottom.x,1 do
		for y=area.left_top.y,area.right_bottom.y,1 do
			table.insert(arr, {x, y})
		end
	end
	return arr
end

function get_safe_position(entity_position, player_position)
	local distance_modifier = 1.5
	return {x = entity_position.x + (player_position.x - entity_position.x) * distance_modifier, y= entity_position.y + (player_position.y - entity_position.y) * distance_modifier}
end

function move_towards_continuous(start, factorio_orientation, distance)
	local rad_factorio_orientation = factorio_orientation * 2 * math.pi
	local mod = {math.sin(rad_factorio_orientation), -math.cos(rad_factorio_orientation)} -- x, y
	return {x = start.x + mod[1] * distance, y = start.y + mod[2] * distance}
end
