//
//  PetInteraction.swift
//  CaloriePet
//
//  文件作用：实现宠物交互系统
//  包括：点击互动、喂食、抚摸、玩耍等功能
//  每种交互会影响宠物心情和经验值
//

import SwiftUI
import Combine

// MARK: - 交互类型定义

/// 宠物交互类型
enum InteractionType {
    case tap        // 点击/抚摸
    case feed       // 喂食（消耗卡路里/步数）
    case play       // 玩耍
    case evolve     // 进化
    
    /// 交互名称
    var name: String {
        switch self {
        case .tap:
            return "抚摸"
        case .feed:
            return "喂食"
        case .play:
            return "玩耍"
        case .evolve:
            return "进化"
        }
    }
    
    /// 交互图标
    var icon: String {
        switch self {
        case .tap:
            return "hand.tap.fill"
        case .feed:
            return "leaf.fill"
        case .play:
            return "balloon.fill"
        case .evolve:
            return "sparkles"
        }
    }
    
    /// 获得的经验值
    var xpReward: Int {
        switch self {
        case .tap:
            return 5
        case .feed:
            return 50
        case .play:
            return 30
        case .evolve:
            return 0  // 进化不直接给经验值
        }
    }
    
    /// 冷却时间（秒）
    var cooldown: TimeInterval {
        switch self {
        case .tap:
            return 3
        case .feed:
            return 300  // 5分钟
        case .play:
            return 600  // 10分钟
        case .evolve:
            return 0
        }
    }
}

// MARK: - 交互反馈

/// 交互反馈结构
struct InteractionFeedback {
    let type: InteractionType
    let xpGained: Int
    let message: String
    let animation: PetAnimationType
}

// MARK: - 宠物交互管理器

/// 宠物交互管理器
/// 处理所有用户与宠物的交互逻辑
class PetInteractionManager: ObservableObject {
    
    // MARK: - 单例
    
    static let shared = PetInteractionManager()
    
    // MARK: - 发布属性
    
    /// 最后一次交互时间记录
    @Published private var lastInteractionTimes: [InteractionType: Date] = [:]
    
    /// 当前正在播放的交互动画
    @Published var currentAnimation: PetAnimationType = .idle
    
    /// 交互反馈信息
    @Published var feedbackMessage: String?
    
    /// 是否显示反馈
    @Published var showFeedback = false
    
    /// 连续点击次数（用于检测快速点击）
    @Published var consecutiveTaps = 0
    
    // MARK: - 私有属性
    
    private var tapTimer: Timer?
    private var animationTimer: Timer?
    private var feedbackTimer: Timer?
    
    // MARK: - 交互方法
    
    /// 执行交互
    /// - Parameters:
    ///   - type: 交互类型
    ///   - pet: 当前宠物
    /// - Returns: 交互反馈
    func performInteraction(_ type: InteractionType, with pet: Pet) -> InteractionFeedback? {
        // 检查冷却时间
        if let cooldownRemaining = checkCooldown(for: type), cooldownRemaining > 0 {
            showFeedback(message: "\(type.name)还需要\(Int(cooldownRemaining))秒")
            return nil
        }
        
        // 记录交互时间
        lastInteractionTimes[type] = Date()
        
        // 执行具体交互逻辑
        let feedback: InteractionFeedback
        
        switch type {
        case .tap:
            feedback = performTapInteraction(pet: pet)
        case .feed:
            feedback = performFeedInteraction(pet: pet)
        case .play:
            feedback = performPlayInteraction(pet: pet)
        case .evolve:
            feedback = performEvolveInteraction(pet: pet)
        }
        
        // 显示反馈
        showFeedback(message: feedback.message)
        
        // 播放动画
        playAnimation(feedback.animation, duration: 2.0)
        
        return feedback
    }
    
    /// 点击/抚摸交互
    private func performTapInteraction(pet: Pet) -> InteractionFeedback {
        consecutiveTaps += 1
        
        // 重置连击计时器
        tapTimer?.invalidate()
        tapTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.consecutiveTaps = 0
        }
        
        let message: String
        let xp: Int
        
        // 根据连击次数给予不同反馈
        switch consecutiveTaps {
        case 1...2:
            message = "\(pet.name)看起来很开心！"
            xp = InteractionType.tap.xpReward
        case 3...5:
            message = "\(pet.name)很喜欢被抚摸！"
            xp = InteractionType.tap.xpReward * 2
        default:
            message = "\(pet.name)超级开心！❤️"
            xp = InteractionType.tap.xpReward * 3
        }
        
        return InteractionFeedback(
            type: .tap,
            xpGained: xp,
            message: message,
            animation: .happy
        )
    }
    
    /// 喂食交互
    private func performFeedInteraction(pet: Pet) -> InteractionFeedback {
        let message = "你喂了\(pet.name)，它吃得很香！"
        
        return InteractionFeedback(
            type: .feed,
            xpGained: InteractionType.feed.xpReward,
            message: message,
            animation: .eating
        )
    }
    
    /// 玩耍交互
    private func performPlayInteraction(pet: Pet) -> InteractionFeedback {
        let messages = [
            "\(pet.name)玩得很开心！",
            "\(pet.name)蹦蹦跳跳的！",
            "\(pet.name)充满活力！"
        ]
        
        return InteractionFeedback(
            type: .play,
            xpGained: InteractionType.play.xpReward,
            message: messages.randomElement() ?? messages[0],
            animation: .happy
        )
    }
    
    /// 进化交互
    private func performEvolveInteraction(pet: Pet) -> InteractionFeedback {
        return InteractionFeedback(
            type: .evolve,
            xpGained: 0,
            message: "\(pet.name)开始进化了！",
            animation: .evolution
        )
    }
    
    // MARK: - 辅助方法
    
    /// 检查冷却时间
    /// - Parameter type: 交互类型
    /// - Returns: 剩余冷却时间（秒），nil 表示无冷却记录
    func checkCooldown(for type: InteractionType) -> TimeInterval? {
        guard let lastTime = lastInteractionTimes[type] else {
            return nil
        }
        
        let elapsed = Date().timeIntervalSince(lastTime)
        let remaining = type.cooldown - elapsed
        
        return remaining > 0 ? remaining : nil
    }
    
    /// 检查交互是否可用
    /// - Parameter type: 交互类型
    /// - Returns: 是否可用
    func isInteractionAvailable(_ type: InteractionType) -> Bool {
        if let remaining = checkCooldown(for: type) {
            return remaining <= 0
        }
        return true
    }
    
    /// 获取冷却进度（0.0 - 1.0）
    /// - Parameter type: 交互类型
    /// - Returns: 冷却进度
    func cooldownProgress(for type: InteractionType) -> Double {
        guard let lastTime = lastInteractionTimes[type] else {
            return 1.0
        }
        
        let elapsed = Date().timeIntervalSince(lastTime)
        let progress = elapsed / type.cooldown
        
        return min(max(progress, 0.0), 1.0)
    }
    
    /// 播放动画
    private func playAnimation(_ animation: PetAnimationType, duration: TimeInterval) {
        currentAnimation = animation
        
        // 定时恢复待机动画
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.currentAnimation = .idle
        }
    }
    
    /// 显示反馈信息
    private func showFeedback(message: String) {
        feedbackMessage = message
        showFeedback = true
        
        // 2秒后隐藏
        feedbackTimer?.invalidate()
        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            withAnimation {
                self?.showFeedback = false
            }
        }
    }
}

// MARK: - 交互按钮视图

/// 宠物交互按钮
struct PetInteractionButton: View {
    let type: InteractionType
    let action: () -> Void
    let isAvailable: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // 背景圆圈
                    Circle()
                        .fill(isAvailable ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    // 图标
                    Image(systemName: type.icon)
                        .font(.title3)
                        .foregroundColor(isAvailable ? .blue : .gray)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                
                // 名称
                Text(type.name)
                    .font(.caption)
                    .foregroundColor(isAvailable ? .primary : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isAvailable)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - 交互面板视图

/// 宠物交互面板
struct PetInteractionPanel: View {
    @StateObject private var interactionManager = PetInteractionManager.shared
    @ObservedObject var viewModel: PetViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // 交互按钮行
            HStack(spacing: 20) {
                // 抚摸按钮
                PetInteractionButton(
                    type: .tap,
                    action: { performInteraction(.tap) },
                    isAvailable: true  // 抚摸总是可用
                )
                
                // 喂食按钮
                PetInteractionButton(
                    type: .feed,
                    action: { performInteraction(.feed) },
                    isAvailable: interactionManager.isInteractionAvailable(.feed)
                )
                
                // 玩耍按钮
                PetInteractionButton(
                    type: .play,
                    action: { performInteraction(.play) },
                    isAvailable: interactionManager.isInteractionAvailable(.play)
                )
            }
            
            // 反馈信息
            if interactionManager.showFeedback, let message = interactionManager.feedbackMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.opacity)
            }
        }
    }
    
    /// 执行交互
    private func performInteraction(_ type: InteractionType) {
        if let feedback = interactionManager.performInteraction(type, with: viewModel.pet) {
            // 添加经验值
            viewModel.addXP(feedback.xpGained)
        }
    }
}

// MARK: - 可点击宠物视图

/// 可交互的宠物视图
struct InteractivePetView: View {
    @ObservedObject var viewModel: PetViewModel
    @StateObject private var interactionManager = PetInteractionManager.shared
    
    @State private var isPressed = false
    @State private var showTapEffect = false
    
    var body: some View {
        ZStack {
            // 宠物动画
            PetAnimationView(
                pet: viewModel.pet,
                animationType: interactionManager.currentAnimation
            )
            .frame(width: 150, height: 150)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            
            // 点击特效
            if showTapEffect {
                tapEffect
            }
        }
        .onTapGesture {
            handleTap()
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
    
    /// 点击特效
    private var tapEffect: some View {
        ZStack {
            // 扩散圆圈
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.yellow.opacity(0.6), lineWidth: 2)
                    .frame(width: 50 + CGFloat(index) * 30, height: 50 + CGFloat(index) * 30)
                    .scaleEffect(showTapEffect ? 1.5 : 0.5)
                    .opacity(showTapEffect ? 0 : 1)
            }
            
            // 爱心
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.title)
                .offset(y: showTapEffect ? -50 : 0)
                .opacity(showTapEffect ? 0 : 1)
        }
        .animation(.easeOut(duration: 0.6), value: showTapEffect)
    }
    
    /// 处理点击
    private func handleTap() {
        // 显示点击特效
        showTapEffect = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showTapEffect = false
        }
        
        // 执行交互
        if let feedback = interactionManager.performInteraction(.tap, with: viewModel.pet) {
            viewModel.addXP(feedback.xpGained)
        }
    }
}

// MARK: - 按压事件修饰符

/// 按压事件修饰符
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - 预览

struct PetInteractionPanel_Previews: PreviewProvider {
    static var previews: some View {
        PetInteractionPanel(viewModel: PetViewModel.preview())
            .padding()
    }
}
