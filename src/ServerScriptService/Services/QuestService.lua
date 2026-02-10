local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TaskConfig = require(ReplicatedStorage.Shared.Data.TaskConfig).TaskConfig

local QuestService = {}

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function ensureValue(parent, name, className, value)
	local valueObject = parent:FindFirstChild(name)
	if not valueObject then
		valueObject = Instance.new(className)
		valueObject.Name = name
		valueObject.Parent = parent
	end
	if value ~= nil then
		valueObject.Value = value
	end
	return valueObject
end

function QuestService:EnsureQuestData(player)
	local data = player:FindFirstChild("Data")
	if not data then
		return nil
	end
	local questFolder = ensureFolder(data, "Quest")
	ensureFolder(questFolder, "Progress")
	ensureFolder(questFolder, "Claimed")
	return questFolder
end

function QuestService:HydrateQuest(player, questData)
	local questFolder = self:EnsureQuestData(player)
	if not questFolder then
		return
	end
	local progressFolder = questFolder:FindFirstChild("Progress")
	local claimedFolder = questFolder:FindFirstChild("Claimed")
	if progressFolder then
		progressFolder:ClearAllChildren()
		for questId, value in pairs((questData and questData.Progress) or {}) do
			ensureValue(progressFolder, questId, "IntValue", value)
		end
	end
	if claimedFolder then
		claimedFolder:ClearAllChildren()
		for questId, value in pairs((questData and questData.Claimed) or {}) do
			ensureValue(claimedFolder, questId, "BoolValue", value)
		end
	end
end

function QuestService:SerializeQuest(player)
	local data = player:FindFirstChild("Data")
	local questFolder = data and data:FindFirstChild("Quest")
	local result = {
		Progress = {},
		Claimed = {},
	}
	if not questFolder then
		return result
	end
	local progressFolder = questFolder:FindFirstChild("Progress")
	if progressFolder then
		for _, valueObject in ipairs(progressFolder:GetChildren()) do
			if valueObject:IsA("ValueBase") then
				result.Progress[valueObject.Name] = valueObject.Value
			end
		end
	end
	local claimedFolder = questFolder:FindFirstChild("Claimed")
	if claimedFolder then
		for _, valueObject in ipairs(claimedFolder:GetChildren()) do
			if valueObject:IsA("BoolValue") then
				result.Claimed[valueObject.Name] = valueObject.Value
			end
		end
	end
	return result
end

function QuestService:RecordEvent(player, eventName, payload)
	local questFolder = self:EnsureQuestData(player)
	if not questFolder then
		return
	end
	local progressFolder = questFolder:FindFirstChild("Progress")
	if not progressFolder then
		return
	end

	for questId, quest in pairs(TaskConfig or {}) do
		if quest.Objective and quest.Objective.Event == eventName then
			local progressValue = progressFolder:FindFirstChild(questId)
			if not progressValue then
				progressValue = ensureValue(progressFolder, questId, "IntValue", 0)
			end
			progressValue.Value += 1
		end
	end
end

return QuestService
