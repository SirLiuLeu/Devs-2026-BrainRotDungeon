local Monsters = {
    Default = {
        MaxHP = 100,
        Damage = 10,
        Defense = 0,
        AttackRange = 5,
        AggroRange = 25,
        AttackCooldown = 1,
        Rewards = {
            Exp = 20,
            Gold = 10,
        },
    },
    SlimeBrainrot = {
        MaxHP = 80,
        Damage = 6,
        Defense = 0,
        AttackRange = 4,
        AggroRange = 20,
        AttackCooldown = 1.2,
        Rewards = {
            Exp = 15,
            Gold = 8,
            Bone = 1,
        },
    },
    FastBrainrot = {
        MaxHP = 60,
        Damage = 5,
        Defense = 0,
        AttackRange = 4,
        AggroRange = 28,
        AttackCooldown = 0.6,
        Rewards = {
            Exp = 18,
            Gold = 9,
            Bone = 1,
        },
    },
    TankBrainrot = {
        MaxHP = 200,
        Damage = 12,
        Defense = 2,
        AttackRange = 5,
        AggroRange = 22,
        AttackCooldown = 1.6,
        Rewards = {
            Exp = 30,
            Gold = 18,
            Bone = 2,
        },
    },
    ShooterBrainrot = {
        MaxHP = 90,
        Damage = 9,
        Defense = 1,
        AttackRange = 8,
        AggroRange = 30,
        AttackCooldown = 1.4,
        Rewards = {
            Exp = 22,
            Gold = 12,
            Bone = 1,
        },
    },
}

return Monsters
