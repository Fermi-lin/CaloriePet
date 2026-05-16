//
//  WatchConnectivityManager.swift
//  CaloriePet
//
//  文件作用：管理 iPhone 和 Apple Watch 之间的数据同步
//  使用 Watch Connectivity 框架实现双向通信
//  负责：session 管理、消息发送、数据接收、状态同步
//

import WatchConnectivity
import Combine

/// Watch Connectivity 管理器
/// 处理 iPhone 和 Apple Watch 之间的所有通信
class WatchConnectivityManager: NSObject, ObservableObject {
    
    // MARK: - 单例模式
    
    static let shared = WatchConnectivityManager()
    
    // MARK: - 发布属性
    
    /// 连接状态
    @Published var isReachable = false
    
    /// 配对状态（仅 iOS 可用）
    @Published var isPaired = false
    
    /// App 是否已安装到 Watch（仅 iOS 可用）
    @Published var isWatchAppInstalled = false
    
    /// 最后接收到的数据
    @Published var lastReceivedData: [String: Any]?
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 同步状态
    @Published var isSyncing = false
    
    // MARK: - 回调闭包
    
    /// 收到数据时的回调
    var onDataReceived: (([String: Any]) -> Void)?
    
    // MARK: - 私有属性
    
    /// WCSession 实例
    private let session = WCSession.default
    
    /// 当前设备类型
    #if os(watchOS)
    private var isWatch: Bool { return true }
    #else
    private var isWatch: Bool { return false }
    #endif
    
    // MARK: - 初始化
    
    private override init() {
        super.init()
        
        // 检查是否支持 Watch Connectivity
        guard WCSession.isSupported() else {
            errorMessage = "此设备不支持 Watch Connectivity"
            return
        }
        
        // 设置代理并激活 session
        session.delegate = self
        session.activate()
    }
    
    // MARK: - 公共方法
    
    /// 激活 session（在应用启动时调用）
    func activateSession() {
        guard session.activationState != .activated else { return }
        session.activate()
    }
    
    /// 发送宠物数据到配对设备
    /// - Parameter pet: 宠物数据
    func sendPetData(_ pet: Pet) {
        guard session.activationState == .activated else {
            errorMessage = "Session 未激活"
            return
        }
        
        guard isReachable else {
            // 如果设备不可达，尝试使用 transferUserInfo（后台传输）
            sendPetDataInBackground(pet)
            return
        }
        
        // 将宠物数据转换为字典
        guard let data = try? JSONEncoder().encode(pet),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            errorMessage = "数据编码失败"
            return
        }
        
        let message = ["petData": dict]
        
        session.sendMessage(message, replyHandler: nil) { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = "发送数据失败: \(error.localizedDescription)"
            }
        }
    }
    
    /// 后台传输宠物数据（当设备不可达时使用）
    /// - Parameter pet: 宠物数据
    func sendPetDataInBackground(_ pet: Pet) {
        guard session.activationState == .activated else {
            errorMessage = "Session 未激活"
            return
        }
        
        // 将宠物数据转换为字典
        guard let data = try? JSONEncoder().encode(pet),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            errorMessage = "数据编码失败"
            return
        }
        
        let userInfo = ["petData": dict]
        session.transferUserInfo(userInfo)
    }
    
    /// 发送同步请求到配对设备
    func requestSync() {
        guard session.activationState == .activated && isReachable else {
            return
        }
        
        let message = ["requestSync": true]
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    /// 发送今日活动数据（从 Watch 到 iPhone）
    /// - Parameters:
    ///   - calories: 卡路里
    ///   - steps: 步数
    func sendActivityData(calories: Double, steps: Int) {
        guard session.activationState == .activated else { return }
        
        let message: [String: Any] = [
            "activityData": [
                "calories": calories,
                "steps": steps,
                "timestamp": Date().timeIntervalSince1970
            ]
        ]
        
        if isReachable {
            session.sendMessage(message, replyHandler: nil) { [weak self] error in
                DispatchQueue.main.async {
                    self?.errorMessage = "发送活动数据失败: \(error.localizedDescription)"
                }
            }
        } else {
            session.transferUserInfo(message)
        }
    }
    
    /// 更新连接状态（通用）
    private func updateConnectionStatus() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isReachable = self.session.isReachable
        }
    }
    
    #if os(iOS)
    /// 更新连接状态（iOS 专用，包含配对信息）
    private func updateConnectionStatusiOS() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isPaired = self.session.isPaired
            self.isWatchAppInstalled = self.session.isWatchAppInstalled
            self.isReachable = self.session.isReachable
        }
    }
    #endif
    
    // MARK: - 数据解析
    
    /// 从接收到的字典解析宠物数据
    /// - Parameter dict: 接收到的字典
    /// - Returns: 解析后的 Pet 对象
    func parsePetData(from dict: [String: Any]) -> Pet? {
        guard let petDict = dict["petData"] as? [String: Any],
              let data = try? JSONSerialization.data(withJSONObject: petDict) else {
            return nil
        }
        
        do {
            let pet = try JSONDecoder().decode(Pet.self, from: data)
            return pet
        } catch {
            print("解析宠物数据失败: \(error)")
            return nil
        }
    }
    
    /// 从接收到的字典解析活动数据
    /// - Parameter dict: 接收到的字典
    /// - Returns: (calories, steps, timestamp) 元组
    func parseActivityData(from dict: [String: Any]) -> (calories: Double, steps: Int, timestamp: Date)? {
        guard let activityDict = dict["activityData"] as? [String: Any],
              let calories = activityDict["calories"] as? Double,
              let steps = activityDict["steps"] as? Int,
              let timestamp = activityDict["timestamp"] as? TimeInterval else {
            return nil
        }
        
        return (calories, steps, Date(timeIntervalSince1970: timestamp))
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    
    /// Session 激活完成回调
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.errorMessage = "Session 激活失败: \(error.localizedDescription)"
            }
            self?.updateConnectionStatus()
        }
    }
    
    /// 收到消息回调（实时传输）
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.handleReceivedData(message)
        }
    }
    
    /// 收到消息回调（带回复）
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.handleReceivedData(message)
        }
        // 发送确认回复
        replyHandler(["received": true])
    }
    
    /// 收到后台传输数据回调
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.handleReceivedData(userInfo)
        }
    }
    
    /// 收到文件传输回调（如果需要传输文件）
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // 本应用不需要文件传输，留空
    }
    
    /// 连接状态改变回调
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.updateConnectionStatus()
        }
    }
    
    /// 处理接收到的数据
    private func handleReceivedData(_ data: [String: Any]) {
        lastReceivedData = data
        
        // 调用外部回调
        onDataReceived?(data)
        
        // 处理同步请求
        if let _ = data["requestSync"] as? Bool {
            // 收到同步请求，触发数据更新
            NotificationCenter.default.post(name: .init("WatchConnectivityDidRequestSync"), object: nil)
        }
    }
}

// MARK: - iOS 专用代理方法

#if os(iOS)
extension WatchConnectivityManager {
    
    /// Watch 配对状态改变回调（iOS 专用）
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.updateConnectionStatusiOS()
        }
    }
    
    /// 收到 Watch 的上下文更新（iOS 专用）
    func session(_ session: WCSession, didUpdate applicationContext: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.handleReceivedData(applicationContext)
        }
    }
}
#endif

// MARK: - 辅助方法

extension WatchConnectivityManager {
    
    /// 获取当前设备的友好名称
    var deviceName: String {
        #if os(iOS)
        return "iPhone"
        #elseif os(watchOS)
        return "Apple Watch"
        #else
        return "Unknown"
        #endif
    }
    
    /// 获取配对设备的友好名称
    var pairedDeviceName: String {
        #if os(iOS)
        return "Apple Watch"
        #elseif os(watchOS)
        return "iPhone"
        #else
        return "Unknown"
        #endif
    }
}
