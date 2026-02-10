local LevelExp = require(script.Parent.LevelExp).LevelExp

local BASE_STATS = {
	MaxHP = 100,
	Damage = 5,
	Defense = 0,
	MoveSpeed = 16,
}

local GROWTH_PER_LEVEL = {
	MaxHP = 20,
	Damage = 2,
	Defense = 1,
	MoveSpeed = 0,
}

local Progression = {}

local function applyRebirthHooks(levelConfig, rebirth)
	-- Migration hook: keep base scaling, but attach rebirth context for future tuning.
	if rebirth and rebirth > 0 then
		levelConfig.Rebirth = rebirth
	end
	return levelConfig
end

function Progression.GetLevelConfig(level, rebirth)
	local expEntry = LevelExp[level]
	if not expEntry then
		return nil
	end

	local levelIndex = math.max(1, level)
	local levelConfig = {
		ExpToNext = expEntry.ExpToNext,
		MaxHP = BASE_STATS.MaxHP + (levelIndex - 1) * GROWTH_PER_LEVEL.MaxHP,
		Damage = BASE_STATS.Damage + (levelIndex - 1) * GROWTH_PER_LEVEL.Damage,
		Defense = BASE_STATS.Defense + (levelIndex - 1) * GROWTH_PER_LEVEL.Defense,
		MoveSpeed = BASE_STATS.MoveSpeed + (levelIndex - 1) * GROWTH_PER_LEVEL.MoveSpeed,
	}

	return applyRebirthHooks(levelConfig, rebirth)
end

Progression.Levels = setmetatable({}, {
	__index = function(_, level)
		return Progression.GetLevelConfig(level, 0)
	end,
})

return Progression
