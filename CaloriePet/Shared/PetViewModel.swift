//
//  PetViewModel.swift
//  CaloriePet
//
//  文件作用：宠物状态管理 ViewModel
//  负责：经验值计算、进化逻辑、每日数据更新、HealthKit 数据整合
//  是 View 和数据层之间的桥梁
//

import Foundation
import Combine
import SwiftUI

/// 宠物视图模型
/// 管理宠物的所有业务逻辑，包括经验值计算、进化判断、数据同步等
class PetViewModel: ObservableObject {
    
    // MARK: - 发布属性
    
    /// 当前宠物数据
    @Published var pet: Pet
    
    /// 是否正在加载数据
    @Published var isLoading = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 是否显示进化动画
    @Published var showEvolutionAnimation = false

    /// 进化目标等级（用于动画显示）
    @Published var evolutionTargetLevel: PetLevel?

    /// 是否显示孵化动画
    @Published var showHatchAnimation = false

    /// 孵化出的新家族（用于动画显示）
    @Published var hatchedFamily: PetFamily?
    
    /// 今日卡路里消耗
    @Published var todayCalories: Double = 0
    
    /// 今日步数
    @Published var todaySteps: Int = 0
    
    /// 是否已达标（可选功能）
    @Published var isGoalAchieved = false
    
    // MARK: - 私有属性
    
    /// 取消令牌存储
    private var cancellables = Set<AnyCancellable>()
    
    /// 定时器，用于定期刷新数据
    private var refreshTimer: Timer?
    
    /// HealthKit 管理器
    private let healthKitManager = HealthKitManager.shared
    
    /// Watch Connectivity 管理器
    private let watchConnectivityManager = WatchConnectivityManager.shared
    
    // MARK: - 计算属性
    
    /// 当前等级进度百分比（0-100）
    var progressPercentage: Int {
        return Int(pet.progressToNextLevel * 100)
    }
    
    /// 距离下一级还需多少经验值
    var xpToNextLevel: Int {
        return max(0, pet.requiredXP - pet.currentXP)
    }
    
    /// 今日获得的经验值
    var todayXP: Int {
        return pet.todayXP
    }
    
    /// 总经验值
    var totalXP: Int {
        // 计算之前等级累积的经验值 + 当前等级经验值
        var total = pet.currentXP
        for level in PetLevel.allCases where level.rawValue < pet.level.rawValue {
            total += level.requiredXPForNextLevel
        }
        return total
    }
    
    /// 宠物状态描述
    var petStatusDescription: String {
        switch pet.state {
        case .happy:
            return "\(pet.name) 很开心！"
        case .normal:
            return "\(pet.name) 状态不错"
        case .hungry:
            return "\(pet.name) 饿了，快去运动吧！"
        }
    }

    /// 是否可以孵化新蛋
    /// 条件：今日经验值 >= 孵化消耗 且 还有未拥有的家族
    var canHatch: Bool {
        return pet.todayXP >= AppConfig.hatchCostXP && !pet.isCollectionComplete
    }
    
    // MARK: - 初始化
    
    init() {
        // 从存储加载宠物数据
        self.pet = Pet.loadFromStorage()
        
        // 检查是否需要重置每日数据
        checkAndResetDailyData()
        
        // 设置 Watch Connectivity 回调
        setupWatchConnectivity()
        
        // 启动定时刷新
        startRefreshTimer()
        
        // 初始加载 HealthKit 数据
        Task {
            await refreshHealthData()
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    // MARK: - 公共方法
    
    /// 刷新 HealthKit 数据并更新宠物状态
    func refreshHealthData() async {
        await MainActor.run {
            isLoading = true
        }
        
        // 检查授权状态
        if !healthKitManager.isAuthorized {
            let authorized = await healthKitManager.requestAuthorization()
            guard authorized else {
                await MainActor.run {
                    errorMessage = "需要授权访问健康数据"
                    isLoading = false
                }
                return
            }
        }
        
        // 获取今日活动数据
        let data = await healthKitManager.fetchTodayActivityData()
        
        await MainActor.run {
            todayCalories = data.calories
            todaySteps = data.steps
            
            // 更新宠物数据
            updatePetWithHealthData(calories: data.calories, steps: data.steps)
            
            isLoading = false
        }
    }
    
    /// 手动刷新数据（供 UI 调用）
    func manualRefresh() {
        Task {
            await refreshHealthData()
        }
    }
    
    /// 更新宠物名称
    /// - Parameter name: 新名称
    func updatePetName(_ name: String) {
        pet.name = name
        savePet()
    }
    
    /// 手动添加经验值（用于测试或特殊功能）
    /// - Parameter xp: 经验值
    func addXP(_ xp: Int) {
        pet.currentXP += xp
        pet.todayXP += xp
        
        // 检查是否可以进化
        checkEvolution()
        
        // 更新状态
        updatePetState()
        
        // 保存数据
        savePet()
        
        // 同步到 Watch
        syncToWatch()
    }
    
    /// 重置宠物数据（用于重新开始）
    func resetPet() {
        pet = Pet.defaultPet()
        todayCalories = 0
        todaySteps = 0
        savePet()
        syncToWatch()
    }

    /// 开始孵化新蛋
    /// 从未拥有的家族中随机选一个，消耗 AppConfig.hatchCostXP 经验值
    func startHatch() {
        guard canHatch else { return }

        // 从未拥有的家族中随机选择一个
        guard let newFamily = PetFamily.randomUnowned(from: pet.ownedFamilies) else { return }

        // 消耗今日经验值
        pet.todayXP -= AppConfig.hatchCostXP

        // 记录孵化中的家族和开始时间
        pet.hatchingFamily = newFamily
        pet.hatchStartTime = Date()

        // 保存数据
        savePet()
        syncToWatch()

        print("开始孵化 \(newFamily.chineseName) 的蛋！")
    }

    /// 完成孵化
    /// 将新家族加入已拥有列表，替换当前宠物
    func completeHatch() {
        guard let newFamily = pet.hatchingFamily else { return }

        // 将新家族加入已拥有列表
        pet.ownedFamilies.insert(newFamily)

        // 增加孵化次数
        pet.totalHatches += 1

        // 替换当前宠物为新家族，重置等级为 Lv1
        pet.family = newFamily
        pet.name = newFamily.chineseName
        pet.level = .level1
        pet.currentXP = 0
        pet.state = .happy

        // 清除孵化状态
        pet.hatchingFamily = nil
        pet.hatchStartTime = nil

        // 设置孵化动画属性
        hatchedFamily = newFamily
        showHatchAnimation = true

        // 保存数据
        savePet()
        syncToWatch()

        print("孵化完成！获得新家族：\(newFamily.chineseName)")
    }

    /// 切换到已拥有的某个家族作为当前宠物（重置等级为 Lv1）
    /// - Parameter family: 要切换到的已拥有家族
    func switchToFamily(_ family: PetFamily) {
        guard pet.ownedFamilies.contains(family) else { return }

        // 切换家族，重置等级
        pet.family = family
        pet.name = family.chineseName
        pet.level = .level1
        pet.currentXP = 0
        pet.state = .happy

        // 保存数据
        savePet()
        syncToWatch()

        print("切换到家族：\(family.chineseName)")
    }
    
    /// 获取历史记录
    /// - Returns: 按日期排序的历史记录数组
    func getHistory() -> [(date: String, achieved: Bool)] {
        return pet.history.sorted { $0.key > $1.key }
            .map { (date: $0.key, achieved: $0.value) }
    }
    
    // MARK: - 私有方法
    
    /// 根据 HealthKit 数据更新宠物
    private func updatePetWithHealthData(calories: Double, steps: Int) {
        // 计算新的经验值
        let newXP = Int(calories * 1.0 + Double(steps) * 0.1)
        let xpDifference = newXP - pet.todayXP
        
        // 更新今日数据
        pet.todayCalories = calories
        pet.todaySteps = steps
        pet.todayXP = newXP
        pet.lastUpdateDate = Date()
        
        // 如果有新增经验值，累加到总经验值
        if xpDifference > 0 {
            pet.currentXP += xpDifference
            
            // 检查进化
            checkEvolution()
        }
        
        // 更新状态
        updatePetState()
        
        // 检查是否达标
        checkGoalAchievement()
        
        // 保存数据
        savePet()
        
        // 同步到 Watch
        syncToWatch()
    }
    
    /// 检查并触发进化
    private func checkEvolution() {
        guard pet.canEvolve else { return }
        
        // 触发进化
        if let nextLevel = pet.level.nextLevel {
            // 保存当前等级用于动画
            evolutionTargetLevel = nextLevel
            
            // 执行进化
            evolveTo(nextLevel)
            
            // 显示进化动画
            showEvolutionAnimation = true
        }
    }
    
    /// 执行进化
    private func evolveTo(_ newLevel: PetLevel) {
        // 扣除升级所需经验值
        pet.currentXP -= pet.requiredXP
        
        // 更新等级
        pet.level = newLevel
        
        // 更新外观（使用 PetFamily 的 imageName）
        // 外观由 pet.family + pet.level 决定，无需额外设置
        
        // 更新状态为开心
        pet.state = .happy
        
        print("宠物进化到 \(newLevel.displayName)！")
    }
    
    /// 更新宠物状态
    private func updatePetState() {
        let calendar = Calendar.current
        
        // 检查最后更新时间
        if let hoursSinceLastUpdate = calendar.dateComponents(
            [.hour],
            from: pet.lastUpdateDate,
            to: Date()
        ).hour {
            
            if hoursSinceLastUpdate >= AppConfig.hungryThresholdHours {
                // 超过饥饿阈值，显示饥饿状态
                pet.state = .hungry
            } else if pet.todayXP >= 500 {
                // 今日获得较多经验值，显示开心
                pet.state = .happy
            } else {
                // 默认状态
                pet.state = .normal
            }
        }
    }
    
    /// 检查是否达成每日目标
    private func checkGoalAchievement() {
        let caloriesAchieved = pet.todayCalories >= AppConfig.dailyCalorieGoal
        let stepsAchieved = pet.todaySteps >= AppConfig.dailyStepsGoal
        
        isGoalAchieved = caloriesAchieved || stepsAchieved
        
        // 如果达标，记录到历史
        if isGoalAchieved {
            let dateString = formatDate(Date())
            pet.history[dateString] = true
        }
    }
    
    /// 检查并重置每日数据
    private func checkAndResetDailyData() {
        let calendar = Calendar.current
        
        // 检查是否是新的一天
        if !calendar.isDate(pet.lastUpdateDate, inSameDayAs: Date()) {
            // 记录昨天的数据
            let yesterdayString = formatDate(pet.lastUpdateDate)
            let wasAchieved = pet.todayXP >= 500  // 简化的达标判断
            pet.history[yesterdayString] = wasAchieved
            
            // 重置今日数据
            pet.todayXP = 0
            pet.todayCalories = 0
            pet.todaySteps = 0
            pet.lastUpdateDate = Date()
            
            // 保存
            savePet()
            
            print("已重置每日数据")
        }
    }
    
    /// 保存宠物数据
    private func savePet() {
        pet.saveToStorage()
    }
    
    /// 同步数据到 Apple Watch
    private func syncToWatch() {
        watchConnectivityManager.sendPetData(pet)
    }
    
    /// 设置 Watch Connectivity 回调
    private func setupWatchConnectivity() {
        watchConnectivityManager.onDataReceived = { [weak self] data in
            // 处理从 Watch 接收到的数据
            if let pet = self?.watchConnectivityManager.parsePetData(from: data) {
                // 如果接收到的数据更新，则更新本地数据
                if pet.lastUpdateDate > (self?.pet.lastUpdateDate ?? Date.distantPast) {
                    self?.pet = pet
                    self?.savePet()
                }
            }
            
            // 处理活动数据（从 Watch 发送的实时数据）
            if let activityData = self?.watchConnectivityManager.parseActivityData(from: data) {
                self?.todayCalories = activityData.calories
                self?.todaySteps = activityData.steps
                self?.updatePetWithHealthData(calories: activityData.calories, steps: activityData.steps)
            }
        }
    }
    
    /// 启动定时刷新
    private func startRefreshTimer() {
        // 每 5 分钟刷新一次数据
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshHealthData()
            }
        }
    }
    
    /// 格式化日期为字符串
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - 预览支持

extension PetViewModel {
    /// 创建用于预览的 ViewModel
    static func preview() -> PetViewModel {
        let viewModel = PetViewModel()
        viewModel.pet = Pet(
            name: "焰爪",
            level: .level2,
            currentXP: 15000,
            todayXP: 800,
            todayCalories: 350,
            todaySteps: 6500,
            state: .happy,
            family: .flamepaw,
            ownedFamilies: [.flamepaw, .tidalrop, .sproutling]
        )
        viewModel.todayCalories = 350
        viewModel.todaySteps = 6500
        return viewModel
    }
}