-- local Players = game:GetService("Players")
-- local player = Players.LocalPlayer

-- local WeaponClient = require(game.ReplicatedStorage.Modules.WeaponClient)
-- local WeaponController = require(game.ReplicatedStorage.Modules.WeaponController)
-- local WeaponInput = require(game.ReplicatedStorage.Modules.WeaponInput)
-- local WeaponConfig = require(game.ReplicatedStorage.Modules.WeaponConfig)

-- local currentWeapon

-- local function onToolEquipped(tool)
-- 	if not tool:IsA("Tool") then return end
-- 	if not tool:FindFirstChild("WeaponTag") then return end -- đánh dấu weapon

-- 	currentWeapon = WeaponClient.new(tool)
-- 	WeaponController.Equip(tool, currentWeapon)

-- 	WeaponInput.Bind(function(skill)
-- 		local cfg = WeaponConfig[skill]
-- 		currentWeapon:PlayAttack(skill, cfg.AnimationId, cfg.Trail, cfg.Cooldown)
-- 	end)
-- end

-- local function onToolUnequipped(tool)
-- 	if currentWeapon then
-- 		WeaponController.Unequip()
-- 		currentWeapon = nil
-- 	end
-- end

-- -- detect equip
-- player.CharacterAdded:Connect(function(char)

-- 	char.ChildAdded:Connect(function(obj)
-- 		if obj:IsA("Tool") then
-- 			obj.Equipped:Connect(function()
-- 				onToolEquipped(obj)
-- 			end)

-- 			obj.Unequipped:Connect(function()
-- 				onToolUnequipped(obj)
-- 			end)
-- 		end
-- 	end)

-- end)
