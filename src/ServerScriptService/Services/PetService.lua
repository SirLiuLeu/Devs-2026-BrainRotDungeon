local PetService = {}

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function ensureValue(parent, name, className, value)
	local valueObject = parent:FindFirstChild(name)
	if not valueObject then
		valueObject = Instance.new(className)
		valueObject.Name = name
		valueObject.Parent = parent
	end
	if value ~= nil then
		valueObject.Value = value
	end
	return valueObject
end

function PetService:EnsurePetData(player)
	local data = player:FindFirstChild("Data")
	if not data then
		return nil
	end
	local petFolder = ensureFolder(data, "Pet")
	ensureValue(petFolder, "Equipped", "StringValue", "")
	ensureFolder(petFolder, "Pets")

	local modifiers = ensureFolder(data, "PetModifiers")
	ensureValue(modifiers, "Damage", "NumberValue", 0)
	ensureValue(modifiers, "MaxHP", "NumberValue", 0)
	return petFolder
end

function PetService:ApplyPetModifiers(player, modifiers)
	local data = player:FindFirstChild("Data")
	local petModifiers = data and data:FindFirstChild("PetModifiers")
	if not petModifiers then
		return
	end
	for statName, value in pairs(modifiers or {}) do
		local valueObject = petModifiers:FindFirstChild(statName)
		if valueObject and valueObject:IsA("NumberValue") then
			valueObject.Value = value
		end
	end
end

function PetService:AddPet(player, petId)
	local petFolder = self:EnsurePetData(player)
	if not petFolder then
		return nil
	end
	local petsFolder = petFolder:FindFirstChild("Pets")
	if not petsFolder then
		return nil
	end

	local petUid = tostring(os.clock()):gsub("%.", "")
	local petEntry = Instance.new("Folder")
	petEntry.Name = petUid
	petEntry.Parent = petsFolder
	ensureValue(petEntry, "PetId", "StringValue", petId)
	ensureValue(petEntry, "Level", "IntValue", 1)
	return petUid
end

function PetService:HydratePets(player, petData)
	local petFolder = self:EnsurePetData(player)
	if not petFolder then
		return
	end
	local equippedValue = petFolder:FindFirstChild("Equipped")
	if equippedValue and petData and petData.Equipped then
		equippedValue.Value = petData.Equipped
	end

	local petsFolder = petFolder:FindFirstChild("Pets")
	if petsFolder then
		petsFolder:ClearAllChildren()
		for petUid, petInfo in pairs((petData and petData.Pets) or {}) do
			local petEntry = Instance.new("Folder")
			petEntry.Name = petUid
			petEntry.Parent = petsFolder
			ensureValue(petEntry, "PetId", "StringValue", petInfo.PetId or "")
			ensureValue(petEntry, "Level", "IntValue", petInfo.Level or 1)
		end
	end

	self:ApplyPetModifiers(player, (petData and petData.Modifiers) or {})
end

function PetService:SerializePets(player)
	local data = player:FindFirstChild("Data")
	local petFolder = data and data:FindFirstChild("Pet")
	local result = {
		Equipped = "",
		Pets = {},
		Modifiers = {},
	}
	if not petFolder then
		return result
	end

	local equippedValue = petFolder:FindFirstChild("Equipped")
	if equippedValue and equippedValue:IsA("StringValue") then
		result.Equipped = equippedValue.Value
	end

	local petsFolder = petFolder:FindFirstChild("Pets")
	if petsFolder then
		for _, petEntry in ipairs(petsFolder:GetChildren()) do
			if petEntry:IsA("Folder") then
				local petIdValue = petEntry:FindFirstChild("PetId")
				local levelValue = petEntry:FindFirstChild("Level")
				result.Pets[petEntry.Name] = {
					PetId = petIdValue and petIdValue.Value or "",
					Level = levelValue and levelValue.Value or 1,
				}
			end
		end
	end

	local petModifiers = data:FindFirstChild("PetModifiers")
	if petModifiers then
		for _, valueObject in ipairs(petModifiers:GetChildren()) do
			if valueObject:IsA("NumberValue") then
				result.Modifiers[valueObject.Name] = valueObject.Value
			end
		end
	end

	return result
end

return PetService
