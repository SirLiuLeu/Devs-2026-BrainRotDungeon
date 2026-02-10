local ServerScriptService = game:GetService("ServerScriptService")

local DropTables = require(ServerScriptService.Config.DropTables)

local DropResolver = {}

local function getWeight(entry)
	if entry.Weight then
		return math.max(0, entry.Weight)
	end
	if entry.Chance then
		return math.max(0, entry.Chance)
	end
	return 0
end

local function buildRollCount(baseRolls, rollMultiplier)
	local rolls = baseRolls or 1
	local multiplier = rollMultiplier or 1
	if multiplier <= 0 then
		return 0
	end
	local total = rolls * multiplier
	local whole = math.floor(total)
	local remainder = total - whole
	if math.random() < remainder then
		whole += 1
	end
	return whole
end

local function selectWeighted(items)
	local totalWeight = 0
	local usesWeighted = false
	for _, entry in ipairs(items) do
		local weight = getWeight(entry)
		if weight > 0 then
			totalWeight += weight
			if weight > 1 then
				usesWeighted = true
			end
		end
	end

	local noDropWeight = 0
	if not usesWeighted and totalWeight > 0 and totalWeight < 1 then
		noDropWeight = 1 - totalWeight
		totalWeight += noDropWeight
	end

	if totalWeight <= 0 then
		return nil
	end

	local roll = math.random() * totalWeight
	local running = 0
	for _, entry in ipairs(items) do
		local weight = getWeight(entry)
		if weight > 0 then
			running += weight
			if roll <= running then
				return entry
			end
		end
	end

	if noDropWeight > 0 and roll <= totalWeight then
		return nil
	end

	return nil
end

function DropResolver.Resolve(dropTableId, options)
	local dropTable = DropTables[dropTableId]
	if not dropTable then
		return {}
	end

	local results = {}
	local items = dropTable.Items or {}
	local rolls = buildRollCount(dropTable.Rolls, options and options.RollMultiplier)
	for _ = 1, rolls do
		local entry = selectWeighted(items)
		if entry and entry.Item then
			table.insert(results, {
				ItemId = entry.Item,
				Type = entry.Type,
				Rarity = entry.Rarity,
			})
		end
	end

	return results
end

return DropResolver
