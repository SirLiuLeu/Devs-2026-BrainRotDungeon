local WeaponClient = require(game.ReplicatedStorage.Modules.WeaponClient)
local WeaponController = require(game.ReplicatedStorage.Modules.WeaponController)
local WeaponInput = require(game.ReplicatedStorage.Modules.WeaponInput)
local WeaponConfig = require(game.ReplicatedStorage.Modules.WeaponConfig)

local Tool
local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

for _, tool in ipairs(backpack:GetChildren()) do
	if tool:IsA("Tool") then
		print(tool.Name)
        Tool = tool
	end
end


local weapon = WeaponClient.new(Tool)

Tool.Equipped:Connect(function()
	WeaponController.Equip(Tool, weapon)
	print("Equipped")
	WeaponInput.Bind(function(skill)
		weapon:PlayAttack(skill, WeaponConfig[skill].AnimationId, WeaponConfig[skill].Trail, WeaponConfig[skill].Cooldown)
	end)
end)

Tool.Unequipped:Connect(function()
	WeaponController.Unequip()
end)

Tool.Activated:Connect(function()
	local skill = "Basic"
	weapon:PlayAttack(skill, WeaponConfig[skill].AnimationId, WeaponConfig[skill].Trail, WeaponConfig[skill].Cooldown)
end)
