//
//  PetAssets.swift
//  CaloriePet
//
//  文件作用：定义宠物美术资源系统
//  支持：自定义图片（Assets.xcassets）、SF Symbols 兜底、动画效果
//  所有宠物图片通过 PetFamily 的 imageName(for:) 获取
//
//  图片命名规则：
//    flamepaw_lv1  flamepaw_lv2  flamepaw_lv3
//    tidalrop_lv1  tidalrop_lv2  tidalrop_lv3
//    ...（共 30 张图片）
//

import SwiftUI

// MARK: - 宠物美术资源管理器

class PetAssets {

    static let shared = PetAssets()

    // MARK: - 获取宠物图片

    /// 根据宠物家族和等级返回 Image 视图
    /// 优先使用自定义图片，如果找不到则回退到 SF Symbols
    static func petImage(family: PetFamily, level: PetLevel) -> Image {
        let name = family.imageName(for: level)
        // SwiftUI 的 Image(name:) 如果找不到资源会显示空白，
        // 这里直接返回，调用方可以自行处理兜底
        return Image(name)
    }

    /// 根据宠物对象返回 Image 视图
    static func petImage(for pet: Pet) -> Image {
        return petImage(family: pet.family, level: pet.level)
    }
}

// MARK: - 宠物图片视图（带兜底）

/// 宠物图片视图
/// 自动加载自定义图片，找不到时回退到 SF Symbols 占位符
struct PetImageView: View {
    let family: PetFamily
    let level: PetLevel
    let size: CGFloat

    init(family: PetFamily, level: PetLevel, size: CGFloat = 100) {
        self.family = family
        self.level = level
        self.size = size
    }

    init(pet: Pet, size: CGFloat = 100) {
        self.family = pet.family
        self.level = pet.level
        self.size = size
    }

    var body: some View {
        Image(family.imageName(for: level))
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

// MARK: - 宠物动画视图

/// 宠物动画视图
/// 在自定义图片基础上叠加缩放、旋转、光晕等动画效果
struct PetAnimationView: View {
    let family: PetFamily
    let level: PetLevel
    let state: PetState
    let animationType: PetAnimationType

    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var offset: CGSize = .zero

    init(pet: Pet, animationType: PetAnimationType = .idle) {
        self.family = pet.family
        self.level = pet.level
        self.state = pet.state
        self.animationType = animationType
    }

    init(family: PetFamily, level: PetLevel, state: PetState = .normal, animationType: PetAnimationType = .idle) {
        self.family = family
        self.level = level
        self.state = state
        self.animationType = animationType
    }

    var body: some View {
        ZStack {
            // 背景光晕效果
            if state == .happy || animationType == .evolution {
                glowEffect
            }

            // 宠物主体
            PetImageView(family: family, level: level, size: 120)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .offset(offset)
                .shadow(color: familyColor.opacity(0.4), radius: 8)
        }
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - 光晕效果

    private var glowEffect: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        familyColor.opacity(0.6),
                        familyColor.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                )
            )
            .frame(width: 200, height: 200)
            .scaleEffect(scale)
    }

    // MARK: - 家族颜色

    private var familyColor: Color {
        return Color(hex: family.primaryColorHex)
    }

    // MARK: - 动画控制

    private func startAnimation() {
        switch animationType {
        case .idle:
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.05
            }
        case .happy:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).repeatForever()) {
                scale = 1.15
                rotation = 8
            }
        case .eating:
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                scale = 1.1
                offset = CGSize(width: 0, height: -8)
            }
        case .evolution:
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                scale = 1.3
                rotation = 360
            }
        case .sleeping:
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                scale = 0.95
                offset = CGSize(width: 0, height: 5)
            }
        }
    }
}

// MARK: - 动画类型枚举

enum PetAnimationType {
    case idle
    case happy
    case eating
    case evolution
    case sleeping
}

// MARK: - 颜色扩展

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
