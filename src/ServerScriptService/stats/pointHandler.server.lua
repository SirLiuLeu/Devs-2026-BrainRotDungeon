local rp = game:GetService("ReplicatedStorage")
local Points = rp:WaitForChild("StatSystem"):WaitForChild("Points")

Points.OnServerEvent:Connect(function(Player,typeStat)
	local Character = Player.Character
	local Humanoid = Character:WaitForChild("Humanoid")
	
	local Stats = Player:WaitForChild("Data")
	local Points = Player:WaitForChild("Data"):WaitForChild("Points")
	local PointsS = Player:WaitForChild("Data"):WaitForChild("PointsS")
	local DefenseP = Player:WaitForChild("Data"):WaitForChild("DefenseP")
	local LuckP = Player:WaitForChild("Data"):WaitForChild("LuckP")
	local SpecialP = Player:WaitForChild("Data"):WaitForChild("SpecialP")
	local SwordP = Player:WaitForChild("Data"):WaitForChild("SwordP")

	
	if Points.Value >= PointsS.Value then
		if typeStat == "Defense" and DefenseP.Value < 300 then
			local statType = Stats:WaitForChild(typeStat)
			statType.Value = statType.Value + 5 * PointsS.Value
			DefenseP.Value = DefenseP.Value + PointsS.Value
			Points.Value = Points.Value - PointsS.Value
			
			Humanoid.MaxHealth = statType.Value + 100
	
		elseif typeStat == "Luck" and LuckP.Value < 300 then
			local statType = Stats:WaitForChild(typeStat)
			statType.Value = statType.Value + 1 * PointsS.Value
			LuckP.Value = LuckP.Value + PointsS.Value
			Points.Value = Points.Value - PointsS.Value
			
		elseif typeStat == "Special" and SpecialP.Value < 300 then
			local statType = Stats:WaitForChild(typeStat)
			statType.Value = statType.Value + 5 * PointsS.Value
			SpecialP.Value = SpecialP.Value + PointsS.Value
			Points.Value = Points.Value - PointsS.Value
			
		elseif typeStat == "Sword" and SwordP.Value < 300 then
			local statType = Stats:WaitForChild(typeStat)
			statType.Value = statType.Value + 5 * PointsS.Value
			SwordP.Value = SwordP.Value + PointsS.Value
			Points.Value = Points.Value - PointsS.Value
			
		end
	end
end)