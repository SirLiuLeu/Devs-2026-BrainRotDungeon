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

return {
    LevelExp = LevelExp,
}