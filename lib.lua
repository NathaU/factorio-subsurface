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

function get_area(position, size)
	return {{math.floor(position.x - size), math.floor(position.y - size)}, {math.ceil(position.x + size), math.ceil(position.y + size)}}
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
