//
//  DebugTools.swift
//  CaloriePet
//
//  文件作用：提供调试和测试工具
//  包括：模拟数据、快速测试、日志记录等功能
//

import SwiftUI
import Combine

// MARK: - 调试管理器

/// 调试管理器
/// 提供开发和测试时的辅助功能
class DebugManager: ObservableObject {
    
    // MARK: - 单例
    
    static let shared = DebugManager()
    
    // MARK: - 发布属性
    
    @Published var isDebugMode = false
    @Published var mockCalories: Double = 300
    @Published var mockSteps: Int = 5000
    
    // MARK: - 模拟数据
    
    /// 快速增加经验值（用于测试进化）
    func addXPForTesting(_ viewModel: PetViewModel, xp: Int = 1000) {
        viewModel.addXP(xp)
        print("[Debug] 添加了 \(xp) XP")
    }
    
    /// 快速进化（用于测试进化动画）
    func forceEvolution(_ viewModel: PetViewModel) {
        let neededXP = viewModel.pet.requiredXP - viewModel.pet.currentXP + 100
        addXPForTesting(viewModel, xp: neededXP)
        print("[Debug] 强制进化触发")
    }
    
    /// 重置为 Lv1
    func resetToLevel1(_ viewModel: PetViewModel) {
        viewModel.resetPet()
        print("[Debug] 重置为 Lv1")
    }
    
    /// 直接设置等级
    func setLevel(_ viewModel: PetViewModel, level: PetLevel) {
        var pet = viewModel.pet
        pet.level = level
        // 外观由 family + level 决定，无需手动设置
        pet.currentXP = 0
        pet.saveToStorage()
        viewModel.objectWillChange.send()
        print("[Debug] 设置等级为 \(level.displayName)")
    }
    
    /// 模拟 HealthKit 数据
    func simulateHealthData(_ viewModel: PetViewModel) {
        viewModel.todayCalories = mockCalories
        viewModel.todaySteps = mockSteps
        viewModel.addXP(Int(mockCalories * 1.0 + Double(mockSteps) * 0.1))
        print("[Debug] 模拟数据: 卡路里 \(mockCalories), 步数 \(mockSteps)")
    }
    
    /// 触发所有通知测试
    func testAllNotifications() {
        let notificationManager = NotificationManager.shared
        
        notificationManager.scheduleHungryNotification(petName: "测试宠物")
        notificationManager.scheduleGoalAchievedNotification(petName: "测试宠物")
        notificationManager.scheduleEvolutionNotification(petName: "测试宠物", newLevel: "Lv.2")
        
        print("[Debug] 已调度所有测试通知")
    }
    
    /// 解锁所有成就
    func unlockAllAchievements() {
        let manager = AchievementManager.shared
        for type in AchievementType.allCases {
            manager.checkAndUnlock(type)
        }
        print("[Debug] 解锁所有成就")
    }
    
    /// 打印当前状态
    func printCurrentState(_ viewModel: PetViewModel) {
        print("""
        [Debug] 当前状态:
        - 宠物: \(viewModel.pet.name)
        - 等级: \(viewModel.pet.level.displayName)
        - 经验值: \(viewModel.pet.currentXP)/\(viewModel.pet.requiredXP)
        - 今日XP: \(viewModel.todayXP)
        - 卡路里: \(viewModel.todayCalories)
        - 步数: \(viewModel.todaySteps)
        - 状态: \(viewModel.pet.state.displayName)
        """)
    }
    
    /// 清除所有数据
    func clearAllData() {
        guard let sharedDefaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) else { return }
        
        sharedDefaults.removeObject(forKey: AppConfig.petStorageKey)
        sharedDefaults.removeObject(forKey: "caloriepet.achievements")
        sharedDefaults.removeObject(forKey: "caloriepet.stats.calories")
        sharedDefaults.removeObject(forKey: "caloriepet.stats.steps")
        sharedDefaults.removeObject(forKey: "caloriepet.stats.taps")
        
        print("[Debug] 已清除所有数据")
    }
}

// MARK: - 调试面板视图（仅 iOS）

#if DEBUG
struct DebugPanelView: View {
    @StateObject private var debugManager = DebugManager.shared
    @ObservedObject var viewModel: PetViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("快速操作")) {
                    Button("添加 1000 XP") {
                        debugManager.addXPForTesting(viewModel, xp: 1000)
                    }
                    
                    Button("强制进化") {
                        debugManager.forceEvolution(viewModel)
                    }
                    
                    Button("重置为 Lv1") {
                        debugManager.resetToLevel1(viewModel)
                    }
                    
                    Button("模拟 HealthKit 数据") {
                        debugManager.simulateHealthData(viewModel)
                    }
                }
                
                Section(header: Text("等级设置")) {
                    Button("设为 Lv1") {
                        debugManager.setLevel(viewModel, level: .level1)
                    }
                    
                    Button("设为 Lv2") {
                        debugManager.setLevel(viewModel, level: .level2)
                    }
                    
                    Button("设为 Lv3") {
                        debugManager.setLevel(viewModel, level: .level3)
                    }
                }
                
                Section(header: Text("模拟数据设置")) {
                    HStack {
                        Text("卡路里")
                        Spacer()
                        TextField("卡路里", value: $debugManager.mockCalories, format: .number)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("步数")
                        Spacer()
                        TextField("步数", value: $debugManager.mockSteps, format: .number)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section(header: Text("测试")) {
                    Button("测试所有通知") {
                        debugManager.testAllNotifications()
                    }
                    
                    Button("解锁所有成就") {
                        debugManager.unlockAllAchievements()
                    }
                    
                    Button("打印当前状态") {
                        debugManager.printCurrentState(viewModel)
                    }
                }
                
                Section(header: Text("危险操作")) {
                    Button("清除所有数据") {
                        debugManager.clearAllData()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("当前状态")) {
                    LabeledContent("等级", value: viewModel.pet.level.displayName)
                    LabeledContent("经验值", value: "\(viewModel.pet.currentXP)/\(viewModel.pet.requiredXP)")
                    LabeledContent("今日XP", value: "\(viewModel.todayXP)")
                    LabeledContent("卡路里", value: String(format: "%.0f", viewModel.todayCalories))
                    LabeledContent("步数", value: "\(viewModel.todaySteps)")
                    LabeledContent("状态", value: viewModel.pet.state.displayName)
                }
            }
            .navigationTitle("调试面板")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif

// MARK: - 日志管理器

/// 应用日志管理器
class LogManager {
    
    static let shared = LogManager()
    
    private var logs: [LogEntry] = []
    private let maxLogs = 100
    
    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let level: LogLevel
        let message: String
        let file: String
        let function: String
        let line: Int
    }
    
    enum LogLevel: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        var color: Color {
            switch self {
            case .debug:
                return .gray
            case .info:
                return .blue
            case .warning:
                return .orange
            case .error:
                return .red
            }
        }
    }
    
    func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let entry = LogEntry(
            timestamp: Date(),
            level: level,
            message: message,
            file: (file as NSString).lastPathComponent,
            function: function,
            line: line
        )
        
        logs.append(entry)
        
        // 限制日志数量
        if logs.count > maxLogs {
            logs.removeFirst(logs.count - maxLogs)
        }
        
        // 打印到控制台
        print("[\(level.rawValue)] \(message) - \(file):\(line)")
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    func getLogs() -> [LogEntry] {
        return logs
    }
    
    func clearLogs() {
        logs.removeAll()
    }
}

// MARK: - 日志查看视图（仅 iOS）

#if os(iOS)
struct LogViewerView: View {
    @State private var logs: [LogManager.LogEntry] = []
    @State private var selectedLevel: LogManager.LogLevel?
    
    var filteredLogs: [LogManager.LogEntry] {
        if let level = selectedLevel {
            return logs.filter { $0.level == level }
        }
        return logs
    }
    
    var body: some View {
        VStack {
            // 筛选器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    FilterChip(title: "全部", isSelected: selectedLevel == nil) {
                        selectedLevel = nil
                    }
                    
                    ForEach(LogManager.LogLevel.allCases, id: \.self) { level in
                        FilterChip(
                            title: level.rawValue,
                            isSelected: selectedLevel == level,
                            color: level.color
                        ) {
                            selectedLevel = level
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 日志列表
            List(filteredLogs) { log in
                LogEntryRow(entry: log)
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("日志")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("清除") {
                    LogManager.shared.clearLogs()
                    refreshLogs()
                }
            }
        }
        .onAppear {
            refreshLogs()
        }
    }
    
    private func refreshLogs() {
        logs = LogManager.shared.getLogs()
    }
}
#endif

// MARK: - 筛选芯片

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - 日志行

struct LogEntryRow: View {
    let entry: LogManager.LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.level.rawValue)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(entry.level.color)
                
                Spacer()
                
                Text(formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.message)
                .font(.caption)
            
            Text("\(entry.file):\(entry.line)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: entry.timestamp)
    }
}

// MARK: - 便捷宏

#if DEBUG
func debugLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    LogManager.shared.debug(message, file: file, function: function, line: line)
}
#else
func debugLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {}
#endif
