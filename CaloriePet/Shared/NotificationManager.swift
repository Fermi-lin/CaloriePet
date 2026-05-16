//
//  NotificationManager.swift
//  CaloriePet
//
//  文件作用：管理本地通知系统
//  包括：运动提醒、宠物状态提醒、达标通知
//

import UserNotifications
import SwiftUI
import Combine

/// 通知管理器
/// 处理所有本地通知的注册、调度和响应
class NotificationManager: NSObject, ObservableObject {
    
    // MARK: - 单例
    
    static let shared = NotificationManager()
    
    // MARK: - 发布属性
    
    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    // MARK: - 初始化
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - 授权管理
    
    /// 检查通知授权状态
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// 请求通知授权
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("请求通知授权失败: \(error)")
            return false
        }
    }
    
    // MARK: - 通知调度
    
    /// 调度宠物饿了提醒
    func scheduleHungryNotification(petName: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(petName) 饿了！"
        content.body = "快去运动赚取卡路里来喂养你的宠物吧！"
        content.sound = .default
        content.badge = 1
        
        // 12小时后触发
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 12 * 3600, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "hungry_\(petName)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// 调度每日运动提醒
    func scheduleDailyReminder(hour: Int = 9, minute: Int = 0) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "该运动了！"
        content.body = "你的宠物正在等待你完成今天的运动目标 🏃‍♂️"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// 调度达标庆祝通知
    func scheduleGoalAchievedNotification(petName: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "恭喜达标！🎉"
        content.body = "\(petName) 因为你今天的努力而非常开心！"
        content.sound = .default
        
        // 立即触发
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "goal_achieved_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// 调度进化通知
    func scheduleEvolutionNotification(petName: String, newLevel: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "进化成功！✨"
        content.body = "\(petName) 进化到了 \(newLevel)！"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "evolution_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// 调度连续达标提醒
    func scheduleStreakNotification(streakDays: Int) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "连续 \(streakDays) 天达标！🔥"
        content.body = "保持这个势头，你的宠物会变得更强大！"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak_\(streakDays)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - 通知管理
    
    /// 取消所有通知
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// 取消特定类型的通知
    func cancelNotifications(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// 获取待处理的通知
    func fetchPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.pendingNotifications = requests
            }
        }
    }
    
    // MARK: - 智能提醒
    
    /// 根据宠物状态智能调度通知
    func scheduleSmartNotifications(pet: Pet) {
        // 如果宠物饿了，调度饥饿提醒
        if pet.state == .hungry {
            scheduleHungryNotification(petName: pet.name)
        }
        
        // 调度每日提醒
        scheduleDailyReminder(hour: 9, minute: 0)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// 应用在前台时收到通知
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 在前台也显示通知
        completionHandler([.banner, .sound, .badge])
    }
    
    /// 用户点击通知
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        
        // 处理不同类型的通知
        if identifier.contains("hungry") {
            // 打开应用并刷新数据
            NotificationCenter.default.post(name: .init("OpenAppAndRefresh"), object: nil)
        } else if identifier.contains("daily_reminder") {
            // 打开应用
            NotificationCenter.default.post(name: .init("OpenApp"), object: nil)
        }
        
        completionHandler()
    }
}

// MARK: - 通知设置视图

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var dailyReminderEnabled = true
    @State private var reminderHour = 9
    @State private var reminderMinute = 0
    
    var body: some View {
        List {
            Section(header: Text("通知权限")) {
                HStack {
                    Text("状态")
                    Spacer()
                    Text(notificationManager.isAuthorized ? "已授权" : "未授权")
                        .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                }
                
                if !notificationManager.isAuthorized {
                    Button("请求授权") {
                        Task {
                            await notificationManager.requestAuthorization()
                        }
                    }
                }
            }
            
            Section(header: Text("提醒设置")) {
                Toggle("每日运动提醒", isOn: $dailyReminderEnabled)
                
                if dailyReminderEnabled {
                    DatePicker(
                        "提醒时间",
                        selection: bindingForTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            
            Section(header: Text("通知类型")) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                    Text("宠物饿了提醒")
                    Spacer()
                    Text("自动")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("达标庆祝")
                    Spacer()
                    Text("自动")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("进化通知")
                    Spacer()
                    Text("自动")
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button("测试通知") {
                    testNotification()
                }
                
                Button("取消所有通知") {
                    notificationManager.cancelAllNotifications()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("通知设置")
    }
    
    /// 时间选择器绑定
    private var bindingForTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = components.hour ?? 9
                reminderMinute = components.minute ?? 0
                
                // 更新通知
                notificationManager.cancelNotifications(withIdentifier: "daily_reminder")
                notificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            }
        )
    }
    
    /// 测试通知
    private func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "测试通知"
        content.body = "这是一条测试通知！"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - 预览

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationSettingsView()
        }
    }
}
