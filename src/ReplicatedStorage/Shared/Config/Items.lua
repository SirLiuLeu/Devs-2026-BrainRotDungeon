local Items = {
    Equipment = {
        Sword_Starter = {
            Slot = "Weapon",
            SubType = "Sword",
            Rarity = "Common",
            LevelReq = 1,
            BaseStats = {
                Damage = 10,
            },
            Growth = {
                Damage = 1.12,
            },
            AttackProfile = "Melee_Single",
            Tags = { "Melee" },
        },
        Sword_Common = {
            Slot = "Weapon",
            SubType = "Sword",
            Rarity = "Common",
            LevelReq = 3,
            BaseStats = {
                Damage = 12,
            },
            Growth = {
                Damage = 1.13,
            },
            AttackProfile = "Melee_Single",
            Tags = { "Melee" },
        },
        Sword_Uncommon = {
            Slot = "Weapon",
            SubType = "Sword",
            Rarity = "Uncommon",
            LevelReq = 7,
            BaseStats = {
                Damage = 16,
            },
            Growth = {
                Damage = 1.14,
            },
            AttackProfile = "Melee_Single",
            Tags = { "Melee" },
        },
        Sword_Rare = {
            Slot = "Weapon",
            SubType = "Sword",
            Rarity = "Rare",
            LevelReq = 12,
            BaseStats = {
                Damage = 22,
            },
            Growth = {
                Damage = 1.16,
            },
            AttackProfile = "Melee_Single",
            Tags = { "Melee" },
        },
        Bow_Wood = {
            Slot = "Weapon",
            SubType = "Bow",
            Rarity = "Common",
            LevelReq = 5,
            BaseStats = {
                Damage = 8,
                AttackRange = 40,
            },
            Growth = {
                Damage = 1.10,
            },
            AttackProfile = "Projectile_Single",
            Tags = { "Ranged" },
        },
        Staff_Epic = {
            Slot = "Weapon",
            SubType = "Staff",
            Rarity = "Epic",
            LevelReq = 20,
            BaseStats = {
                Damage = 30,
                Mana = 30,
            },
            Growth = {
                Damage = 1.18,
            },
            AttackProfile = "Magic_AOE",
            Tags = { "Magic" },
        },
        DragonBlade = {
            Slot = "Weapon",
            SubType = "Sword",
            Rarity = "Legendary",
            LevelReq = 30,
            BaseStats = {
                Damage = 45,
                LifestealPercent = 0.01,
            },
            Growth = {
                Damage = 1.2,
            },
            AttackProfile = "Melee_Single",
            Tags = { "Melee", "Boss" },
        },
        Helmet_Common = {
            Slot = "Armor",
            SubType = "Helmet",
            Rarity = "Common",
            LevelReq = 4,
            BaseStats = {
                HP = 40,
                Defense = 3,
            },
            Growth = {
                HP = 1.16,
            },
        },
        Armor_Rare = {
            Slot = "Armor",
            SubType = "Chest",
            Rarity = "Rare",
            LevelReq = 14,
            BaseStats = {
                HP = 120,
                Defense = 8,
            },
            Growth = {
                HP = 1.2,
            },
        },
        Ring_Luck = {
            Slot = "Accessory",
            SubType = "Ring",
            Rarity = "Rare",
            LevelReq = 8,
            BaseStats = {
                Luck = 0.05,
            },
        },
    },
    Consumables = {
        Potion_HP_Small = {
            Type = "Potion",
            Effect = "Heal",
            Value = 0.3,
            Cooldown = 10,
            Rarity = "Common",
            Price = { Gold = 150 },
        },
        Potion_HP_Medium = {
            Type = "Potion",
            Effect = "Heal",
            Value = 0.5,
            Cooldown = 10,
            Rarity = "Uncommon",
            Price = { Gold = 350 },
        },
        Potion_Exp = {
            Type = "Potion",
            Effect = "ExpBoost",
            Value = 0.5,
            Duration = 600,
            Rarity = "Rare",
            Price = { Gold = 800 },
        },
        Potion_Damage = {
            Type = "Potion",
            Effect = "DamageBoost",
            Value = 0.3,
            Duration = 600,
            Rarity = "Rare",
            Price = { Gold = 800 },
        },
    },
    Gacha = {
        Standard = {
            Currency = "Bone",
            Cost = 100,
            Rolls = 1,
            Pools = {
                Common = 0.7,
                Uncommon = 0.2,
                Rare = 0.08,
                Epic = 0.018,
                Legendary = 0.002,
            },
            Pity = {
                Enabled = true,
                Counter = "Legendary",
                Soft = {
                    Start = 50,
                    BonusPerRoll = 0.002,
                },
                Hard = 80,
            },
            Items = {
                Common = {
                    { Id = "Sword_Common", Type = "Equipment" },
                    { Id = "Helmet_Common", Type = "Equipment" },
                    { Id = "Potion_HP_Small", Type = "Consumable" },
                },
                Uncommon = {
                    { Id = "Sword_Uncommon", Type = "Equipment" },
                    { Id = "Potion_HP_Medium", Type = "Consumable" },
                },
                Rare = {
                    { Id = "Sword_Rare", Type = "Equipment" },
                    { Id = "Armor_Rare", Type = "Equipment" },
                },
                Epic = {
                    { Id = "Staff_Epic", Type = "Equipment" },
                },
                Legendary = {
                    { Id = "DragonBlade", Type = "Equipment" },
                },
            },
        },
    },
}

return Items
