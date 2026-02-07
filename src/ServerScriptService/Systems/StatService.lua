local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Weapons = require(ReplicatedStorage.Shared.Config.Weapons)
local PlayerStateService = require(ServerScriptService.Services.PlayerStateService)

local StatService = {}

local function getWeaponConfig(weaponId)
	if weaponId and Weapons[weaponId] then
		return Weapons[weaponId]
	end
	return Weapons.Basic
end

local function getValueFromContainer(container, statName)
	if not container then
		return 0
	end
	if typeof(container) == "table" then
		return tonumber(container[statName]) or 0
	end
	if typeof(container) == "Instance" then
		local statValue = container:FindFirstChild(statName)
		if statValue and statValue:IsA("ValueBase") then
			return statValue.Value
		end
	end
	return 0
end

local function getPlayerData(player)
	if not player or not player:IsA("Player") then
		return nil
	end
	return player:FindFirstChild("Data")
end

local function resolveBaseStats(player)
	local data = getPlayerData(player)
	local baseStats = data and data:FindFirstChild("BasePlayerStats")
	if baseStats then
		return baseStats
	end
	local state = PlayerStateService:GetState(player)
	return state and state.Stats or nil
end

local function resolveWeaponStats(player, weaponId)
	local data = getPlayerData(player)
	local weaponStats = data and data:FindFirstChild("WeaponStats")
	if weaponStats then
		return weaponStats
	end
	local weaponConfig = getWeaponConfig(weaponId or player:GetAttribute("EquippedWeaponId"))
	return {
		Damage = weaponConfig.Damage or 0,
	}
end

local function resolveModifiers(player, name)
	local data = getPlayerData(player)
	if not data then
		return nil
	end
	return data:FindFirstChild(name)
end

function StatService:GetFinalDamage(player, weaponId)
	if not player or not player:IsA("Player") then
		return 0
	end

	local baseStats = resolveBaseStats(player)
	local weaponStats = resolveWeaponStats(player, weaponId)
	local petModifiers = resolveModifiers(player, "PetModifiers")
	local boostModifiers = resolveModifiers(player, "BoostModifiers")

	local baseDamage = getValueFromContainer(baseStats, "Damage")
	local weaponDamage = getValueFromContainer(weaponStats, "Damage")
	local petDamage = getValueFromContainer(petModifiers, "Damage")
	local boostDamage = getValueFromContainer(boostModifiers, "Damage")

	return math.max(0, baseDamage + weaponDamage + petDamage + boostDamage)
end

function StatService:GetMaxHP(player)
	if not player or not player:IsA("Player") then
		return 0
	end

	local baseStats = resolveBaseStats(player)
	local petModifiers = resolveModifiers(player, "PetModifiers")
	local boostModifiers = resolveModifiers(player, "BoostModifiers")

	local baseHp = getValueFromContainer(baseStats, "MaxHP")
	local petHp = getValueFromContainer(petModifiers, "MaxHP")
	local boostHp = getValueFromContainer(boostModifiers, "MaxHP")

	return math.max(0, baseHp + petHp + boostHp)
end

return StatService
