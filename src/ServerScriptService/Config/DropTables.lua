local DropTables = {
    BrainrotBasic = {
        Rolls = 1,
        Items = {
            { Item = "Bone", Chance = 0.05 },
            { Item = "Potion_HP_Small", Chance = 0.02 },
            { Item = "Sword_Common", Chance = 0.01 },
        },
        Pity = {
            Enabled = true,
            MaxStacks = 80,
            BonusPerFail = 0.005,
            GuaranteedAt = 80,
        },
    },
    BrainrotElite = {
        Rolls = 1,
        Items = {
            { Item = "Bone", Chance = 0.2 },
            { Item = "Potion_HP_Medium", Chance = 0.08 },
            { Item = "Sword_Uncommon", Chance = 0.03 },
            { Item = "Armor_Rare", Chance = 0.02 },
        },
        Pity = {
            Enabled = true,
            MaxStacks = 60,
            BonusPerFail = 0.01,
            GuaranteedAt = 60,
        },
    },
    BrainrotBoss = {
        Rolls = 2,
        Items = {
            { Item = "Bone", Chance = 1.0 },
            { Item = "Potion_Damage", Chance = 0.25 },
            { Item = "Sword_Rare", Chance = 0.1 },
            { Item = "Staff_Epic", Chance = 0.05 },
        },
        Pity = {
            Enabled = true,
            MaxStacks = 40,
            BonusPerFail = 0.02,
            GuaranteedAt = 40,
        },
    },
}

return DropTables
