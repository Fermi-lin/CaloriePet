//
//  CaloriePetApp.swift
//  CaloriePet (iPhone)
//
//  文件作用：iPhone 应用的入口点
//  负责：初始化 HealthKit、激活 Watch Connectivity、设置应用生命周期
//

import SwiftUI
import HealthKit

@main
struct CaloriePetApp: App {
    
    // MARK: - 应用委托
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - 场景
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 激活 Watch Connectivity
                    WatchConnectivityManager.shared.activateSession()
                }
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// 应用启动完成时调用
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // 初始化 HealthKit
        initializeHealthKit()
        
        // 配置通知（可选）
        configureNotifications()
        
        return true
    }
    
    /// 初始化 HealthKit
    private func initializeHealthKit() {
        // 检查 HealthKit 是否可用
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit 在此设备上不可用")
            return
        }
        
        // 请求授权（可选：延迟到用户首次进入应用时请求）
        // 这里仅检查状态，实际授权在 HealthKitManager 中处理
        HealthKitManager.shared.checkAuthorizationStatus()
    }
    
    /// 配置本地通知
    private func configureNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("通知授权失败: \(error.localizedDescription)")
            } else {
                print("通知授权状态: \(granted)")
            }
        }
    }
    
    /// 应用进入前台时调用
    func applicationDidBecomeActive(_ application: UIApplication) {
        // 刷新数据
        NotificationCenter.default.post(name: .init("AppDidBecomeActive"), object: nil)
    }
    
    /// 应用进入后台时调用
    func applicationDidEnterBackground(_ application: UIApplication) {
        // 保存数据
        let pet = Pet.loadFromStorage()
        pet.saveToStorage()
    }
}
