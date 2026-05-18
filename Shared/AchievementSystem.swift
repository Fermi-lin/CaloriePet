import Foundation

struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}

class AchievementSystem {
    let pet: Pet
    
    init(pet: Pet) {
        self.pet = pet
    }
    
    func checkAchievements() -> [Achievement] {
        var achievements: [Achievement] = []
        
        // 累计饿晕成就
        achievements.append(checkFirstDizzy())
        achievements.append(checkCouchPotato())
        achievements.append(checkLyingMaster())
        achievements.append(checkWasteExpert())
        achievements.append(checkUltimateLying())
        
        // 连续饿晕成就
        achievements.append(checkThreeDayFaint())
        achievements.append(checkComaWeek())
        
        // 饿晕后恢复成就
        achievements.append(checkRebirth())
        
        return achievements.filter { $0.isUnlocked }
    }
    
    // MARK: - 累计饿晕成就
    
    // 初次饿晕
    private func checkFirstDizzy() -> Achievement {
        Achievement(
            id: "初次饿晕",
            name: "初次饿晕",
            description: "第一次饿晕",
            icon: "😵",
            isUnlocked: pet.dizzyCount >= 1
        )
    }
    
    // 沙发土豆 (3次饿晕)
    private func checkCouchPotato() -> Achievement {
        Achievement(
            id: "沙发土豆",
            name: "沙发土豆",
            description: "累计饿晕3次",
            icon: "🛋️",
            isUnlocked: pet.dizzyCount >= 3
        )
    }
    
    // 躺平大师 (7次饿晕)
    private func checkLyingMaster() -> Achievement {
        Achievement(
            id: "躺平大师",
            name: "躺平大师",
            description: "累计饿晕7次",
            icon: "🛌",
            isUnlocked: pet.dizzyCount >= 7
        )
    }
    
    // 废柴达人 (15次饿晕)
    private func checkWasteExpert() -> Achievement {
        Achievement(
            id: "废柴达人",
            name: "废柴达人",
            description: "累计饿晕15次",
            icon: "🥀",
            isUnlocked: pet.dizzyCount >= 15
        )
    }
    
    // 终极躺平 (30次饿晕)
    private func checkUltimateLying() -> Achievement {
        Achievement(
            id: "终极躺平",
            name: "终极躺平",
            description: "累计饿晕30次",
            icon: "👑",
            isUnlocked: pet.dizzyCount >= 30
        )
    }
    
    // MARK: - 连续饿晕成就
    
    // 三日昏厥 (连续3天饿晕)
    private func checkThreeDayFaint() -> Achievement {
        Achievement(
            id: "三日昏厥",
            name: "三日昏厥",
            description: "连续3天饿晕",
            icon: "💫",
            isUnlocked: pet.consecutiveDizzyDays >= 3
        )
    }
    
    // 昏迷周 (连续7天饿晕)
    private func checkComaWeek() -> Achievement {
        Achievement(
            id: "昏迷周",
            name: "昏迷周",
            description: "连续7天饿晕",
            icon: "🏥",
            isUnlocked: pet.consecutiveDizzyDays >= 7
        )
    }
    
    // MARK: - 饿晕后恢复成就
    
    // 绝地重生 (饿晕后恢复运动)
    private func checkRebirth() -> Achievement {
        Achievement(
            id: "绝地重生",
            name: "绝地重生",
            description: "饿晕后恢复运动",
            icon: "🔥",
            isUnlocked: pet.unlockedAchievements.contains("绝地重生")
        )
    }
}

// 成就展示数据
extension AchievementSystem {
    static let allAchievements: [Achievement] = [
        Achievement(id: "初次饿晕", name: "初次饿晕", description: "第一次饿晕", icon: "😵", isUnlocked: false),
        Achievement(id: "沙发土豆", name: "沙发土豆", description: "累计饿晕3次", icon: "🛋️", isUnlocked: false),
        Achievement(id: "躺平大师", name: "躺平大师", description: "累计饿晕7次", icon: "🛌", isUnlocked: false),
        Achievement(id: "废柴达人", name: "废柴达人", description: "累计饿晕15次", icon: "🥀", isUnlocked: false),
        Achievement(id: "终极躺平", name: "终极躺平", description: "累计饿晕30次", icon: "👑", isUnlocked: false),
        Achievement(id: "三日昏厥", name: "三日昏厥", description: "连续3天饿晕", icon: "💫", isUnlocked: false),
        Achievement(id: "昏迷周", name: "昏迷周", description: "连续7天饿晕", icon: "🏥", isUnlocked: false),
        Achievement(id: "绝地重生", name: "绝地重生", description: "饿晕后恢复运动", icon: "🔥", isUnlocked: false)
    ]
}
