local Players = game:GetService("Players")
local WeaponController = {}

local player = Players.LocalPlayer
local currentWeapon

function WeaponController.Equip(tool, weaponClient)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	weaponClient:BindCharacter(character, humanoid)
	currentWeapon = weaponClient
end

function WeaponController.Unequip()
	if currentWeapon then
		currentWeapon:Cleanup()
		currentWeapon = nil
	end
end

return WeaponController
