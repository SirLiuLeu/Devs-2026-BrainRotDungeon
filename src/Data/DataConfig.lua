-- Config = game design (static)
-- Profile = save file (persistent)
-- State = runtime (session only)

local DataConfig = {
    Rules = {
        ExpGoldLevelRange = 10, -- +- level range for exp/gold rewards
        RebirthGoldBonus = 0.05, -- +5% gold per rebirth
        AutoFarm = {
            UseBasicAttackOnly = true,
            UseSkills = false,
        }
    },

    Currency = {
        Gold = { Id = "Gold" },
        Bone = { Id = "Bone" },
        Premium = { Id = "Premium" },
    },

    Rarity = {
        Common = { Tier = 1, RandomStatCount = 1 },
        Uncommon = { Tier = 2, RandomStatCount = 2 },
        Rare = { Tier = 3, RandomStatCount = 3 },
        Epic = { Tier = 4, RandomStatCount = 4 },
        Legendary = { Tier = 5, RandomStatCount = 5 },
        Mythic = { Tier = 6, RandomStatCount = 5, BonusEffects = { "LifestealPercent" } },
        Secret = { Tier = 7, RandomStatCount = 5, BonusEffects = { "LifestealPercent", "LuckyDropPercent" } },
    },

    RandomStatPool = {
        "ExpPercent",
        "DamageFlat",
        "DamagePercent",
        "GoldPercent",
        "ArmorFlat",
        "ReflectPercent",
        "HPFlat",
        "LifestealPercent",
        "HPRegenFlat",
        "MoveSpeedPercent",
        "HealPerSecond",
        "LuckyDropPercent",
        "CritChancePercent",
        "CritDamagePercent",
        "AttackSpeedPercent",
        "SkillDamagePercent",
        "GoldOnKill",
        "BoneOnKill",
    },

    EquipmentSlots = {
        Weapon = { "Sword", "Bow", "Staff" },
        Armor = { "Helmet", "Chest", "Pants" },
        Accessory = { "Ring", "Necklace" },
    },

    AttackProfiles = {
        Melee_Single = { Range = 6, Targeting = "SingleTarget" },
        Projectile_Single = { Range = 40, Targeting = "SingleTarget" },
        Magic_AOE = { Range = 30, Targeting = "AOE" },
    },

    Schemas = {
        ItemData = {
            UID = "string",
            ItemId = "string",
            Level = "number",
            Star = "number",
            Rarity = "string",
            RandomStats = { { Damage = 12.5 }, { GoldPercent = 8 } },
        },

        PlayerProfile = {
            Identity = {
                UserId = "number",
                JoinDate = "number",
                TotalPlayTime = "number",
            },
            Progression = {
                Level = "number",
                Exp = "number",
                Rebirth = "number",
                StatPoints = "number",
                AllocatedStats = {
                    Strength = "number",
                    Vitality = "number",
                    Agility = "number",
                },
            },
            Currency = {
                Gold = "number",
                Bone = "number",
                Premium = "number",
            },
            Equipment = {
                Weapon = "ItemUID?",
                Armor = "ItemUID?",
                Accessory = "ItemUID?",
            },
            Inventory = {
                Items = { ["ItemUID"] = "ItemData" },
                Capacity = "number",
            },
            Skills = {
                Active = "SkillId?",
                Passive = "SkillId?",
                Learned = { ["SkillId"] = "SkillLevel" },
            },
            Pet = {
                Equipped = "PetUID?",
                Pets = { ["PetUID"] = "PetData" },
            },
            Quest = {
                DailyProgress = { ["QuestId"] = "number" },
                StoryProgress = "number",
                Timers = { ["QuestId"] = "timestamp" },
            },
            Statistics = {
                TotalKills = "number",
                BossKills = "number",
                TotalDamage = "number",
            },
        },
    },
}

return DataConfig
