local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Weapons = require(ReplicatedStorage.Shared.Config.Weapons)
local PlayerStateService = require(script.Parent.PlayerStateService)

local function getWeaponConfig(weaponId)
	return Weapons[weaponId] or Weapons.Basic
end

local function getWeaponIdFromTool(tool)
	if not tool or not tool:IsA("Tool") then
		return nil
	end
	return tool:GetAttribute("ItemId") or tool.Name
end

local function buildWeaponStats(weaponConfig)
	return {
		Damage = weaponConfig.Damage or 0,
		Defense = weaponConfig.Defense or 0,
		MaxHP = weaponConfig.MaxHP or 0,
		MoveSpeed = weaponConfig.MoveSpeed or 0,
	}
end

local function attachToolSignals(player, tool)
	if not tool:IsA("Tool") then
		return
	end
	if not tool:FindFirstChild("WeaponTag") then
		return
	end

	tool.Equipped:Connect(function()
		local weaponId = getWeaponIdFromTool(tool)
		local weaponConfig = getWeaponConfig(weaponId)
		PlayerStateService:SetEquippedWeapon(player, weaponId, buildWeaponStats(weaponConfig))
	end)

	tool.Unequipped:Connect(function()
		local weaponConfig = getWeaponConfig("Basic")
		PlayerStateService:SetEquippedWeapon(player, "Basic", buildWeaponStats(weaponConfig))
	end)
end

local function attachContainer(player, container)
	for _, child in ipairs(container:GetChildren()) do
		attachToolSignals(player, child)
	end
	container.ChildAdded:Connect(function(child)
		attachToolSignals(player, child)
	end)
end

Players.PlayerAdded:Connect(function(player)
	local starterConfig = getWeaponConfig("Basic")
	PlayerStateService:SetEquippedWeapon(player, "Basic", buildWeaponStats(starterConfig))
	player.CharacterAdded:Connect(function(character)
		attachContainer(player, character)
	end)

	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		attachContainer(player, backpack)
	end
	player.ChildAdded:Connect(function(child)
		if child.Name == "Backpack" then
			attachContainer(player, child)
		end
	end)
end)
