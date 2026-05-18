import Foundation

enum PetState: String, Codable, CaseIterable {
    case normal = "正常"
    case happy = "开心"
    case sad = "难过"
    case hungry = "饥饿"
    case dizzy = "饿晕"
    case sleeping = "睡觉"
    case exercising = "运动中"
}

struct Pet: Codable {
    var name: String
    var state: PetState
    var calories: Int
    var lastFeedTime: Date?
    var lastExerciseTime: Date?
    var createdAt: Date
    
    // 饿晕相关统计
    var dizzyCount: Int
    var consecutiveDizzyDays: Int
    var lastDizzyDate: Date?
    var dizzyHistory: [Date]
    
    // 成就相关
    var unlockedAchievements: [String]
    
    init(name: String = "小卡") {
        self.name = name
        self.state = .normal
        self.calories = 500
        self.createdAt = Date()
        self.dizzyCount = 0
        self.consecutiveDizzyDays = 0
        self.dizzyHistory = []
        self.unlockedAchievements = []
    }
    
    // 检查是否饿晕（每天22点后卡路里<200触发）
    mutating func checkDizzyState() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        // 22点后检查
        if hour >= 22 && calories < 200 {
            if state != .dizzy {
                state = .dizzy
                recordDizzy()
            }
        }
    }
    
    mutating private func recordDizzy() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // 避免同一天重复记录
        if let lastDizzy = lastDizzyDate,
           Calendar.current.isDate(lastDizzy, inSameDayAs: today) {
            return
        }
        
        dizzyCount += 1
        dizzyHistory.append(today)
        lastDizzyDate = today
        
        // 计算连续饿晕天数
        if let lastDizzy = lastDizzyDate {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            if Calendar.current.isDate(lastDizzy, inSameDayAs: yesterday) {
                consecutiveDizzyDays += 1
            } else {
                consecutiveDizzyDays = 1
            }
        } else {
            consecutiveDizzyDays = 1
        }
    }
    
    // 恢复运动（饿晕后）
    mutating func recoverFromDizzy() {
        if state == .dizzy {
            state = .normal
            // 恢复后解锁"绝地重生"成就
            if !unlockedAchievements.contains("绝地重生") {
                unlockedAchievements.append("绝地重生")
            }
        }
    }
    
    // 喂食
    mutating func feed(calories amount: Int) {
        calories += amount
        if calories > 1000 {
            calories = 1000
        }
        lastFeedTime = Date()
        
        // 如果饿晕状态，喂食后恢复正常
        if state == .dizzy && calories >= 200 {
            state = .normal
        }
    }
    
    // 运动消耗
    mutating func exercise(calories amount: Int) {
        calories -= amount
        if calories < 0 {
            calories = 0
        }
        lastExerciseTime = Date()
        
        // 饿晕后恢复运动
        if state == .dizzy {
            recoverFromDizzy()
        }
    }
}
