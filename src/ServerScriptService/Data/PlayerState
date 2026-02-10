-- No save data, runtime only

local PlayerState = {
    FinalStats = {
        MaxHP = "number",
        Damage = "number",
        Defense = "number",
        MoveSpeed = "number",
    },

    Multipliers = {
        Exp = "number",
        Gold = "number",
        Bone = "number",
        Luck = "number",
    },

    Cooldowns = {
        Attack = "number",
        Skills = { ["SkillId"] = "timestamp" },
    },

    Combat = {
        Target = "EnemyId?",
        InCombat = "boolean",
        LastAttackTime = "number",
    },

    AutoFarm = {
        Enabled = "boolean",
        CurrentTarget = "EnemyId?",
    },
}

local BossFight = {
    BossId = "string",
    DamageByPlayer = {
        ["UserId"] = "number",
    },
    LastHit = "UserId",
}

return {
    PlayerState = PlayerState,
    BossFight = BossFight,
}
