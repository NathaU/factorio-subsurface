-- pretend presence of subways for currently passing trains (we do not know which subway they are passing)
for u, _ in pairs(storage.train_transport or {}) do
	storage.train_transport[u].stop1 = {valid = true}
	storage.train_transport[u].stop2 = {valid = true}
end
