local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(script.Services.PlayerDataService)
local CombatService = require(script.Services.CombatService)
local MonsterService = require(script.Services.MonsterService)
local RoomService = require(script.Services.RoomService)
local UpgradeService = require(script.Services.UpgradeService)
local Weapons = require(ReplicatedStorage.Shared.Config.Weapons)

local Remotes = ReplicatedStorage.Shared.Remotes
local UseSkill = Remotes:WaitForChild("UseSkill")

local function findClosestEnemy(player, range)
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return nil
    end

    local closest
    local minDist = range

    for _, monster in ipairs(RoomService:GetActiveEnemies()) do
        local root = monster:FindFirstChild("HumanoidRootPart")
        local humanoid = monster:FindFirstChildOfClass("Humanoid")
        if root and humanoid and humanoid.Health > 0 then
            local dist = (root.Position - hrp.Position).Magnitude
            if dist <= minDist then
                minDist = dist
                closest = monster
            end
        end
    end

    return closest
end

UseSkill.OnServerEvent:Connect(function(player, mode)
    if mode ~= "Hit" then
        return
    end

    local weaponId = player:GetAttribute("EquippedWeaponId")
    local weapon = weaponId and Weapons[weaponId] or Weapons.Basic
    local range = weapon.Range or 10

    local target = findClosestEnemy(player, range)
    if not target then
        return
    end

    CombatService:ApplyDamage(player, target, weaponId)
end)

Players.PlayerAdded:Connect(function(player)
    PlayerDataService:GetData(player)

    if player.Character then
        PlayerDataService:ApplyCharacterStats(player, player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        PlayerDataService:ApplyCharacterStats(player, character)
    end)
end)

MonsterService:Start()
UpgradeService:Start()
