local MonsterConfig = {
    Default = {
        MaxHP = 100,
        Damage = 10,
        AttackRange = 5,
        AggroRange = 25,
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
}

return MonsterConfig
