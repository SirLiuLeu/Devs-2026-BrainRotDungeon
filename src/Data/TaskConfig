local TaskConfig = {
    KillMonster_10 = {
        Type = "Daily",
        Category = "Combat",

        Objective = {
            Event = "KillMonster",
            Target = "Any",
            Count = 10,
        },

        Rewards = {
            Gold = 500,
            Exp = 200,
            Bone = 5,
            Item = "Potion_HP_Small",
        },

        Reset = "Daily",
    },

    KillBoss_1 = {
        Type = "Daily",
        Category = "Combat",

        Objective = {
            Event = "KillBoss",
            Count = 1,
        },

        Rewards = {
            Gold = 1000,
            Exp = 500,
            Item = "Armor_Rare",
        },

        Reset = "Daily",
    },

    DealDamage_100k = {
        Type = "Weekly",
        Category = "Combat",

        Objective = {
            Event = "DealDamage",
            Count = 100000,
        },

        Rewards = {
            Gold = 2000,
            Exp = 1000,
            Item = "Sword_Uncommon",
        },

        Reset = "Weekly",
    },

    Story_Chapter1 = {
        Type = "Story",
        Category = "Progress",

        Objective = {
            Event = "EnterRoom",
            Room = 104,
        },

        Rewards = {
            Gold = 1000,
            Exp = 500,
            Bone = 10,
        },

        Reset = "Never",
    },
}

local PlayerTasks = {
    Progress = {
        KillMonster_10 = 4,
        KillBoss_1 = 0,
        DealDamage_100k = 52000,
        Story_Chapter1 = 1,
    },

    Claimed = {
        KillMonster_10 = false,
        KillBoss_1 = false,
        DealDamage_100k = false,
        Story_Chapter1 = true,
    },

    ResetTime = {
        Daily = 1707206400,
        Weekly = 1707260000,
    },
}

return {
    TaskConfig = TaskConfig,
    PlayerTasks = PlayerTasks,
}
