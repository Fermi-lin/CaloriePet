//
//  CaloriePetWatchApp.swift
//  CaloriePet Watch App
//
//  文件作用：Apple Watch 应用的入口点
//  负责：激活 Watch Connectivity、设置应用生命周期
//  Watch 端通过 Watch Connectivity 与 iPhone 同步数据
//

import SwiftUI

@main
struct CaloriePetWatchApp: App {
    
    // MARK: - 场景
    
    var body: some Scene {
        WindowGroup {
            ContentView_Watch()
                .onAppear {
                    // 激活 Watch Connectivity
                    WatchConnectivityManager.shared.activateSession()
                }
        }
    }
}
