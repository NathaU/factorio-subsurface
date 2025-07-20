storage.exposed_chunks = storage.exposed_chunks or {}
for _, subsurface in pairs(storage.subsurfaces) do
	storage.exposed_chunks[subsurface.index] = storage.exposed_chunks[subsurface.index] or {}
	for chunk in subsurface.get_chunks() do
		if subsurface.is_chunk_generated({chunk.x, chunk.y}) and subsurface.count_tiles_filtered{area = chunk.area, name = "out-of-map"} < 1024 then
			storage.exposed_chunks[subsurface.index][spiral({chunk.x, chunk.y})] = {chunk.x, chunk.y}
		end
	end
end
