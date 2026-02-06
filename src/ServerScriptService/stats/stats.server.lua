local DataStore = game:GetService("DataStoreService")
local Level1 = DataStore:GetDataStore("Levels001")
local Beli11 = DataStore:GetDataStore("Beli001")
local Exp1 = DataStore:GetDataStore("Exp001")
local ExpNeed1 = DataStore:GetDataStore("ExpNeed001")
local DefenseP1 = DataStore:GetDataStore("DefenseP001")
local SwordP1 = DataStore:GetDataStore("SwordP001")
local LuckP1 = DataStore:GetDataStore("LuckP001")
local SpecialP1 = DataStore:GetDataStore("Special001")
local Defense1 = DataStore:GetDataStore("Defense001")
local Sword1 = DataStore:GetDataStore("Sword001")
local Luck1 = DataStore:GetDataStore("Luck001")
local Special1 = DataStore:GetDataStore("Special001")
local Points1 = DataStore:GetDataStore("Points001")

game.Players.PlayerAdded:Connect(function(Plr)
	local stats = Instance.new("Folder", Plr)
	stats.Name = "Data"
	--- Level System
	local Levels = Instance.new("IntValue", stats)
	Levels.Name = "Levels"
	Levels.Value = 1
	local Exp = Instance.new("IntValue", stats)
	Exp.Name = "Exp"
	Exp.Value = 0
	local ExpNeed = Instance.new("IntValue", stats)
	ExpNeed.Name = "ExpNeed"
	ExpNeed.Value = 200
	--- Money System
	local Beli = Instance.new("IntValue", stats)
	Beli.Name = "Gold"
	Beli.Value = 0
	--- Stats Text
	local DefenseP = Instance.new("IntValue", stats)
	DefenseP.Name = "DefenseP"
	DefenseP.Value = 1
	local SwordP = Instance.new("IntValue", stats)
	SwordP.Name = "SwordP"
	SwordP.Value = 1
	local LuckP = Instance.new("IntValue", stats)
	LuckP.Name = "LuckP"
	LuckP.Value = 1
	local SpecialP = Instance.new("IntValue", stats)
	SpecialP.Name = "SpecialP"
	SpecialP.Value = 1
	--- Stats System
	local Points = Instance.new("IntValue", stats)
	Points.Name = "Points"
	Points.Value = 0
	local PointsS = Instance.new("IntValue", stats)
	PointsS.Name = "PointsS"
	PointsS.Value = 1
	local Defense = Instance.new("IntValue", stats)
	Defense.Name = "Defense"
	Defense.Value = 0
	local Sword = Instance.new("IntValue", stats)
	Sword.Name = "Sword"
	Sword.Value = 0
	local Luck = Instance.new("IntValue", stats)
	Luck.Name = "Luck"
	Luck.Value = 0
	local Special = Instance.new("IntValue", stats)
	Special.Name = "Special"
	Special.Value = 0
---- Datastore ----
--- Levels
   Levels.Value = Level1:GetAsync(Plr.UserId) or Levels.Value
	   Level1:SetAsync(Plr.UserId, Levels.Value)
      Levels.Changed:connect(function()
	   Level1:SetAsync(Plr.UserId, Levels.Value)
   end)
--- Gold
   Beli.Value = Beli11:GetAsync(Plr.UserId) or Beli.Value
	   Beli11:SetAsync(Plr.UserId, Beli.Value)
      Beli.Changed:connect(function()
	   Beli11:SetAsync(Plr.UserId, Beli.Value)
   end)
--- Exp
   Exp.Value = Exp1:GetAsync(Plr.UserId) or Exp.Value
	   Exp1:SetAsync(Plr.UserId, Exp.Value)
      Exp.Changed:connect(function()
	   Exp1:SetAsync(Plr.UserId, Exp.Value)
   end)
--- ExpNeed
   ExpNeed.Value = ExpNeed1:GetAsync(Plr.UserId) or ExpNeed.Value
	   ExpNeed1:SetAsync(Plr.UserId, ExpNeed.Value)
      ExpNeed.Changed:connect(function()
	   ExpNeed1:SetAsync(Plr.UserId, ExpNeed.Value)
   end)
--- SwordP
   SwordP.Value = SwordP1:GetAsync(Plr.UserId) or SwordP.Value
	   SwordP1:SetAsync(Plr.UserId, SwordP.Value)
      SwordP.Changed:connect(function()
	   SwordP1:SetAsync(Plr.UserId, SwordP.Value)
   end)
--- DefenseP
   DefenseP.Value = DefenseP1:GetAsync(Plr.UserId) or DefenseP.Value
	   DefenseP1:SetAsync(Plr.UserId, DefenseP.Value)
      DefenseP.Changed:connect(function()
	   DefenseP1:SetAsync(Plr.UserId, DefenseP.Value)
   end)
--- LuckP
   ExpNeed.Value = ExpNeed1:GetAsync(Plr.UserId) or ExpNeed.Value
	   ExpNeed1:SetAsync(Plr.UserId, ExpNeed.Value)
      ExpNeed.Changed:connect(function()
	   ExpNeed1:SetAsync(Plr.UserId, ExpNeed.Value)
   end)
--- SpecialP
   ExpNeed.Value = ExpNeed1:GetAsync(Plr.UserId) or ExpNeed.Value
	   ExpNeed1:SetAsync(Plr.UserId, ExpNeed.Value)
      ExpNeed.Changed:connect(function()
	   ExpNeed1:SetAsync(Plr.UserId, ExpNeed.Value)
   end)
--- Sword
   Sword.Value = Sword1:GetAsync(Plr.UserId) or Sword.Value
	   Sword1:SetAsync(Plr.UserId, SwordP.Value)
      Sword.Changed:connect(function()
	   Sword1:SetAsync(Plr.UserId, SwordP.Value)
   end)
--- Defense
   Defense.Value = Defense1:GetAsync(Plr.UserId) or Defense.Value
	   Defense1:SetAsync(Plr.UserId, Defense.Value)
      Defense.Changed:connect(function()
	   Defense1:SetAsync(Plr.UserId, Defense.Value)
   end)
--- Luck
   Luck.Value = Luck1:GetAsync(Plr.UserId) or Luck.Value
	   Luck1:SetAsync(Plr.UserId, Luck.Value)
      Luck.Changed:connect(function()
	   Luck1:SetAsync(Plr.UserId, Luck.Value)
   end)
--- Special
   Special.Value = Special1:GetAsync(Plr.UserId) or Special.Value
	   Special1:SetAsync(Plr.UserId, Special.Value)
      Special.Changed:connect(function()
	   Special1:SetAsync(Plr.UserId, Special.Value)
   end)
--- Points
   Points.Value = Points1:GetAsync(Plr.UserId) or Points.Value
	   Points1:SetAsync(Plr.UserId, Points.Value)
      Points.Changed:connect(function()
	   Points1:SetAsync(Plr.UserId, Points.Value)
   end)
end)

game.Players.PlayerAdded:Connect(function(plr)
	wait(.1)
	local Exp = plr.Data.Exp
	local Levels = plr.Data.Levels
	local ExpNeed = plr.Data.ExpNeed
	local Points = plr.Data.Points
	
	while wait() do
		if Exp.Value >= (100 * (Levels.Value + 1)) and Levels.Value <= 399 then
			Levels.Value = Levels.Value + 1
			Points.Value = Points.Value + 3
			Exp.Value = Exp.Value - ExpNeed.Value
			ExpNeed.Value = ExpNeed.Value + 100
			game.ReplicatedStorage.LevelSystem.LevelUpGui:FireClient(plr)
		end
	end
end)

game.Players.PlayerRemoving:connect(function(Player)
	Level1:SetAsync(Player.UserId, Player.Data.Levels.Value)
	Beli11:SetAsync(Player.UserId, Player.Data.Beli.Value)
	Exp1:SetAsync(Player.UserId, Player.Data.Exp.Value)
	ExpNeed1:SetAsync(Player.UserId, Player.Data.ExpNeed.Value)
	SwordP1:SetAsync(Player.UserId, Player.Data.SwordP.Value)
	DefenseP1:SetAsync(Player.UserId, Player.Data.DefenseP.Value)
	LuckP1:SetAsync(Player.UserId, Player.Data.LuckP.Value)
	SpecialP1:SetAsync(Player.UserId, Player.Data.SpecialP.Value)
	Sword1:SetAsync(Player.UserId, Player.Data.Sword.Value)
	Defense1:SetAsync(Player.UserId, Player.Data.Defense.Value)
	Luck1:SetAsync(Player.UserId, Player.Data.Luck.Value)
	Special1:SetAsync(Player.UserId, Player.Data.Special.Value)
	Points1:SetAsync(Player.UserId, Player.Data.Points.Value)
end)