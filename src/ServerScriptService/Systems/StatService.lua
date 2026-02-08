local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerStateService = require(ServerScriptService.Services.PlayerStateService)

local StatService = {}

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
	local state = PlayerStateService:GetState(player)
	return state and state.FinalStats or nil
end

local function resolveModifiers(player, name)
	local data = getPlayerData(player)
	if not data then
		return nil
	end
	return data:FindFirstChild(name)
end

function StatService:GetFinalStats(player)
	if not player or not player:IsA("Player") then
		return {
			MaxHP = 0,
			Damage = 0,
			Defense = 0,
			MoveSpeed = 0,
		}
	end

	local baseStats = resolveBaseStats(player)
	local petModifiers = resolveModifiers(player, "PetModifiers")
	local boostModifiers = resolveModifiers(player, "BoostModifiers")

	local baseDamage = getValueFromContainer(baseStats, "Damage")
	local petDamage = getValueFromContainer(petModifiers, "Damage")
	local boostDamage = getValueFromContainer(boostModifiers, "Damage")

	local baseHp = getValueFromContainer(baseStats, "MaxHP")
	local petHp = getValueFromContainer(petModifiers, "MaxHP")
	local boostHp = getValueFromContainer(boostModifiers, "MaxHP")

	local baseDefense = getValueFromContainer(baseStats, "Defense")
	local petDefense = getValueFromContainer(petModifiers, "Defense")
	local boostDefense = getValueFromContainer(boostModifiers, "Defense")

	local baseMoveSpeed = getValueFromContainer(baseStats, "MoveSpeed")
	local petMoveSpeed = getValueFromContainer(petModifiers, "MoveSpeed")
	local boostMoveSpeed = getValueFromContainer(boostModifiers, "MoveSpeed")

	return {
		MaxHP = math.max(0, baseHp + petHp + boostHp),
		Damage = math.max(0, baseDamage + petDamage + boostDamage),
		Defense = math.max(0, baseDefense + petDefense + boostDefense),
		MoveSpeed = math.max(0, baseMoveSpeed + petMoveSpeed + boostMoveSpeed),
	}
end

function StatService:GetMaxHP(player)
	return self:GetFinalStats(player).MaxHP
end

function StatService:GetFinalDamage(player)
	return self:GetFinalStats(player).Damage
end

return StatService
