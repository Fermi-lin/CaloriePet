//
//  CaloriePetWatchApp.swift
//  CaloriePetWatch Watch App
//
//  Created by 冷极冰 on 2026/5/13.
//

import SwiftUI

@main
struct CaloriePetWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView_Watch()
                .onAppear {
                    WatchConnectivityManager.shared.activateSession()
                }
        }
    }
}
