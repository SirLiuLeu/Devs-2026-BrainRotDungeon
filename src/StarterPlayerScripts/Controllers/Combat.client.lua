local Players = game:GetService("Players")
local player = Players.LocalPlayer

local controllers = script.Parent
local WeaponClient = require(controllers:WaitForChild("WeaponClient"))
local WeaponController = require(controllers:WaitForChild("WeaponController"))
local WeaponInput = require(script.Parent.Parent:WaitForChild("Input"):WaitForChild("WeaponInput"))
local WeaponConfig = require(game.ReplicatedStorage.Shared.Config.WeaponConfig)

local weaponByTool = {}
local currentWeapon
local toolConnections = {}
local containerConnections = {}

local function ensureWeapon(tool)
	if not weaponByTool[tool] then
		weaponByTool[tool] = WeaponClient.new(tool)
	end

	return weaponByTool[tool]
end

local function onToolEquipped(tool)
	if not tool:IsA("Tool") then return end
	if not tool:FindFirstChild("WeaponTag") then return end
    
	local weapon = ensureWeapon(tool)
	currentWeapon = weapon
	WeaponController.Equip(tool, weapon)
end

local function onToolUnequipped(tool)
	if currentWeapon and weaponByTool[tool] == currentWeapon then
		WeaponController.Unequip()
		currentWeapon = nil
	end
end

local function onToolActivated(tool)
	if not weaponByTool[tool] then return end
	local skill = "Basic"
	local cfg = WeaponConfig[skill]
	weaponByTool[tool]:PlayAttack(skill, cfg.AnimationId, cfg.Trail, cfg.Cooldown)
end

local function bindInput()
	WeaponInput.Bind(function(skill)
		if not currentWeapon then return end
		local cfg = WeaponConfig[skill]
		currentWeapon:PlayAttack(skill, cfg.AnimationId, cfg.Trail, cfg.Cooldown)
	end)
end

local function connectTool(tool)
	if toolConnections[tool] then return end
	if not tool:IsA("Tool") then return end
    print("WeaponRuntime loaded for ", player.Name)
	if not tool:FindFirstChild("WeaponTag") then return end
    
	toolConnections[tool] = true
	tool.Equipped:Connect(function()
		onToolEquipped(tool)
	end)
	tool.Unequipped:Connect(function()
		onToolUnequipped(tool)
	end)
	tool.Activated:Connect(function()
		onToolActivated(tool)
	end)
end

local function connectContainer(container)
	if containerConnections[container] then return end
	containerConnections[container] = true
	for _, child in ipairs(container:GetChildren()) do
		connectTool(child)
	end
	container.ChildAdded:Connect(connectTool)
end

bindInput()

if player.Backpack then
	connectContainer(player.Backpack)
end

player.CharacterAdded:Connect(function(character)
	connectContainer(character)
	if player.Backpack then
		connectContainer(player.Backpack)
	end
end)
