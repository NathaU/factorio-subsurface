for _, e in pairs(storage.pole_links) do
	local opposite = storage.pole_links[e.unit_number]
	e.get_wire_connector(defines.wire_connector_id.pole_copper, true).connect_to(opposite.get_wire_connector(defines.wire_connector_id.pole_copper, true), false, defines.wire_origin.script)
	e.get_wire_connector(defines.wire_connector_id.circuit_red, true).connect_to(opposite.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script)
	e.get_wire_connector(defines.wire_connector_id.circuit_green, true).connect_to(opposite.get_wire_connector(defines.wire_connector_id.circuit_green, true), false, defines.wire_origin.script)
end
