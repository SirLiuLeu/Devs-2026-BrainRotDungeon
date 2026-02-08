local Skills = {
    Basic = {
        DamagePercent = 1.0,
        Range = 20,
        Cooldown = 0.2,
        EffectType = "Damage",
        Targeting = "AOE",
    },
    SkillE = {
        DamagePercent = 1.35,
        Range = 20,
        Cooldown = 1,
        EffectType = "Damage",
        Targeting = "AOE",
    },
    SkillR = {
        DamagePercent = 1.8,
        Range = 24,
        Cooldown = 3.5,
        EffectType = "Damage",
        Targeting = "AOE",
    },
    HealPulse = {
        HealPercent = 0.25,
        Cooldown = 6,
        EffectType = "Heal",
        Targeting = "Self",
    },
    BuffGuard = {
        Cooldown = 10,
        Duration = 6,
        EffectType = "Buff",
        Targeting = "Self",
        BuffStats = {
            Defense = 5,
        },
    },
    DebuffSlow = {
        Range = 18,
        Cooldown = 8,
        Duration = 4,
        EffectType = "Debuff",
        Targeting = "AOE",
        DebuffMoveSpeedMultiplier = 0.6,
    },
    StunStrike = {
        Range = 10,
        Cooldown = 12,
        Duration = 2,
        EffectType = "Stun",
        Targeting = "Single",
    },
    DashStep = {
        Cooldown = 5,
        EffectType = "Dash",
        Targeting = "Self",
        DashDistance = 18,
    },
    PassiveFortitude = {
        EffectType = "Passive",
        Targeting = "Self",
        BuffStats = {
            MaxHP = 25,
        },
    },
}

return Skills
