local ClientState = {}
ClientState.__index = ClientState

local changedEvent = Instance.new("BindableEvent")

local snapshot = {
	Gold = 0,
	Inventory = {},
	Level = 1,
	Exp = 0,
	Pet = {},
}

function ClientState:ApplySnapshot(newSnapshot)
	if typeof(newSnapshot) ~= "table" then
		return
	end

	snapshot = {
		Gold = newSnapshot.Gold or 0,
		Inventory = newSnapshot.Inventory or {},
		Level = newSnapshot.Level or 1,
		Exp = newSnapshot.Exp or 0,
		Pet = newSnapshot.Pet or {},
	}

	changedEvent:Fire(snapshot)
end

function ClientState:Subscribe(callback)
	if typeof(callback) ~= "function" then
		return nil
	end
	return changedEvent.Event:Connect(callback)
end

function ClientState:GetSnapshot()
	return {
		Gold = snapshot.Gold,
		Inventory = snapshot.Inventory,
		Level = snapshot.Level,
		Exp = snapshot.Exp,
		Pet = snapshot.Pet,
	}
end

function ClientState:GetGold()
	return snapshot.Gold
end

function ClientState:GetInventory()
	return snapshot.Inventory
end

function ClientState:GetLevel()
	return snapshot.Level
end

function ClientState:GetExp()
	return snapshot.Exp
end

function ClientState:GetPet()
	return snapshot.Pet
end

return ClientState
