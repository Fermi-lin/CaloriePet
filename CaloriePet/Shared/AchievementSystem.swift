//
//  AchievementSystem.swift
//  CaloriePet
//
//  文件作用：实现成就系统和连续达标追踪
//  包括：各种成就定义、进度追踪、奖励发放
//

import SwiftUI
import Combine

// MARK: - 成就定义

/// 成就类型
enum AchievementType: String, Codable, CaseIterable {
    case firstSteps = "first_steps"           // 首次获得步数
    case firstCalories = "first_calories"     // 首次获得卡路里
    case firstEvolution = "first_evolution"   // 首次进化
    case maxLevel = "max_level"               // 达到最高等级
    case streak3 = "streak_3"                 // 连续3天达标
    case streak7 = "streak_7"                 // 连续7天达标
    case streak30 = "streak_30"               // 连续30天达标
    case calories1000 = "calories_1000"       // 累计1000卡路里
    case calories10000 = "calories_10000"     // 累计10000卡路里
    case steps10000 = "steps_10000"           // 累计10000步
    case steps100000 = "steps_100000"         // 累计100000步
    case earlyBird = "early_bird"             // 早上6点前运动
    case nightOwl = "night_owl"               // 晚上10点后运动
    case petLover = "pet_lover"               // 抚摸宠物100次
    
    /// 成就名称
    var name: String {
        switch self {
        case .firstSteps:
            return "第一步"
        case .firstCalories:
            return "初燃卡路里"
        case .firstEvolution:
            return "初次进化"
        case .maxLevel:
            return "巅峰之路"
        case .streak3:
            return "坚持3天"
        case .streak7:
            return "一周达人"
        case .streak30:
            return "月度冠军"
        case .calories1000:
            return "千卡路里"
        case .calories10000:
            return "万卡路里"
        case .steps10000:
            return "万步行者"
        case .steps100000:
            return "十万步神"
        case .earlyBird:
            return "早起的鸟"
        case .nightOwl:
            return "夜猫子"
        case .petLover:
            return "宠物爱好者"
        }
    }
    
    /// 成就描述
    var description: String {
        switch self {
        case .firstSteps:
            return "首次记录到步数"
        case .firstCalories:
            return "首次消耗卡路里"
        case .firstEvolution:
            return "宠物完成第一次进化"
        case .maxLevel:
            return "宠物达到最高等级"
        case .streak3:
            return "连续3天达标"
        case .streak7:
            return "连续7天达标"
        case .streak30:
            return "连续30天达标"
        case .calories1000:
            return "累计消耗1000卡路里"
        case .calories10000:
            return "累计消耗10000卡路里"
        case .steps10000:
            return "累计行走10000步"
        case .steps100000:
            return "累计行走100000步"
        case .earlyBird:
            return "早上6点前完成运动"
        case .nightOwl:
            return "晚上10点后完成运动"
        case .petLover:
            return "抚摸宠物100次"
        }
    }
    
    /// 成就图标
    var icon: String {
        switch self {
        case .firstSteps:
            return "shoeprints.fill"
        case .firstCalories:
            return "flame.fill"
        case .firstEvolution:
            return "arrow.up.circle.fill"
        case .maxLevel:
            return "crown.fill"
        case .streak3:
            return "3.circle.fill"
        case .streak7:
            return "7.circle.fill"
        case .streak30:
            return "30.circle.fill"
        case .calories1000:
            return "1.circle.fill"
        case .calories10000:
            return "10.circle.fill"
        case .steps10000:
            return "10.square.fill"
        case .steps100000:
            return "100.circle.fill"
        case .earlyBird:
            return "sunrise.fill"
        case .nightOwl:
            return "moon.fill"
        case .petLover:
            return "heart.fill"
        }
    }
    
    /// 成就颜色
    var color: Color {
        switch self {
        case .firstSteps, .firstCalories, .firstEvolution:
            return .green
        case .maxLevel:
            return .yellow
        case .streak3, .streak7, .streak30:
            return .orange
        case .calories1000, .calories10000:
            return .red
        case .steps10000, .steps100000:
            return .blue
        case .earlyBird:
            return .yellow
        case .nightOwl:
            return .purple
        case .petLover:
            return .pink
        }
    }
    
    /// 奖励经验值
    var xpReward: Int {
        switch self {
        case .firstSteps, .firstCalories:
            return 100
        case .firstEvolution:
            return 500
        case .maxLevel:
            return 2000
        case .streak3:
            return 300
        case .streak7:
            return 700
        case .streak30:
            return 3000
        case .calories1000:
            return 200
        case .calories10000:
            return 1000
        case .steps10000:
            return 200
        case .steps100000:
            return 1000
        case .earlyBird, .nightOwl:
            return 150
        case .petLover:
            return 500
        }
    }
}

// MARK: - 成就数据

/// 单个成就的数据
struct Achievement: Codable, Identifiable {
    let id: String
    let type: AchievementType
    var isUnlocked: Bool
    var unlockDate: Date?
    var progress: Double  // 0.0 - 1.0
    
    init(type: AchievementType, isUnlocked: Bool = false, unlockDate: Date? = nil, progress: Double = 0.0) {
        self.id = type.rawValue
        self.type = type
        self.isUnlocked = isUnlocked
        self.unlockDate = unlockDate
        self.progress = progress
    }
}

// MARK: - 成就管理器

/// 成就管理器
/// 管理所有成就的追踪和解锁
class AchievementManager: ObservableObject {
    
    // MARK: - 单例
    
    static let shared = AchievementManager()
    
    // MARK: - 发布属性
    
    @Published var achievements: [AchievementType: Achievement] = [:]
    @Published var newlyUnlocked: [Achievement] = []
    @Published var showUnlockAnimation = false
    
    // MARK: - 统计数据
    
    @Published var totalCaloriesBurned: Double = 0
    @Published var totalSteps: Int = 0
    @Published var totalPetTaps: Int = 0
    
    // MARK: - 初始化
    
    private init() {
        loadAchievements()
        loadStats()
    }
    
    // MARK: - 成就检查
    
    /// 检查并解锁成就
    /// - Parameter type: 成就类型
    /// - Returns: 是否新解锁
    @discardableResult
    func checkAndUnlock(_ type: AchievementType) -> Bool {
        guard var achievement = achievements[type], !achievement.isUnlocked else {
            return false
        }
        
        achievement.isUnlocked = true
        achievement.unlockDate = Date()
        achievement.progress = 1.0
        
        achievements[type] = achievement
        newlyUnlocked.append(achievement)
        
        saveAchievements()
        
        // 显示解锁动画
        showUnlockAnimation = true
        
        return true
    }
    
    /// 更新成就进度
    /// - Parameters:
    ///   - type: 成就类型
    ///   - progress: 进度（0.0 - 1.0）
    func updateProgress(for type: AchievementType, progress: Double) {
        guard var achievement = achievements[type], !achievement.isUnlocked else {
            return
        }
        
        achievement.progress = min(max(progress, 0.0), 1.0)
        achievements[type] = achievement
        
        // 如果进度达到100%，自动解锁
        if achievement.progress >= 1.0 {
            checkAndUnlock(type)
        }
        
        saveAchievements()
    }
    
    // MARK: - 统计更新
    
    /// 更新卡路里统计
    func addCalories(_ calories: Double) {
        totalCaloriesBurned += calories
        
        // 检查卡路里成就
        if totalCaloriesBurned >= 1000 {
            checkAndUnlock(.calories1000)
        }
        if totalCaloriesBurned >= 10000 {
            checkAndUnlock(.calories10000)
        }
        
        saveStats()
    }
    
    /// 更新步数统计
    func addSteps(_ steps: Int) {
        totalSteps += steps
        
        // 检查步数成就
        if totalSteps >= 10000 {
            checkAndUnlock(.steps10000)
        }
        if totalSteps >= 100000 {
            checkAndUnlock(.steps100000)
        }
        
        saveStats()
    }
    
    /// 记录宠物点击
    func recordPetTap() {
        totalPetTaps += 1
        
        if totalPetTaps >= 100 {
            checkAndUnlock(.petLover)
        }
        
        saveStats()
    }
    
    /// 记录进化
    func recordEvolution(level: PetLevel) {
        if level == .level2 {
            checkAndUnlock(.firstEvolution)
        }
        if level == .level3 {
            checkAndUnlock(.maxLevel)
        }
    }
    
    /// 检查连续达标天数
    func checkStreak(_ streakDays: Int) {
        switch streakDays {
        case 3...6:
            checkAndUnlock(.streak3)
        case 7...29:
            checkAndUnlock(.streak7)
        case 30...:
            checkAndUnlock(.streak30)
        default:
            break
        }
    }
    
    // MARK: - 数据持久化
    
    private func saveAchievements() {
        guard let sharedDefaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) else { return }
        
        let data = achievements.values.map { $0 }
        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults.set(encoded, forKey: "caloriepet.achievements")
        }
    }
    
    private func loadAchievements() {
        guard let sharedDefaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier),
              let data = sharedDefaults.data(forKey: "caloriepet.achievements"),
              let decoded = try? JSONDecoder().decode([Achievement].self, from: data) else {
            // 初始化默认成就
            initializeDefaultAchievements()
            return
        }
        
        achievements = Dictionary(uniqueKeysWithValues: decoded.map { ($0.type, $0) })
    }
    
    private func initializeDefaultAchievements() {
        for type in AchievementType.allCases {
            achievements[type] = Achievement(type: type)
        }
        saveAchievements()
    }
    
    private func saveStats() {
        guard let sharedDefaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) else { return }
        
        sharedDefaults.set(totalCaloriesBurned, forKey: "caloriepet.stats.calories")
        sharedDefaults.set(totalSteps, forKey: "caloriepet.stats.steps")
        sharedDefaults.set(totalPetTaps, forKey: "caloriepet.stats.taps")
    }
    
    private func loadStats() {
        guard let sharedDefaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) else { return }
        
        totalCaloriesBurned = sharedDefaults.double(forKey: "caloriepet.stats.calories")
        totalSteps = sharedDefaults.integer(forKey: "caloriepet.stats.steps")
        totalPetTaps = sharedDefaults.integer(forKey: "caloriepet.stats.taps")
    }
    
    // MARK: - 获取成就
    
    /// 获取已解锁的成就
    var unlockedAchievements: [Achievement] {
        return achievements.values.filter { $0.isUnlocked }.sorted {
            ($0.unlockDate ?? Date()) > ($1.unlockDate ?? Date())
        }
    }
    
    /// 获取未解锁的成就
    var lockedAchievements: [Achievement] {
        return achievements.values.filter { !$0.isUnlocked }
    }
    
    /// 获取解锁数量
    var unlockedCount: Int {
        return unlockedAchievements.count
    }
    
    /// 获取总成就数
    var totalCount: Int {
        return AchievementType.allCases.count
    }
}

// MARK: - 成就列表视图

struct AchievementListView: View {
    @StateObject private var manager = AchievementManager.shared
    
    var body: some View {
        List {
            // 统计概览
            Section(header: Text("概览")) {
                HStack {
                    Text("已解锁")
                    Spacer()
                    Text("\(manager.unlockedCount)/\(manager.totalCount)")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: Double(manager.unlockedCount), total: Double(manager.totalCount))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }
            
            // 已解锁成就
            if !manager.unlockedAchievements.isEmpty {
                Section(header: Text("已解锁")) {
                    ForEach(manager.unlockedAchievements) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
            }
            
            // 未解锁成就
            Section(header: Text("未解锁")) {
                ForEach(manager.lockedAchievements) { achievement in
                    AchievementRow(achievement: achievement)
                        .opacity(0.6)
                }
            }
        }
        .navigationTitle("成就")
    }
}

// MARK: - 成就行视图

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            ZStack {
                Circle()
                    .fill(achievement.type.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: achievement.type.icon)
                    .font(.title3)
                    .foregroundColor(achievement.type.color)
            }
            
            // 信息
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.type.name)
                    .font(.headline)
                
                Text(achievement.type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 状态
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else {
                // 进度
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 30, height: 30)
                    
                    Circle()
                        .trim(from: 0, to: achievement.progress)
                        .stroke(achievement.type.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(-90))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 解锁动画视图

struct AchievementUnlockView: View {
    let achievement: Achievement
    @Binding var isShowing: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("成就解锁！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 成就图标动画
                ZStack {
                    // 光效
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    achievement.type.color.opacity(0.8),
                                    achievement.type.color.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(scale)
                    
                    // 图标
                    Image(systemName: achievement.type.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(achievement.type.color)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(scale)
                }
                
                // 成就信息
                VStack(spacing: 8) {
                    Text(achievement.type.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(achievement.type.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("+\(achievement.type.xpReward) XP")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 8)
                }
                
                Button("太棒了！") {
                    withAnimation {
                        isShowing = false
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(25)
                .padding(.top, 16)
            }
            .padding()
        }
        .onAppear {
            // 启动动画
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - 预览

struct AchievementListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AchievementListView()
        }
    }
}
