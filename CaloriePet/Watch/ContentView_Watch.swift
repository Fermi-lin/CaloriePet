//
//  ContentView_Watch.swift
//  CaloriePet Watch App
//
//  文件作用：Apple Watch 应用的主界面
//  包含：简化版宠物展示、经验值进度、今日数据
//  针对小屏幕优化，突出核心信息
//

import SwiftUI
import WatchKit

/// Apple Watch 主界面
struct ContentView_Watch: View {
    
    // MARK: - 状态对象
    
    @StateObject private var viewModel = PetViewModel()
    @StateObject private var watchConnectivityManager = WatchConnectivityManager.shared
    
    // MARK: - 状态变量
    
    @State private var showingDetail = false
    
    // MARK: - 主视图
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // 宠物展示区域
                petDisplaySection
                
                // 今日数据
                todayDataSection
                
                // 刷新按钮
                refreshButton
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .navigationTitle("CaloriePet")
        .onAppear {
            viewModel.manualRefresh()
        }
    }
    
    // MARK: - 子视图
    
    /// 宠物展示区域
    private var petDisplaySection: some View {
        VStack(spacing: 4) {
            // 宠物图片（无圆圈，突出可爱）
            PetImageView(pet: viewModel.pet, size: 80)
                .shadow(color: Color(hex: viewModel.pet.family.primaryColorHex).opacity(0.35), radius: 10)
            
            // 名称 + 状态小圆点
            HStack(spacing: 6) {
                Text(viewModel.pet.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Circle()
                    .fill(petStateColor)
                    .frame(width: 8, height: 8)
            }
            
            // 等级
            Text(viewModel.pet.level.displayName)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 下半圆弧形进度条（始终显示）
            VStack(spacing: 2) {
                // 下半圆弧（U 形）
                ZStack {
                    // 背景轨道
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .stroke(
                            Color.gray.opacity(0.15),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                    
                    // 进度弧（有进度时显示鲜艳色，无进度时显示浅色底色）
                    Circle()
                        .trim(from: 0, to: max(0.5 * viewModel.pet.progressToNextLevel, 0.02))
                        .stroke(
                            viewModel.pet.currentXP > 0 ? familyGradient : familyLightGradient,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .animation(.easeInOut(duration: 0.5), value: viewModel.pet.progressToNextLevel)
                }
                .frame(width: 130, height: 130)
                .frame(height: 65)
                .offset(y: -65)
                .clipped()
                
                // 经验值数字（有经验值时才显示）
                if viewModel.pet.currentXP > 0 {
                    HStack(spacing: 4) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 9))
                            Text("+\(viewModel.todayXP)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(viewModel.pet.currentXP) / \(viewModel.pet.requiredXP)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    /// 今日数据区域
    private var todayDataSection: some View {
        HStack(spacing: 8) {
            // 卡路里
            WatchActivityCard(
                icon: "flame.fill",
                iconColor: .orange,
                title: "卡路里",
                value: String(format: "%.0f", viewModel.todayCalories),
                unit: "千卡"
            )
            
            // 步数
            WatchActivityCard(
                icon: "shoeprints.fill",
                iconColor: .green,
                title: "步数",
                value: "\(viewModel.todaySteps)",
                unit: "步"
            )
        }
    }
    
    /// 刷新按钮
    private var refreshButton: some View {
        Button(action: { viewModel.manualRefresh() }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.6)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                Text(viewModel.isLoading ? "刷新中" : "刷新")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.blue.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(8)
        .disabled(viewModel.isLoading)
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
    
    /// 进度条渐变色（使用家族主色调）
    private var familyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: viewModel.pet.family.primaryColorHex),
                Color(hex: viewModel.pet.family.gradientColorsHex.1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// 浅色家族色（无进度时显示）
    private var familyLightGradient: LinearGradient {
        let lightColor = Color(hex: viewModel.pet.family.primaryColorHex).opacity(0.25)
        return LinearGradient(
            colors: [lightColor, lightColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Watch 活动数据卡片

struct WatchActivityCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            // 图标
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
                .background(iconColor.opacity(0.2))
                .cornerRadius(6)
            
            // 数值
            Text(value)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .lineLimit(1)
            
            // 单位
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - 预览

struct ContentView_Watch_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_Watch()
    }
}
