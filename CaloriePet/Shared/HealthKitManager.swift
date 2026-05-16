//
//  HealthKitManager.swift
//  CaloriePet
//
//  文件作用：封装 HealthKit 数据读取功能
//  负责：请求授权、读取活动卡路里、读取步数、错误处理
//  提供异步接口供 ViewModel 调用
//

import HealthKit
import Combine

/// HealthKit 管理器
/// 处理所有与 HealthKit 相关的操作，包括授权和数据读取
class HealthKitManager: ObservableObject {
    
    // MARK: - 单例模式
    
    static let shared = HealthKitManager()
    
    // MARK: - 发布属性
    
    /// 授权状态
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    /// 是否正在加载数据
    @Published var isLoading = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    
    /// HealthKit 存储对象
    private let healthStore = HKHealthStore()
    
    /// 需要读取的数据类型
    private var typesToRead: Set<HKObjectType> {
        return [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ]
    }
    
    /// 需要写入的数据类型（可选，如果需要写入数据）
    private var typesToWrite: Set<HKSampleType> {
        return []  // 本应用只需要读取，不需要写入
    }
    
    // MARK: - 初始化
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - 授权相关
    
    /// 检查当前授权状态
    func checkAuthorizationStatus() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            authorizationStatus = .sharingDenied
            return
        }
        
        let calorieStatus = healthStore.authorizationStatus(for: calorieType)
        let stepStatus = healthStore.authorizationStatus(for: stepType)
        
        // 如果任一权限被拒绝，则认为整体被拒绝
        if calorieStatus == .sharingDenied || stepStatus == .sharingDenied {
            authorizationStatus = .sharingDenied
        } else if calorieStatus == .sharingAuthorized && stepStatus == .sharingAuthorized {
            authorizationStatus = .sharingAuthorized
        } else {
            authorizationStatus = .notDetermined
        }
    }
    
    /// 请求 HealthKit 授权
    /// - Returns: 是否成功获得授权
    func requestAuthorization() async -> Bool {
        // 检查 HealthKit 是否可用
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run {
                errorMessage = "此设备不支持 HealthKit"
                authorizationStatus = .sharingDenied
            }
            return false
        }
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            
            await MainActor.run {
                checkAuthorizationStatus()
            }
            
            return authorizationStatus == .sharingAuthorized
        } catch {
            await MainActor.run {
                errorMessage = "请求授权失败: \(error.localizedDescription)"
                authorizationStatus = .sharingDenied
            }
            return false
        }
    }
    
    /// 检查是否已授权
    var isAuthorized: Bool {
        return authorizationStatus == .sharingAuthorized
    }
    
    // MARK: - 数据读取
    
    /// 获取今日活动数据（卡路里和步数）
    /// - Returns: (卡路里, 步数) 的元组
    func fetchTodayActivityData() async -> (calories: Double, steps: Int) {
        guard isAuthorized else {
            return (0, 0)
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // 获取今日的起始时间（00:00）
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        // 创建异步任务组，同时获取卡路里和步数
        async let calories = fetchActiveEnergyBurned(from: startOfDay, to: now)
        async let steps = fetchStepCount(from: startOfDay, to: now)
        
        let result = await (calories: calories, steps: steps)
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    /// 获取指定时间段内的活动消耗卡路里
    /// - Parameters:
    ///   - startDate: 开始时间
    ///   - endDate: 结束时间
    /// - Returns: 消耗的卡路里数
    private func fetchActiveEnergyBurned(from startDate: Date, to endDate: Date) async -> Double {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return 0
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: calorieType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                
                if let error = error {
                    print("读取卡路里数据失败: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                // 获取千卡值
                let calories = sum.doubleValue(for: .kilocalorie())
                continuation.resume(returning: calories)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 获取指定时间段内的步数
    /// - Parameters:
    ///   - startDate: 开始时间
    ///   - endDate: 结束时间
    /// - Returns: 步数
    private func fetchStepCount(from startDate: Date, to endDate: Date) async -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                
                if let error = error {
                    print("读取步数数据失败: \(error.localizedDescription)")
                    continuation.resume(returning: 0)
                    return
                }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                // 获取步数值
                let steps = sum.doubleValue(for: .count())
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - 错误处理
    
    /// 获取用户友好的错误信息
    /// - Parameter error: 原始错误
    /// - Returns: 本地化错误描述
    private func getFriendlyErrorMessage(for error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case HKError.errorHealthDataUnavailable.rawValue:
            return "HealthKit 在此设备上不可用"
        case HKError.errorAuthorizationDenied.rawValue:
            return "请在设置中授权访问健康数据"
        case HKError.errorAuthorizationNotDetermined.rawValue:
            return "需要授权才能访问健康数据"
        case HKError.errorDatabaseInaccessible.rawValue:
            return "无法访问健康数据库，请稍后重试"
        default:
            return "获取健康数据失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 模拟数据（用于测试）
    
    #if DEBUG
    /// 获取模拟数据（用于开发和测试）
    func fetchMockData() -> (calories: Double, steps: Int) {
        // 返回模拟数据：300 卡路里，5000 步
        return (300.0, 5000)
    }
    #endif
}

// MARK: - 扩展：HKAuthorizationStatus 描述

extension HKAuthorizationStatus {
    var displayName: String {
        switch self {
        case .notDetermined:
            return "未确定"
        case .sharingDenied:
            return "已拒绝"
        case .sharingAuthorized:
            return "已授权"
        @unknown default:
            return "未知"
        }
    }
}