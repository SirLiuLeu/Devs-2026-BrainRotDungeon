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

return {
    UpgradeCost = UpgradeCost,
    PowerScoreWeights = PowerScoreWeights,
}