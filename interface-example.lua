-- Remote interface. replace "mymod" with your mod name
remote.add_interface("mymod", {

	-- This function defines which resource should be used when drilling to subsurfaces. It can be used for different mining results.
	-- The resource must be of category "subsurface-hole".
	-- Since multiple mods can have this function, the resource with the highest priority will be used. Default priority is 0.
	-- surface and depth parameters refer to the surface where the drill is placed.
	subsurface_hole_resource = function(surface, depth, position)
		local priority = 1
		local resource = "subsurface-hole"
		local amount = 2000
		return priority, resource, amount
	end,

	-- This function defines custom subsurface walls with custom mining results.
	-- The walls must be of type "cliff" - best practice is to copy from Subsurface and change what needed (pictures, drops)
	-- The noise expression returns a priority value (default is 0), the wall with the highest priority will be used.
	-- The expression can make use of the variable "subsurface_level".
	subsurface_register_walls = function()
		return {
			["mymod-subsurface-wall"] = "mymod-wall-noise-expression"
		}
	end
})
