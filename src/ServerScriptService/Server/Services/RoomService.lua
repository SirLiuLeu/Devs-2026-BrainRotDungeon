local RoomService = {}
RoomService.ActiveEnemies = {}

function RoomService:RegisterEnemy(monster)
    if not monster then
        return
    end
    self.ActiveEnemies[monster] = true
end

function RoomService:UnregisterEnemy(monster)
    if not monster then
        return
    end
    self.ActiveEnemies[monster] = nil
end

function RoomService:GetActiveEnemies()
    local results = {}
    for monster in pairs(self.ActiveEnemies) do
        table.insert(results, monster)
    end
    return results
end

return RoomService
