//
//  Pet.swift
//  CaloriePet
//
//  文件作用：定义宠物数据模型，包含宠物的所有属性、状态、外观和家族系统
//  包括：名称、等级、经验值、状态、10个宠物家族、随机孵化逻辑
//  支持 Codable 协议用于数据持久化存储
//

import Foundation

// MARK: - 宠物状态枚举

/// 宠物状态枚举
enum PetState: String, Codable, CaseIterable {
    case happy = "happy"
    case normal = "normal"
    case hungry = "hungry"

    var displayName: String {
        switch self {
        case .happy: return "开心"
        case .normal: return "普通"
        case .hungry: return "饿了"
        }
    }

    var colorHex: String {
        switch self {
        case .happy: return "#4CAF50"
        case .normal: return "#FFC107"
        case .hungry: return "#F44336"
        }
    }
}

// MARK: - 宠物等级枚举

/// 宠物等级枚举
enum PetLevel: Int, Codable, CaseIterable {
    case level1 = 1
    case level2 = 2
    case level3 = 3

    var displayName: String {
        switch self {
        case .level1: return "Lv.1 幼年期"
        case .level2: return "Lv.2 成长期"
        case .level3: return "Lv.3 完全体"
        }
    }

    var requiredXPForNextLevel: Int {
        switch self {
        case .level1: return 10000
        case .level2: return 30000
        case .level3: return 0
        }
    }

    var nextLevel: PetLevel? {
        switch self {
        case .level1: return .level2
        case .level2: return .level3
        case .level3: return nil
        }
    }
}

// MARK: - 宠物家族（10 个家族）

/// 宠物家族枚举
/// 每个家族有 3 个进化阶段，对应 3 张图片
enum PetFamily: String, Codable, CaseIterable {
    case Aerochorus = "Aerochorus" // 风系 — 风灵
    case flamepaw   = "flamepaw"   // 火系 — 焰爪
    case frosto     = "frosto"     // 冰系 — 霜灵
    case funglow    = "funglow"    // 妖精系 — 荧光菇
    case Glimmerite = "Glimmerite" // 光系 — 辉石
    case Lunara     = "Lunara"     // 暗系 — 月影
    case pebblem    = "pebblem"    // 岩系 — 岩崽
    case sproutling = "sproutling" // 草系 — 萌芽
    case Stellarion = "Stellarion" // 电系 — 星电
    case tidalrop   = "tidalrop"   // 水系 — 潮滴

    // MARK: - 家族信息

    /// 家族中文名
    var chineseName: String {
        switch self {
        case .Aerochorus: return "风灵"
        case .flamepaw:   return "焰爪"
        case .frosto:     return "霜灵"
        case .funglow:    return "荧光菇"
        case .Glimmerite: return "辉石"
        case .Lunara:     return "月影"
        case .pebblem:    return "岩崽"
        case .sproutling: return "萌芽"
        case .Stellarion: return "星电"
        case .tidalrop:   return "潮滴"
        }
    }

    /// 家族英文名（用于图片命名）
    var englishName: String {
        switch self {
        case .Aerochorus: return "Aerochorus"
        case .flamepaw:   return "Flamepaw"
        case .frosto:     return "Frosto"
        case .funglow:    return "Funglow"
        case .Glimmerite: return "Glimmerite"
        case .Lunara:     return "Lunara"
        case .pebblem:    return "Pebblem"
        case .sproutling: return "Sproutling"
        case .Stellarion: return "Stellarion"
        case .tidalrop:   return "Tidalrop"
        }
    }

    /// 家族属性
    var element: String {
        switch self {
        case .Aerochorus: return "🌬️ 风系"
        case .flamepaw:   return "🔥 火系"
        case .frosto:     return "❄️ 冰系"
        case .funglow:    return "🍄 妖精系"
        case .Glimmerite: return "☀️ 光系"
        case .Lunara:     return "🌙 暗系"
        case .pebblem:    return "🪨 岩系"
        case .sproutling: return "🌿 草系"
        case .Stellarion: return "⚡ 电系"
        case .tidalrop:   return "💧 水系"
        }
    }

    /// 家族主色调
    var primaryColorHex: String {
        switch self {
        case .Aerochorus: return "#A2D2FF"
        case .flamepaw:   return "#FF6B35"
        case .frosto:     return "#74C0FC"
        case .funglow:    return "#FF69B4"
        case .Glimmerite: return "#F4A460"
        case .Lunara:     return "#9B59B6"
        case .pebblem:    return "#D4A574"
        case .sproutling: return "#6BCB77"
        case .Stellarion: return "#FFD93D"
        case .tidalrop:   return "#4D96FF"
        }
    }

    /// 家族渐变色
    var gradientColorsHex: (String, String) {
        switch self {
        case .Aerochorus: return ("#A2D2FF", "#B8E0D2")
        case .flamepaw:   return ("#FF6B35", "#FFA41B")
        case .frosto:     return ("#74C0FC", "#DFE6E9")
        case .funglow:    return ("#FF69B4", "#A29BFE")
        case .Glimmerite: return ("#F4A460", "#FDCB6E")
        case .Lunara:     return ("#9B59B6", "#6C5CE7")
        case .pebblem:    return ("#D4A574", "#E17055")
        case .sproutling: return ("#6BCB77", "#2ECC71")
        case .Stellarion: return ("#FFD93D", "#F9CA24")
        case .tidalrop:   return ("#4D96FF", "#00D2FF")
        }
    }

    // MARK: - 图片资源名

    /// Lv1 图片名（在 Assets.xcassets 中的名称）
    var imageNameLv1: String {
        return "\(rawValue)_lv1"
    }

    /// Lv2 图片名
    var imageNameLv2: String {
        return "\(rawValue)_lv2"
    }

    /// Lv3 图片名
    var imageNameLv3: String {
        return "\(rawValue)_lv3"
    }

    /// 根据等级获取图片名
    func imageName(for level: PetLevel) -> String {
        switch level {
        case .level1: return imageNameLv1
        case .level2: return imageNameLv2
        case .level3: return imageNameLv3
        }
    }

    /// Lv1 描述
    var descriptionLv1: String {
        switch self {
        case .Aerochorus: return "一朵轻飘飘的小云"
        case .flamepaw:   return "一颗会冒小火苗的蛋"
        case .frosto:     return "一个冰凉的小雪球"
        case .funglow:    return "一朵发光的小蘑菇"
        case .Glimmerite: return "一束温暖的光芒"
        case .Lunara:     return "一团神秘的小影子"
        case .pebblem:    return "一块会发光的小石头"
        case .sproutling: return "一颗冒出嫩芽的种子"
        case .Stellarion: return "一团毛茸茸的电球"
        case .tidalrop:   return "一颗晶莹的水滴精灵"
        }
    }

    /// Lv2 描述
    var descriptionLv2: String {
        switch self {
        case .Aerochorus: return "优雅的风精灵鸟"
        case .flamepaw:   return "活泼的小火狐"
        case .frosto:     return "好奇的北极狐"
        case .funglow:    return "快乐的森林仙子"
        case .Glimmerite: return "温暖的阳光兔"
        case .Lunara:     return "神秘的暗影猫"
        case .pebblem:    return "结实的小石魔像"
        case .sproutling: return "温柔的森林小鹿"
        case .Stellarion: return "调皮的小电猫"
        case .tidalrop:   return "可爱的小海龟"
        }
    }

    /// Lv3 描述
    var descriptionLv3: String {
        switch self {
        case .Aerochorus: return "华丽的暴风鹰"
        case .flamepaw:   return "威严的焰狮"
        case .frosto:     return "高贵的霜狼"
        case .funglow:    return "梦幻的自然精灵"
        case .Glimmerite: return "辉煌的太阳狮"
        case .Lunara:     return "华丽的暗凤凰"
        case .pebblem:    return "强大的水晶泰坦"
        case .sproutling: return "古老的树龙"
        case .Stellarion: return "霸气的雷虎"
        case .tidalrop:   return "壮丽的海龙"
        }
    }

    /// 根据等级获取描述
    func description(for level: PetLevel) -> String {
        switch level {
        case .level1: return descriptionLv1
        case .level2: return descriptionLv2
        case .level3: return descriptionLv3
        }
    }

    // MARK: - 孵化相关

    /// 随机获取一个未拥有的家族（用于孵化）
    /// - Parameter ownedFamilies: 已拥有的家族列表
    /// - Returns: 随机的未拥有家族，如果全部拥有则返回 nil
    static func randomUnowned(from ownedFamilies: Set<PetFamily>) -> PetFamily? {
        let allFamilies = Set(PetFamily.allCases)
        let unowned = allFamilies.subtracting(ownedFamilies)
        guard !unowned.isEmpty else { return nil }
        return unowned.randomElement()
    }

    /// 随机获取一个家族（不考虑是否已拥有）
    static func random() -> PetFamily {
        return PetFamily.allCases.randomElement()!
    }
}

// MARK: - 宠物外观枚举（已废弃，保留兼容性）

/// 宠物外观枚举 — 现在由 PetFamily 替代
/// 保留此枚举仅用于数据向后兼容
@available(*, deprecated, message: "使用 PetFamily 替代")
enum PetAppearance: String, Codable, CaseIterable {
    case egg = "egg.fill"
    case chick = "bird.fill"
    case phoenix = "flame.fill"

    static func forLevel(_ level: PetLevel) -> PetAppearance {
        switch level {
        case .level1: return .egg
        case .level2: return .chick
        case .level3: return .phoenix
        }
    }

    var description: String {
        switch self {
        case .egg: return "蛋宝宝"
        case .chick: return "小鸟兽"
        case .phoenix: return "烈焰凤凰"
        }
    }
}

// MARK: - 宠物数据模型

/// 宠物数据模型
struct Pet: Codable {

    // MARK: - 基础属性

    var name: String
    var level: PetLevel
    var currentXP: Int
    var todayXP: Int
    var todayCalories: Double
    var todaySteps: Int
    var state: PetState

    /// 当前宠物家族
    var family: PetFamily

    /// 最后更新日期
    var lastUpdateDate: Date

    /// 历史记录
    var history: [String: Bool]

    // MARK: - 收藏系统

    /// 已拥有的家族列表（用于图鉴收集）
    var ownedFamilies: Set<PetFamily>

    /// 已孵化次数
    var totalHatches: Int

    /// 当前正在孵化的蛋（可选，孵化完成后变为正式宠物）
    var hatchingFamily: PetFamily?

    /// 孵化开始时间
    var hatchStartTime: Date?

    // MARK: - 计算属性

    var requiredXP: Int {
        return level.requiredXPForNextLevel
    }

    var progressToNextLevel: Double {
        guard requiredXP > 0 else { return 1.0 }
        return min(Double(currentXP) / Double(requiredXP), 1.0)
    }

    var canEvolve: Bool {
        return currentXP >= requiredXP && level != .level3
    }

    var calculatedTodayXP: Int {
        return Int(todayCalories * 1.0 + Double(todaySteps) * 0.1)
    }

    /// 当前宠物外观描述
    var appearanceDescription: String {
        return family.description(for: level)
    }

    /// 当前宠物图片名
    var currentImageName: String {
        return family.imageName(for: level)
    }

    /// 图鉴收集进度
    var collectionProgress: String {
        return "\(ownedFamilies.count)/\(PetFamily.allCases.count)"
    }

    /// 是否已集齐所有家族
    var isCollectionComplete: Bool {
        return ownedFamilies.count >= PetFamily.allCases.count
    }

    // MARK: - 初始化

    init(
        name: String = "小宠物",
        level: PetLevel = .level1,
        currentXP: Int = 0,
        todayXP: Int = 0,
        todayCalories: Double = 0,
        todaySteps: Int = 0,
        state: PetState = .normal,
        family: PetFamily = .flamepaw,
        lastUpdateDate: Date = Date(),
        history: [String: Bool] = [:],
        ownedFamilies: Set<PetFamily> = [.flamepaw],
        totalHatches: Int = 0,
        hatchingFamily: PetFamily? = nil,
        hatchStartTime: Date? = nil
    ) {
        self.name = name
        self.level = level
        self.currentXP = currentXP
        self.todayXP = todayXP
        self.todayCalories = todayCalories
        self.todaySteps = todaySteps
        self.state = state
        self.family = family
        self.lastUpdateDate = lastUpdateDate
        self.history = history
        self.ownedFamilies = ownedFamilies
        self.totalHatches = totalHatches
        self.hatchingFamily = hatchingFamily
        self.hatchStartTime = hatchStartTime
    }

    // MARK: - 静态方法

    static func defaultPet() -> Pet {
        // 首次创建时随机分配一个家族
        let randomFamily = PetFamily.random()
        return Pet(
            name: randomFamily.chineseName,
            family: randomFamily,
            ownedFamilies: [randomFamily]
        )
    }

    static func loadFromStorage() -> Pet {
        guard let sharedDefaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier),
              let data = sharedDefaults.data(forKey: AppConfig.petStorageKey) else {
            return defaultPet()
        }

        do {
            let pet = try JSONDecoder().decode(Pet.self, from: data)
            return pet
        } catch {
            print("加载宠物数据失败: \(error)")
            return defaultPet()
        }
    }

    func saveToStorage() {
        guard let sharedDefaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) else {
            print("无法访问 App Groups")
            return
        }

        do {
            let data = try JSONEncoder().encode(self)
            sharedDefaults.set(data, forKey: AppConfig.petStorageKey)
        } catch {
            print("保存宠物数据失败: \(error)")
        }
    }
}

// MARK: - 应用配置常量

struct AppConfig {
    static let appGroupIdentifier = "group.com.yourcompany.caloriepet"
    static let petStorageKey = "caloriepet.pet.data"
    static let dailyCalorieGoal: Double = 300
    static let dailyStepsGoal: Int = 5000
    static let hungryThresholdHours: Int = 12

    /// 孵化所需经验值（消耗今日经验值来孵化）
    static let hatchCostXP: Int = 500

    /// 孵化所需时间（秒），设为 0 表示即时孵化
    static let hatchDurationSeconds: TimeInterval = 0
}
