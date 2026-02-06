-- Config = game design (static)
-- Profile = save file (persistent)
-- State = runtime (session only)

ItemData = {
    UID = string,
    ItemId = string,
    Level = number,
    Star = number,
    Rarity = string,

    RandomStats = {
        { Damage = 12.5 },
        { GoldPercent = 8 },
    }
}

PetConfig = {
    Wolf = {
        Rarity = "Common",
        UID = string,
        PetId = string,
        Star = number,
        Stats = {
            Damage = { Base = 5, Growth = 1.12 }
        },
        Skills = { "Bite" }
    },
    SlimeGold = {
        UID = string,
        PetId = string,
        Star = number,
        Rarity = "Common",
        Stats = {
            GoldBonus = { Base = 0.05, Growth = 1.06 }
        }
    },
    FairyExp = {
        UID = string,
        PetId = string,
        Star = number,
        Rarity = "Rare",
        Stats = {
            ExpBonus = { Base = 0.04, Growth = 1.07 }
        }
    }
}

PlayerProfile = {
    Identity = {
        UserId = number,
        JoinDate = number,
        TotalPlayTime = number,
    },
    Progression = {
        Level = number,
        Exp = number,
        Rebirth = number, -- times rebirthed inrealese %5 gold
        StatPoints = number,
        AllocatedStats = {
            Strength = number,
            Vitality = number,
            Agility = number,
        }
    },
    Currency = {
        Gold = number,
        Bone = number,
        Premium = number,
    },
    Equipment = {
        Weapon = ItemUID?,
        Armor = ItemUID?,
        Accessory = ItemUID?,
    },
    Inventory = {
        Items = { [ItemUID] = ItemData },
        Capacity = number,
    },
    Skills = {
        Active = SkillId?,
        Passive = SkillId?,
        Learned = { [SkillId] = SkillLevel }
    },
    Pet = {
        Equipped = PetUID?,
        Pets = { [PetUID] = PetData }
    },
    Quest = {
        DailyProgress = { [QuestId] = number },
        StoryProgress = number,
        Timers = { [QuestId] = timestamp }
    },
    Statistics = {
        TotalKills = number,
        BossKills = number,
        TotalDamage = number,
    },
    PlayerState = {
        FinalStats = {},
        Cooldowns = {},
        ActiveBuffs = {},
        InCombat = false,
        Target = Monster?,
        LastAttackTime = number
    }
}


DropTable = {
    Rolls = 1,

    Items = {
        { Item = "Bone", Chance = 0.05 },
        { Item = "PotionHP", Chance = 0.02},
        { Item = "Sword_Common", Chance = 0.01},
    },
    Pity = {
        Enabled = true,
        MaxStacks = 80,
        BonusPerFail = 0.005,
        GuaranteedAt = 80
    }
}

SkillConfig = {
   SkillE = { Id = "Dash",
        Type = "Active",

        Cooldown = 5,
        BoneCost = 10,

        Effects = {
            DashDistance = 25,
            InvincibleTime = 0.3
        }
    },
    SkillQ = { Id = "Fireball",
          Type = "Active",
          Cooldown = 8,
          BoneCost = 15,
    
          Effects = {
                Damage = 50,
                AreaRadius = 5
          }
     }
}


