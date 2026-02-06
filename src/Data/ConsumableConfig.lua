local ConsumableConfig = {
    Potion_HP_Small = {
        Type = "Potion",
        Effect = "Heal",
        Value = 0.3, -- 30% HP
        Cooldown = 10,
        Rarity = "Common",
        Price = { Gold = 150 },
    },

    Potion_HP_Medium = {
        Type = "Potion",
        Effect = "Heal",
        Value = 0.5, -- 50% HP
        Cooldown = 10,
        Rarity = "Uncommon",
        Price = { Gold = 350 },
    },

    Potion_Exp = {
        Type = "Potion",
        Effect = "ExpBoost",
        Value = 0.5, -- 50% exp
        Duration = 600,
        Rarity = "Rare",
        Price = { Gold = 800 },
    },

    Potion_Damage = {
        Type = "Potion",
        Effect = "DamageBoost",
        Value = 0.3, -- 30% damage
        Duration = 600,
        Rarity = "Rare",
        Price = { Gold = 800 },
    },
}

return ConsumableConfig
