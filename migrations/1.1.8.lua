storage.exposed_chunks = storage.exposed_chunks or {}
for _, subsurface in pairs(storage.subsurfaces) do
	storage.exposed_chunks[subsurface.index] = storage.exposed_chunks[subsurface.index] or {}
	for chunk in subsurface.get_chunks() do
		if subsurface.is_chunk_generated({chunk.x, chunk.y}) and subsurface.count_tiles_filtered{area = chunk.area, name = "out-of-map"} < 1024 then
			storage.exposed_chunks[subsurface.index][spiral({chunk.x, chunk.y})] = {2, {chunk.x, chunk.y}}
			storage.exposed_chunks[subsurface.index][spiral({chunk.x, chunk.y - 1})] = storage.exposed_chunks[subsurface.index][spiral({chunk.x, chunk.y - 1})] or {1, {chunk.x, chunk.y - 1}}
			storage.exposed_chunks[subsurface.index][spiral({chunk.x, chunk.y + 1})] = storage.exposed_chunks[subsurface.index][spiral({chunk.x, chunk.y + 1})] or {1, {chunk.x, chunk.y + 1}}
			storage.exposed_chunks[subsurface.index][spiral({chunk.x - 1, chunk.y})] = storage.exposed_chunks[subsurface.index][spiral({chunk.x - 1, chunk.y})] or {1, {chunk.x - 1, chunk.y}}
			storage.exposed_chunks[subsurface.index][spiral({chunk.x + 1, chunk.y})] = storage.exposed_chunks[subsurface.index][spiral({chunk.x + 1, chunk.y})] or {1, {chunk.x + 1, chunk.y}}
		elseif subsurface.get_pollution({chunk.x * 32, chunk.y * 32}) > 0 then
			subsurface.set_pollution({chunk.x * 32, chunk.y * 32}, 0)
		end
	end
end
