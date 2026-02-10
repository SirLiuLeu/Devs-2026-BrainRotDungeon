local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStateService = require(script.Parent.PlayerStateService)
local InventoryService = require(script.Parent.InventoryService)
local EquipmentService = require(script.Parent.EquipmentService)
local PetService = require(script.Parent.PetService)
local QuestService = require(script.Parent.QuestService)

local PersistenceService = {}
PersistenceService._profiles = {}
PersistenceService._autosaveConnections = {}

local STORE = DataStoreService:GetDataStore("PlayerProfiles")
local AUTOSAVE_INTERVAL = 60

local function deepCopy(original)
	if typeof(original) ~= "table" then
		return original
	end
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = deepCopy(value)
	end
	return copy
end

local function buildDefaultProfile(userId)
	return {
		Identity = {
			UserId = userId,
			JoinDate = os.time(),
			TotalPlayTime = 0,
		},
		Progression = {
			Level = 1,
			Exp = 0,
			Rebirth = 0,
			StatPoints = 0,
			AllocatedStats = {
				Strength = 0,
				Vitality = 0,
				Agility = 0,
			},
		},
		Currency = {
			Gold = 0,
			Bone = 0,
			Premium = 0,
		},
		Equipment = {},
		Inventory = {
			Items = {},
			Capacity = 30,
		},
		Skills = {
			Active = nil,
			Passive = nil,
			Learned = {},
		},
		Pet = {
			Equipped = "",
			Pets = {},
			Modifiers = {},
		},
		Quest = {
			Progress = {},
			Claimed = {},
		},
		Statistics = {
			TotalKills = 0,
			BossKills = 0,
			TotalDamage = 0,
		},
	}
end

local function mergeDefaults(defaults, loaded)
	local result = deepCopy(defaults)
	for key, value in pairs(loaded or {}) do
		if typeof(value) == "table" and typeof(result[key]) == "table" then
			result[key] = mergeDefaults(result[key], value)
		else
			result[key] = value
		end
	end
	return result
end

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end
print("PLACE ID", game.PlaceId)
print("JOB ID", game.JobId)
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

local function hydrateDataFolder(player, profile)
	local dataFolder = player:FindFirstChild("Data")
	if not dataFolder then
		dataFolder = Instance.new("Folder")
		dataFolder.Name = "Data"
		dataFolder.Parent = player
	end

	ensureValue(dataFolder, "Level", "IntValue", profile.Progression.Level)
	ensureValue(dataFolder, "Exp", "IntValue", profile.Progression.Exp)
	ensureValue(dataFolder, "Gold", "IntValue", profile.Currency.Gold)
	ensureValue(dataFolder, "Bone", "IntValue", profile.Currency.Bone)
	ensureValue(dataFolder, "Rebirth", "IntValue", profile.Progression.Rebirth)
	ensureValue(dataFolder, "StatPoints", "IntValue", profile.Progression.StatPoints)

	local allocated = ensureFolder(dataFolder, "AllocatedStats")
	ensureValue(allocated, "Strength", "IntValue", profile.Progression.AllocatedStats.Strength)
	ensureValue(allocated, "Vitality", "IntValue", profile.Progression.AllocatedStats.Vitality)
	ensureValue(allocated, "Agility", "IntValue", profile.Progression.AllocatedStats.Agility)

	InventoryService:HydrateInventory(player, profile.Inventory)
	EquipmentService:HydrateEquipment(player, profile.Equipment)
	PetService:HydratePets(player, profile.Pet)
	QuestService:HydrateQuest(player, profile.Quest)

	return dataFolder
end

local function buildProfileFromRuntime(player)
	local profile = buildDefaultProfile(player.UserId)
	local state = PlayerStateService:GetState(player)
	if state then
		profile.Progression.Level = state.Level
		profile.Progression.Exp = state.Exp
		profile.Progression.Rebirth = state.Rebirth
		profile.Progression.StatPoints = state.StatPoints
		profile.Progression.AllocatedStats = deepCopy(state.AllocatedStats)
		profile.Currency.Gold = state.Gold
		profile.Currency.Bone = state.Bone
	end

	profile.Inventory = InventoryService:SerializeInventory(player)
	profile.Equipment = EquipmentService:SerializeEquipment(player)
	profile.Pet = PetService:SerializePets(player)
	profile.Quest = QuestService:SerializeQuest(player)
	return profile
end

function PersistenceService:LoadProfile(player)
	local defaults = buildDefaultProfile(player.UserId)
	local success, stored = pcall(function()
		return STORE:GetAsync(tostring(player.UserId))
	end)
	print("PersistenceService: Loaded profile for", player.Name, "Success:", success, stored)
	local merged = success and mergeDefaults(defaults, stored) or defaults
	self._profiles[player] = merged

	hydrateDataFolder(player, merged)
	PlayerStateService:GetState(player)
	PlayerStateService:_trackPlayer(player)
	PlayerStateService:ApplyProfile(player, merged)
end

function PersistenceService:SaveProfile(player)
	local profile = buildProfileFromRuntime(player)
	self._profiles[player] = profile

	local success
	for attempt = 1, 3 do
		success = pcall(function()
			STORE:SetAsync(tostring(player.UserId), profile)
		end)
		if success then
			break
		end
		task.wait(2 * attempt)
	end
	return success
end

function PersistenceService:StartAutosave(player)
	if self._autosaveConnections[player] then
		return
	end
	self._autosaveConnections[player] = task.spawn(function()
		while player.Parent do
			task.wait(AUTOSAVE_INTERVAL)
			self:SaveProfile(player)
		end
	end)
end

function PersistenceService:StopAutosave(player)
	local thread = self._autosaveConnections[player]
	if thread then
		task.cancel(thread)
		self._autosaveConnections[player] = nil
	end
end

Players.PlayerAdded:Connect(function(player)
	PersistenceService:LoadProfile(player)
	PersistenceService:StartAutosave(player)
end)

Players.PlayerRemoving:Connect(function(player)
	PersistenceService:SaveProfile(player)
	PersistenceService:StopAutosave(player)
	PlayerStateService:CleanupPlayer(player)
end)

return PersistenceService
