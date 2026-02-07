local LevelExp = {}

local MAX_LEVEL = 100
local total = 0

for level = 1, MAX_LEVEL do
    local expToNext = math.floor(50 + (level ^ 1.6) * 20)

    LevelExp[level] = {
        Level = level,
        ExpToNext = expToNext,
        TotalExp = total,
    }

    total += expToNext
end

local UpgradeCost = {}

local MAX_UPGRADE_LEVEL = 20
local BASE_COST = 120

for level = 1, MAX_UPGRADE_LEVEL do
    local cost = math.floor(BASE_COST * (level ^ 2.2) + level * 150)

    UpgradeCost[level] = {
        Level = level,
        Gold = cost,
    }
end

local PowerScoreWeights = {
    Level = 5,
    TotalEquipmentLevel = 20,
    Rebirth = 150,
    TotalStats = 2,
    TotalPetsLevel = 3,
    TotalSkillsLearned = 10,
}

return {
    LevelExp = LevelExp,
    UpgradeCost = UpgradeCost,
    PowerScoreWeights = PowerScoreWeights,
}
