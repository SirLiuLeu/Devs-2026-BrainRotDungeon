-- ReplicatedStorage/Config/Enemies

EnemyConfig = {
    Id = "Brainrot",

    Stats = {
        HP = number,
        Damage = number,
        AttackRange = number,
        Cooldown = number,
        AttackType = "SingleTarget" | "AOE"
    },

    Rewards = {
        Exp = number,
        Gold = number,
        BoneChance = number,
        DropTable = "BrainrotBasic"
    }
}


