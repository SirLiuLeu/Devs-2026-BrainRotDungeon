local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage.Remotes.UseSkill

local Cooldown = {}
local COOLDOWN_TIME = 1.5
Remote.OnServerEvent:Connect(function(player, mode, skillName)
	if mode ~= "Hit" then return end
	-- cooldown
	if Cooldown[player] then return end
	Cooldown[player] = true

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
    
	-- damage
	if workspace:FindFirstChild("Enemies") then
		for _, enemy in pairs(workspace.Enemies:GetChildren()) do
			local eh = enemy:FindFirstChildOfClass("Humanoid")
			local erp = enemy:FindFirstChild("HumanoidRootPart")
			if eh and erp then
				local dist = (erp.Position - hrp.Position).Magnitude
                print("Distance to ", enemy.Name, ": ", dist)
				if dist <= 20 then
					eh:TakeDamage(25)				
				end
			end
		end
	end

	task.delay(COOLDOWN_TIME, function()
		Cooldown[player] = nil
	end)
end)