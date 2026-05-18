import SwiftUI

struct ContentView_Watch: View {
    @StateObject private var viewModel = PetViewModel()
    @State private var showingFeedSheet = false
    @State private var showingExerciseSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 宠物显示区域
                petDisplayView
                
                // 状态信息
                statusView
                
                // 操作按钮
                actionButtons
                
                // 成就展示
                achievementsView
            }
            .padding()
        }
    }
    
    // MARK: - 宠物显示视图
    private var petDisplayView: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 100, height: 100)
            
            // 宠物表情
            Text(petEmoji)
                .font(.system(size: 50))
                .grayscale(viewModel.pet.state == .dizzy ? 1.0 : 0.0)
            
            // 饿晕时的旋转星星动画
            if viewModel.pet.state == .dizzy {
                dizzyAnimationView
            }
        }
        .frame(height: 120)
    }
    
    // 饿晕动画视图
    private var dizzyAnimationView: some View {
        ZStack {
            ForEach(0..<3) { i in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 12))
                    .offset(
                        x: 35 * cos(Double(i) * 2.0 * .pi / 3.0),
                        y: 35 * sin(Double(i) * 2.0 * .pi / 3.0)
                    )
                    .rotationEffect(.degrees(Double(i) * 120))
            }
        }
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
    
    @State private var rotationAngle: Double = 0
    
    // 背景颜色
    private var backgroundColor: Color {
        switch viewModel.pet.state {
        case .normal: return .green.opacity(0.3)
        case .happy: return .yellow.opacity(0.3)
        case .sad: return .blue.opacity(0.3)
        case .hungry: return .orange.opacity(0.3)
        case .dizzy: return .gray.opacity(0.3)
        case .sleeping: return .purple.opacity(0.3)
        case .exercising: return .red.opacity(0.3)
        }
    }
    
    // 宠物表情
    private var petEmoji: String {
        switch viewModel.pet.state {
        case .normal: return "🐶"
        case .happy: return "🥰"
        case .sad: return "😢"
        case .hungry: return "🤤"
        case .dizzy: return "😵"
        case .sleeping: return "😴"
        case .exercising: return "💪"
        }
    }
    
    // MARK: - 状态视图
    private var statusView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.pet.name)
                .font(.headline)
            
            HStack {
                Text("状态: \(viewModel.pet.state.rawValue)")
                    .font(.caption)
                    .foregroundColor(statusColor)
                Spacer()
            }
            
            // 卡路里进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(calorieColor)
                        .frame(width: calorieWidth(in: geo.size.width), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text("卡路里: \(viewModel.pet.calories)/1000")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // 饿晕提示
            if viewModel.pet.state == .dizzy {
                Text("⚠️ 饿晕了！快喂食恢复")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
    }
    
    // 状态颜色
    private var statusColor: Color {
        switch viewModel.pet.state {
        case .normal: return .green
        case .happy: return .yellow
        case .sad: return .blue
        case .hungry: return .orange
        case .dizzy: return .gray
        case .sleeping: return .purple
        case .exercising: return .red
        }
    }
    
    // 卡路里颜色
    private var calorieColor: Color {
        if viewModel.pet.calories < 200 {
            return .red
        } else if viewModel.pet.calories < 500 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func calorieWidth(in totalWidth: CGFloat) -> CGFloat {
        let ratio = CGFloat(viewModel.pet.calories) / 1000.0
        return totalWidth * min(max(ratio, 0), 1)
    }
    
    // MARK: - 操作按钮
    private var actionButtons: some View {
        HStack(spacing: 8) {
            Button(action: { showingFeedSheet = true }) {
                VStack {
                    Image(systemName: "fork.knife")
                    Text("喂食")
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(8)
            .background(Color.orange.opacity(0.3))
            .cornerRadius(8)
            
            Button(action: { showingExerciseSheet = true }) {
                VStack {
                    Image(systemName: "figure.run")
                    Text("运动")
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(8)
            .background(Color.green.opacity(0.3))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showingFeedSheet) {
            FeedSheetView(viewModel: viewModel, isPresented: $showingFeedSheet)
        }
        .sheet(isPresented: $showingExerciseSheet) {
            ExerciseSheetView(viewModel: viewModel, isPresented: $showingExerciseSheet)
        }
    }
    
    // MARK: - 成就视图
    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("最近成就")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if viewModel.currentAchievements.isEmpty {
                Text("暂无成就")
                    .font(.caption2)
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.currentAchievements.prefix(3)) { achievement in
                    HStack {
                        Text(achievement.icon)
                        Text(achievement.name)
                            .font(.caption)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - 喂食弹窗
struct FeedSheetView: View {
    @ObservedObject var viewModel: PetViewModel
    @Binding var isPresented: Bool
    @State private var calories = 100
    
    var body: some View {
        VStack {
            Text("喂食")
                .font(.headline)
            
            Stepper("卡路里: \(calories)", value: $calories, in: 50...500, step: 50)
                .padding()
            
            Button("确认") {
                viewModel.feed(calories: calories)
                isPresented = false
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

// MARK: - 运动弹窗
struct ExerciseSheetView: View {
    @ObservedObject var viewModel: PetViewModel
    @Binding var isPresented: Bool
    @State private var calories = 50
    
    var body: some View {
        VStack {
            Text("运动")
                .font(.headline)
            
            Stepper("消耗: \(calories)", value: $calories, in: 10...300, step: 10)
                .padding()
            
            Button("确认") {
                viewModel.exercise(calories: calories)
                isPresented = false
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct ContentView_Watch_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_Watch()
    }
}
