local Players = game:GetService("Players")

local RankingService = {}
RankingService._entries = {}

function RankingService:UpdatePlayer(player, stats)
	if not player then
		return
	end
	self._entries[player.UserId] = {
		UserId = player.UserId,
		Level = stats.Level or 1,
		Power = stats.Power or 0,
		Rebirth = stats.Rebirth or 0,
	}
end

function RankingService:RemovePlayer(player)
	if player then
		self._entries[player.UserId] = nil
	end
end

function RankingService:GetTopEntries()
	local entries = {}
	for _, entry in pairs(self._entries) do
		table.insert(entries, entry)
	end
	table.sort(entries, function(a, b)
		if a.Level == b.Level then
			return a.Power > b.Power
		end
		return a.Level > b.Level
	end)
	return entries
end

Players.PlayerRemoving:Connect(function(player)
	RankingService:RemovePlayer(player)
end)

return RankingService
