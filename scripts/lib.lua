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
	return {left_top={x=math.floor(pos.x - size), y=math.floor(pos.y - size)}, right_bottom={x=math.ceil(pos.x + size), y=math.ceil(pos.y + size)}}
end

function get_area_positions(area)
	local arr = {}
	for y=area.left_top.y,area.right_bottom.y,1 do
		for x=area.left_top.x,area.right_bottom.x,1 do
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

function get_chunk_positions(poss)
	pos = math2d.position.ensure_xy(poss)
	return get_area_positions({left_top={x=math.floor(pos.x/32)*32, y=math.floor(pos.y/32)*32}, right_bottom={x=(math.floor(pos.x/32)*32)+31, y=(math.floor(pos.y/32)*32)+31}})
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
