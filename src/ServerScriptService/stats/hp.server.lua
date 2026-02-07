game.Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(character)
		local Data = player.Data
		local Defense = Data:WaitForChild("Defense")
		character.Humanoid.MaxHealth = Defense.Value + 100
		character.Humanoid.Health = character.Humanoid.MaxHealth + 100
		
	end)
end)