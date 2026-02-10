local Players = game:GetService("Players")

local RoomService = {}
RoomService._rooms = {}

local function ensureRoomId(entity)
	if not entity then
		return nil
	end
	local existing = entity:GetAttribute("RoomId")
	if existing == nil then
		entity:SetAttribute("RoomId", 0)
		return 0
	end
	return existing
end

local function register(entity)
	local roomId = ensureRoomId(entity)
	if roomId == nil then
		return nil
	end
	if not RoomService._rooms[roomId] then
		RoomService._rooms[roomId] = { Players = {}, Enemies = {} }
	end
	return roomId
end

function RoomService:AssignPlayer(player, roomId)
	if not player then
		return
	end
	player:SetAttribute("RoomId", roomId)
	register(player)
	self._rooms[roomId].Players[player] = true
end

function RoomService:AssignEnemy(enemy, roomId)
	if not enemy then
		return
	end
	enemy:SetAttribute("RoomId", roomId)
	register(enemy)
	self._rooms[roomId].Enemies[enemy] = true
end

function RoomService:ClearEntity(entity)
	if not entity then
		return
	end
	local roomId = entity:GetAttribute("RoomId")
	if roomId == nil then
		return
	end
	local room = self._rooms[roomId]
	if room then
		room.Players[entity] = nil
		room.Enemies[entity] = nil
	end
end

function RoomService:GetRoomId(entity)
	if not entity then
		return nil
	end
	return ensureRoomId(entity)
end

function RoomService:CanInteract(entityA, entityB)
	if not entityA or not entityB then
		return false
	end
	local roomA = self:GetRoomId(entityA)
	local roomB = self:GetRoomId(entityB)
	if roomA == nil or roomB == nil then
		return true
	end
	return roomA == roomB
end

Players.PlayerAdded:Connect(function(player)
	register(player)
end)

Players.PlayerRemoving:Connect(function(player)
	RoomService:ClearEntity(player)
end)

return RoomService
