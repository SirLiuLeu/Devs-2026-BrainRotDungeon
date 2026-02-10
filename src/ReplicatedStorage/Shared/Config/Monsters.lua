local SourceMonsters = {
    Default = {
        Type = "Normal",
        Stats = {
            HP = 100,
            Damage = 10,
            AttackRange = 5,
            Cooldown = 1,
            AttackType = "SingleTarget",
            AggroRange = 25,
        },
        Rewards = {
            Exp = 30,
            Gold = 15,
            BoneChance = 0,
            DropTable = nil,
        },
    },
    Slime = {
        Type = "Normal",
        Stats = {
            HP = 80,
            Damage = 6,
            AttackRange = 4,
            Cooldown = 1,
            AttackType = "SingleTarget",
            AggroRange = 20,
        },
        Rewards = {
            Exp = 20,
            Gold = 10,
            BoneChance = 0,
            DropTable = nil,
        },
    },
    Skeleton = {
        Type = "Normal",
        Stats = {
            HP = 140,
            Damage = 14,
            AttackRange = 6,
            Cooldown = 1,
            AttackType = "SingleTarget",
            AggroRange = 30,
        },
        Rewards = {
            Exp = 45,
            Gold = 25,
            BoneChance = 0,
            DropTable = nil,
        },
    },
    Brainrot = {
        Type = "Normal",
        Stats = {
            HP = 120,
            Damage = 8,
            AttackRange = 6,
            Cooldown = 1,
            AttackType = "SingleTarget",
            AggroRange = 25,
        },
        Rewards = {
            Exp = 20,
            Gold = 25,
            BoneChance = 0.05,
            DropTable = "BrainrotBasic",
        },
    },
    EliteBrainrot = {
        Type = "Elite",
        Stats = {
            HP = 450,
            Damage = 22,
            AttackRange = 8,
            Cooldown = 1.2,
            AttackType = "SingleTarget",
            AggroRange = 28,
        },
        Rewards = {
            Exp = 120,
            Gold = 140,
            BoneChance = 0.3,
            DropTable = "BrainrotElite",
        },
    },
    BossBrainrot = {
        Type = "Boss",
        Stats = {
            HP = 2500,
            Damage = 40,
            AttackRange = 12,
            Cooldown = 2.5,
            AttackType = "AOE",
            AggroRange = 35,
        },
        Rewards = {
            Exp = 700,
            Gold = 900,
            BoneChance = 1.0,
            DropTable = "BrainrotBoss",
            LastHitBonePercent = 0.3,
            DamageContributionPercent = 0.7,
        },
    },
}

local function normalizeMonsterConfig(id, raw)
    local rawStats = raw.Stats or raw
    local rawRewards = raw.Rewards or {}

    return {
        Id = id,
        Type = raw.Type or "Normal",
        Level = raw.Level,
        Stats = {
            HP = rawStats.HP or rawStats.MaxHP or 100,
            Damage = rawStats.Damage or 0,
            AttackRange = rawStats.AttackRange or rawStats.Range or 5,
            Cooldown = rawStats.Cooldown or rawStats.AttackCooldown or 1,
            AttackType = rawStats.AttackType or "SingleTarget",
            AggroRange = rawStats.AggroRange,
        },
        Rewards = {
            Exp = rawRewards.Exp or 0,
            Gold = rawRewards.Gold or 0,
            BoneChance = rawRewards.BoneChance or 0,
            DropTable = rawRewards.DropTable,
            LastHitBonePercent = rawRewards.LastHitBonePercent,
            DamageContributionPercent = rawRewards.DamageContributionPercent,
        },
    }
end

local Monsters = {}
for id, raw in pairs(SourceMonsters) do
    Monsters[id] = normalizeMonsterConfig(id, raw)
end

function Monsters.GetById(id)
    if type(id) ~= "string" then
        return nil
    end
    return Monsters[id]
end

return Monsters
