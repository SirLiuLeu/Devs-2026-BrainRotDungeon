local Monsters = {
    Default = {
        MaxHP = 100,
        Damage = 10,
        Defense = 0,
        AttackRange = 5,
        AggroRange = 25,
        AttackCooldown = 1,
        Rewards = {
            Exp = 30,
            Gold = 15,
        },
    },
    Slime = {
        MaxHP = 80,
        Damage = 6,
        AttackRange = 4,
        AggroRange = 20,
        Rewards = {
            Exp = 20,
            Gold = 10,
        },
    },
    Skeleton = {
        MaxHP = 140,
        Damage = 14,
        AttackRange = 6,
        AggroRange = 30,
        Rewards = {
            Exp = 45,
            Gold = 25,
        },
    },
    DesignCatalog = {
        Brainrot = {
            Id = "Brainrot",
            Type = "Normal",
            Stats = {
                HP = 120,
                Damage = 8,
                AttackRange = 6,
                Cooldown = 1,
                AttackType = "SingleTarget",
            },
            Rewards = {
                Exp = 20,
                Gold = 25,
                BoneChance = 0.05,
                DropTable = "BrainrotBasic",
            },
        },
        EliteBrainrot = {
            Id = "EliteBrainrot",
            Type = "Elite",
            Stats = {
                HP = 450,
                Damage = 22,
                AttackRange = 8,
                Cooldown = 1.2,
                AttackType = "SingleTarget",
            },
            Rewards = {
                Exp = 120,
                Gold = 140,
                BoneChance = 0.3,
                DropTable = "BrainrotElite",
            },
        },
        BossBrainrot = {
            Id = "BossBrainrot",
            Type = "Boss",
            Stats = {
                HP = 2500,
                Damage = 40,
                AttackRange = 12,
                Cooldown = 2.5,
                AttackType = "AOE",
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
    },
}

return Monsters
