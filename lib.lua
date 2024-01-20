--[[
	Iterator for looping over an area.
	returns the x, y co-ordiantes for each position in an area.
	example:
		area = {{0, 0}, {10, 20}}
		for x, y in iarea(area) do
		end
]]
--iarea this was taken from the NESTT mod lib.lua and modified
function iarea( area )
	local leftTop = area.left_top 
	local RightBottom = area.right_bottom
	local _x = leftTop.x
	local _y = leftTop.y
	local reachedEnd = false
	return function()
		if reachedEnd then return nil end
		local x = _x
		local y = _y
		_x = _x + 1
		if _x > RightBottom.x then
			_x = leftTop.x
			_y = _y + 1
			if _y > RightBottom.y then
				reachedEnd = true
			end
		end
		return x, y
	end
end

function iarea_border(area)
	local left_top = {x = area.left_top.x, y = area.left_top.y }
	local right_bottom = {x = area.right_bottom.x, y = area.right_bottom.y}
	local _x = left_top.x
	local _y = left_top.y
	local reachedEnd = false
	return function()
		if reachedEnd then return nil end
		local x = _x
		local y = _y

		if y == left_top.y or y == right_bottom.y then
			_x = _x + 1
		else
			_x = right_bottom.x
		end
		if x == right_bottom.x then
			_x = left_top.x
			_y = _y + 1
			if _y > right_bottom.y then
				reachedEnd = true
			end
		end
		return x, y
	end
end
function iouter_area_border(area)
	return iarea_border({left_top = {x=area.left_top.x-1, y=area.left_top.y-1}, right_bottom = {x=area.right_bottom.x+1, y=area.right_bottom.y+1}})
end

function get_area(position, size)
	return {left_top = {x = math.floor(position.x - size) +0.5, y = math.floor(position.y - size)+0.5}, right_bottom = {x = math.floor(position.x + size) +0.5, y = math.floor(position.y + size)+0.5}}
end	

function expand_area(_area, _expanding_radius)
	local left_top = {x = _area.left_top.x - _expanding_radius, y = _area.left_top.y - _expanding_radius}
	local right_bottom = {x = _area.right_bottom.x + _expanding_radius, y = _area.right_bottom.y + _expanding_radius}
	return {left_top = left_top, right_bottom = right_bottom}
end


function KeyExists(tbl, key)
  for k,v in pairs(tbl) do
    if key == k then
      return true
    end
  end

  return false
end


function get_safe_position(entity_position, player_position)
	local distance_modifier = 1.5
	return {x = entity_position.x + (player_position.x - entity_position.x) * distance_modifier, y= entity_position.y + (player_position.y - entity_position.y) * distance_modifier}
end

function to_chunk_position(position)
	return {x = math.floor(position.x/32),y = math.floor(position.y/32)}
end

function associative_table_count(table)
	local i = 0
	for _,_ in pairs(table) do
		i=i+1
	end
	return i
end

function move_towards_continuous(start, factorio_orientation, distance)
	local mod = {}
	local rad_factorio_orientation = factorio_orientation * 2 * math.pi
	mod.x = math.sin(rad_factorio_orientation)
	mod.y = -math.cos(rad_factorio_orientation)
	local newPosition = {x = start.x+mod.x*distance, y = start.y+mod.y*distance}
	return newPosition
end

function turn_left_continuous(orientation)
	return math.fmod(orientation + 0.25, 1)
end

function turn_right_continuous(orientation)
	return math.fmod(orientation - 0.25, 1)
end



function notNil(class, var)
	value = false
	pcall(function()
		if class[var]
		then
			value = true
		end
	end)
	return value
end

function toGameString(arg, aT, fT)
	if aT~=nil then asTable = aT else asTable = false end
	if fT~=nil then firstTable = fT else firstTable = true end
	argType = type(arg)
	if argType == "nil"
	then
		text = "error"
	elseif argType == "string" or argType == "boolean" or argType == "number"
	then
		text = tostring(arg) .. " "
	elseif argType == "function"
	then
		text = debug.getinfo(arg).name .. " "
	elseif notNil(arg, "x") and notNil(arg, "y") and not asTable
	then
		text = "Position: " .. arg.x .. ", " .. arg.y .. " "
	elseif notNil(arg, "destructible") and not asTable
	then
		text = "Entity: " .. arg.name .. " " .. "Type: " .. arg.type .. " " .. toGameString(arg.position)
	elseif notNil(arg, "collideswith") and not asTable
	then
		text = "Tile: " .. arg.name .. " "
	elseif notNil(arg, "valid") and not asTable
	then
		text = "Unknown "
		if arg.valid then text = text .. "Valid Object: " else text = text .. "Invalid Object: " end
		if notNil(arg, "name") then text = text .. arg.name .. " " end
		if notNil(arg, "type") then text = text .. "Type: " .. arg.type .. " " end
		if notNil(arg, "position") then text = text .. toGameString(arg.position) .. " " end
	elseif (notNil(arg, "name") or notNil(arg, "type") or notNil(arg, "position")) and not asTable
	then
		text = "Unknown: "
		if notNil(arg, "name") then text = text .. "Name: " .. arg.name .. " " end
		if notNil(arg, "type") then text = text .. "Type: " .. arg.type .. " " end
		if notNil(arg, "position") then text = text .. toGameString(arg.position) end
	elseif argType == "table"
	then
		text = ""
		if firstTable then text = "Table: " end
		text = text .. "{"
		iters = math.min(#arg, 3)
		for i=1, iters
		do
			text = text .. toGameString(arg[i])
			if i<iters then text = text .. ", " end
		end
		if #arg>4 then text = text .. ", ... " end
		if #arg>3 then text = text .. toGameString(arg[#arg], false, false) end
		text = text .. "}"
	end
	return text
end

function message(arg, dialog, asTable)
	if dialog
	then
		game.showmessagedialog{text = {toGameString(arg, asTable)}}
	else
		game.player.print(toGameString(arg, asTable))
	end
end