//
//  ContentView.swift
//  CaloriePet (iPhone)
//
//  文件作用：iPhone 应用的主界面
//  包含：宠物展示区、经验值进度条、今日数据展示、历史记录入口
//  使用 SwiftUI 构建，支持动态刷新
//

import SwiftUI
import HealthKit

/// iPhone 主界面
struct ContentView: View {
    
    // MARK: - 状态对象
    
    @StateObject private var viewModel = PetViewModel()
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var watchConnectivityManager = WatchConnectivityManager.shared
    
    // MARK: - 状态变量
    
    @State private var showingHistory = false
    @State private var showingSettings = false
    @State private var showingNameEdit = false
    @State private var showingCollection = false
    @State private var newPetName = ""
    
    // MARK: - 主视图
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 宠物展示区域
                    petDisplaySection
                    
                    // 经验值进度区域
                    xpProgressSection
                    
                    // 今日数据区域
                    todayDataSection
                    
                    // 状态信息
                    statusSection
                    
                    // 刷新按钮
                    refreshButton
                }
                .padding()
            }
            .navigationTitle("CaloriePet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // 连接状态指示器
                        connectionStatusIndicator
                        
                        // 设置按钮
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gear")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        // 图鉴按钮
                        Button(action: { showingCollection = true }) {
                            Image(systemName: "text.book.closed")
                        }

                        // 历史记录按钮
                        Button(action: { showingHistory = true }) {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: viewModel, isPresented: $showingSettings)
            }
            .sheet(isPresented: $showingCollection) {
                HatchView(viewModel: viewModel)
            }
            .alert("给宠物起个名字", isPresented: $showingNameEdit) {
                TextField("宠物名字", text: $newPetName)
                Button("取消", role: .cancel) { }
                Button("确定") {
                    if !newPetName.isEmpty {
                        viewModel.updatePetName(newPetName)
                    }
                }
            }
            .overlay {
                // 进化动画覆盖层
                if viewModel.showEvolutionAnimation {
                    EvolutionAnimationView(
                        family: viewModel.pet.family,
                        level: viewModel.evolutionTargetLevel ?? .level2,
                        isShowing: $viewModel.showEvolutionAnimation
                    )
                }
            }
            .onAppear {
                // 页面出现时刷新数据
                viewModel.manualRefresh()
            }
        }
    }
    
    // MARK: - 子视图
    
    /// 宠物展示区域
    private var petDisplaySection: some View {
        VStack(spacing: 16) {
            // 宠物图标
            ZStack {
                // 背景圆圈
                Circle()
                    .fill(petStateColor.opacity(0.2))
                    .frame(width: 180, height: 180)
                
                // 宠物外观
                PetImageView(pet: viewModel.pet, size: 100)
                
                // 等级徽章
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(viewModel.pet.level.displayName)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .frame(width: 180, height: 180)
            }
            .frame(height: 200)
            
            // 宠物名称（可点击编辑）
            Button(action: {
                newPetName = viewModel.pet.name
                showingNameEdit = true
            }) {
                HStack {
                    Text(viewModel.pet.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 外观描述
            Text(viewModel.pet.appearanceDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // 家族属性
            Text(viewModel.pet.family.element)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    /// 经验值进度区域
    private var xpProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("经验值进度")
                    .font(.headline)
                
                Spacer()
                
                // 今日获得经验值
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("+\(viewModel.todayXP) 今日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                    
                    // 进度
                    RoundedRectangle(cornerRadius: 8)
                        .fill(progressGradient)
                        .frame(width: geometry.size.width * viewModel.pet.progressToNextLevel, height: 16)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.pet.progressToNextLevel)
                }
            }
            .frame(height: 16)
            
            // 进度信息
            HStack {
                Text("\(viewModel.pet.currentXP) / \(viewModel.pet.requiredXP) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if viewModel.pet.level != .level3 {
                    Text("还需 \(viewModel.xpToNextLevel) XP 升级")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("已满级！")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    /// 今日数据区域
    private var todayDataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日活动")
                .font(.headline)
            
            HStack(spacing: 20) {
                // 卡路里
                ActivityCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    title: "卡路里",
                    value: String(format: "%.0f", viewModel.todayCalories),
                    unit: "千卡",
                    goal: AppConfig.dailyCalorieGoal,
                    current: viewModel.todayCalories
                )
                
                // 步数
                ActivityCard(
                    icon: "shoeprints.fill",
                    iconColor: .green,
                    title: "步数",
                    value: "\(viewModel.todaySteps)",
                    unit: "步",
                    goal: Double(AppConfig.dailyStepsGoal),
                    current: Double(viewModel.todaySteps)
                )
            }
            
            // 经验值计算公式说明
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.secondary)
                Text("经验值 = 卡路里 × 1.0 + 步数 × 0.1")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    /// 状态信息区域
    private var statusSection: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(petStateColor)
            
            Text(viewModel.petStatusDescription)
                .font(.subheadline)
            
            Spacer()
            
            // 连接状态
            HStack(spacing: 4) {
                Circle()
                    .fill(watchConnectivityManager.isReachable ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                Text(watchConnectivityManager.isReachable ? "已连接" : "未连接")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    /// 刷新按钮
    private var refreshButton: some View {
        Button(action: { viewModel.manualRefresh() }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                Text(viewModel.isLoading ? "刷新中..." : "刷新数据")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
    }
    
    /// 连接状态指示器
    private var connectionStatusIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "applewatch")
                .font(.caption)
            Circle()
                .fill(watchConnectivityManager.isReachable ? Color.green : Color.red)
                .frame(width: 6, height: 6)
        }
    }
    
    // MARK: - 辅助属性
    
    /// 根据宠物状态返回颜色
    private var petStateColor: Color {
        switch viewModel.pet.state {
        case .happy:
            return .green
        case .normal:
            return .orange
        case .hungry:
            return .red
        }
    }
    
    /// 状态图标
    private var statusIcon: String {
        switch viewModel.pet.state {
        case .happy:
            return "face.smiling.fill"
        case .normal:
            return "face.neutral.fill"
        case .hungry:
            return "face.dashed.fill"
        }
    }
    
    /// 进度条渐变色
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - 活动数据卡片

struct ActivityCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    let goal: Double
    let current: Double
    
    var progress: Double {
        return min(current / goal, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // 图标
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 50, height: 50)
                .background(iconColor.opacity(0.2))
                .cornerRadius(12)
            
            // 数值
            VStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 进度环
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(iconColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
            .frame(width: 40, height: 40)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - 历史记录视图

struct HistoryView: View {
    @ObservedObject var viewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("最近 30 天")) {
                    if viewModel.getHistory().isEmpty {
                        Text("暂无历史记录")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.getHistory(), id: \.date) { record in
                            HistoryRow(date: record.date, achieved: record.achieved)
                        }
                    }
                }
                
                Section(header: Text("统计")) {
                    let history = viewModel.getHistory()
                    let achievedCount = history.filter { $0.achieved }.count
                    
                    HStack {
                        Text("达标天数")
                        Spacer()
                        Text("\(achievedCount) 天")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("总记录天数")
                        Spacer()
                        Text("\(history.count) 天")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 历史记录行

struct HistoryRow: View {
    let date: String
    let achieved: Bool
    
    var body: some View {
        HStack {
            Image(systemName: achieved ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(achieved ? .green : .red)
            
            Text(formattedDate)
            
            Spacer()
            
            Text(achieved ? "达标" : "未达标")
                .font(.caption)
                .foregroundColor(achieved ? .green : .red)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: date) {
            formatter.dateFormat = "M月d日"
            return formatter.string(from: date)
        }
        return date
    }
}

// MARK: - 设置视图

struct SettingsView: View {
    @ObservedObject var viewModel: PetViewModel
    @Binding var isPresented: Bool
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("宠物")) {
                    HStack {
                        Text("当前等级")
                        Spacer()
                        Text(viewModel.pet.level.displayName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("总经验值")
                        Spacer()
                        Text("\(viewModel.totalXP) XP")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("重置宠物数据") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Text("CaloriePet 通过读取您的健康数据来帮助您养成运动习惯。数据仅存储在本地，不会上传到任何服务器。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        isPresented = false
                    }
                }
            }
            .alert("确认重置？", isPresented: $showingResetAlert) {
                Button("取消", role: .cancel) { }
                Button("重置", role: .destructive) {
                    viewModel.resetPet()
                    isPresented = false
                }
            } message: {
                Text("这将清除所有宠物数据，包括等级、经验值和历史记录。此操作不可撤销。")
            }
        }
    }
}

// MARK: - 图鉴 / 孵蛋视图

struct HatchView: View {
    @ObservedObject var viewModel: PetViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - 孵化动画状态

    @State private var isHatching = false
    @State private var hatchPhase: HatchPhase = .idle
    @State private var eggShakeAmount: CGFloat = 0
    @State private var eggScale: CGFloat = 1.0
    @State private var hatchResultFamily: PetFamily?
    @State private var showHatchResult = false

    /// 孵化动画阶段
    enum HatchPhase {
        case idle       // 未开始
        case shaking    // 蛋摇晃
        case cracking   // 蛋裂开
        case revealed   // 展示结果
    }

    // MARK: - 计算属性

    /// 是否有足够的经验值孵化
    private var canAffordHatch: Bool {
        return viewModel.pet.todayXP >= AppConfig.hatchCostXP
    }

    /// 收集进度文本
    private var collectionProgressText: String {
        return "已收集 \(viewModel.pet.ownedFamilies.count)/\(PetFamily.allCases.count)"
    }

    // MARK: - 主视图

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 收集进度
                    collectionHeader

                    // 孵蛋区域
                    hatchSection

                    // 家族图鉴网格
                    familyCollectionView
                }
                .padding()
            }
            .navigationTitle("宠物图鉴")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .overlay {
                // 孵化结果覆盖层
                if showHatchResult, let newFamily = hatchResultFamily {
                    hatchResultOverlay(family: newFamily)
                }
            }
        }
    }

    // MARK: - 子视图

    /// 收集进度头部
    private var collectionHeader: some View {
        VStack(spacing: 8) {
            Text(collectionProgressText)
                .font(.title3)
                .fontWeight(.bold)

            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * Double(viewModel.pet.ownedFamilies.count) / Double(PetFamily.allCases.count),
                            height: 12
                        )
                        .animation(.easeInOut(duration: 0.5), value: viewModel.pet.ownedFamilies.count)
                }
            }
            .frame(height: 12)

            if viewModel.pet.isCollectionComplete {
                Text("恭喜！图鉴已集齐！")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    /// 孵蛋区域
    private var hatchSection: some View {
        VStack(spacing: 20) {
            Text("消耗 \(AppConfig.hatchCostXP) XP 孵化新宠物")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // 蛋的展示
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 160, height: 160)

                if hatchPhase == .idle || hatchPhase == .shaking {
                    // 蛋图标
                    Image(systemName: "egg.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.purple)
                        .rotationEffect(.degrees(eggShakeAmount))
                        .scaleEffect(eggScale)
                        .symbolEffect(.bounce, options: .repeating, value: hatchPhase == .shaking)
                } else if hatchPhase == .cracking {
                    // 裂开的蛋
                    Image(systemName: "egg.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.purple.opacity(0.5))
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundColor(.yellow)
                        )
                }
            }
            .frame(height: 180)

            // 孵蛋按钮
            Button(action: {
                startHatching()
            }) {
                HStack {
                    if isHatching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(isHatching ? "孵化中..." : "孵化新宠物")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canAffordHatch && !isHatching ? Color.purple : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!canAffordHatch || isHatching)

            if !canAffordHatch && !isHatching {
                Text("今日经验值不足，继续运动获取更多 XP 吧！")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    /// 家族图鉴网格
    private var familyCollectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("家族图鉴")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(PetFamily.allCases, id: \.self) { family in
                    familyCard(for: family)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    /// 单个家族卡片
    private func familyCard(for family: PetFamily) -> some View {
        let isOwned = viewModel.pet.ownedFamilies.contains(family)

        return VStack(spacing: 8) {
            // 家族名称
            Text(family.chineseName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isOwned ? .primary : .secondary)

            // 3 个等级的小图
            HStack(spacing: 4) {
                ForEach(PetLevel.allCases, id: \.self) { level in
                    if isOwned {
                        PetImageView(family: family, level: level, size: 30)
                    } else {
                        // 未拥有：显示问号剪影
                        Image(systemName: "questionmark")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 30, height: 30)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }

            // 属性标签
            Text(family.element)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(isOwned ? Color(.secondarySystemBackground) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isOwned ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }

    /// 孵化结果覆盖层
    private func hatchResultOverlay(family: PetFamily) -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("新宠物！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                // 光效
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: family.primaryColorHex).opacity(0.6), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)

                // 新宠物 Lv1
                PetImageView(family: family, level: .level1, size: 100)

                Text(family.chineseName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(family.descriptionLv1)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Text(family.element)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                Button("收下！") {
                    withAnimation {
                        showHatchResult = false
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(25)
                .padding(.top, 12)
            }
        }
        .transition(.opacity)
    }

    // MARK: - 孵化逻辑

    /// 开始孵化流程
    private func startHatching() {
        guard canAffordHatch, !isHatching else { return }

        isHatching = true

        // 阶段1：蛋摇晃
        hatchPhase = .shaking
        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
            eggShakeAmount = 8
        }

        // 阶段2：蛋裂开（1.5秒后）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                hatchPhase = .cracking
                eggShakeAmount = 0
                eggScale = 1.2
            }
        }

        // 阶段3：展示结果（2.5秒后）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            performHatch()
        }
    }

    /// 执行孵化（扣除经验值，随机获取家族）
    private func performHatch() {
        // 随机获取一个未拥有的家族
        let newFamily = PetFamily.randomUnowned(from: viewModel.pet.ownedFamilies)

        if let newFamily = newFamily {
            // 扣除经验值
            viewModel.pet.todayXP -= AppConfig.hatchCostXP
            if viewModel.pet.todayXP < 0 {
                viewModel.pet.todayXP = 0
            }

            // 添加到已拥有列表
            viewModel.pet.ownedFamilies.insert(newFamily)
            viewModel.pet.totalHatches += 1
            viewModel.pet.saveToStorage()

            // 展示结果
            hatchResultFamily = newFamily
            withAnimation {
                showHatchResult = true
            }
        } else {
            // 已经集齐所有家族
            hatchResultFamily = nil
        }

        // 重置孵化状态
        isHatching = false
        withAnimation {
            hatchPhase = .idle
            eggScale = 1.0
        }
    }
}

// MARK: - 进化动画视图

struct EvolutionAnimationView: View {
    let family: PetFamily?
    let level: PetLevel
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("进化！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 进化动画
                ZStack {
                    // 光效
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.yellow.opacity(0.8), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .scaleEffect(scale)
                    
                    // 宠物图标
                    PetImageView(family: family ?? .flamepaw, level: level, size: 120)
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(scale)
                }
                
                Text("进化为 \(level.displayName)！")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(family?.description(for: level) ?? "")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
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
                .padding(.top, 20)
            }
        }
        .onAppear {
            // 启动动画
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - 预览

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}