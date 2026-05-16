# CaloriePet 完整配置指南

## 📋 实现步骤概览

```
步骤1: 创建 Xcode 项目
    ↓
步骤2: 配置 App Groups
    ↓
步骤3: 配置 HealthKit
    ↓
步骤4: 配置 Watch App
    ↓
步骤5: 复制代码文件
    ↓
步骤6: 添加美术资源（可选）
    ↓
步骤7: 构建运行
```

---

## 步骤 1: 创建 Xcode 项目

### 1.1 创建 iOS 项目
1. 打开 Xcode（需要 Xcode 14.0+）
2. File → New → Project
3. 选择 "iOS" → "App"
4. 填写项目信息：
   - **Name**: `CaloriePet`
   - **Team**: 选择你的 Apple ID
   - **Organization Identifier**: `com.yourcompany`（替换为你的）
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: `None`

### 1.2 项目设置
1. 选择项目文件（左侧最顶部的 CaloriePet）
2. 在 General 标签页：
   - **Deployment Info**: iOS 16.0+
   - **Device Orientation**: 只勾选 Portrait

---

## 步骤 2: 配置 App Groups

App Groups 是 iPhone 和 Apple Watch 共享数据的关键。

### 2.1 为 iPhone App 配置
1. 选择 `CaloriePet` Target
2. 点击 "Signing & Capabilities" 标签
3. 点击 "+ Capability"
4. 搜索并添加 "App Groups"
5. 点击 "+" 添加新的 Group ID：
   ```
   group.com.yourcompany.caloriepet
   ```
   ⚠️ **重要**: 替换 `com.yourcompany` 为你自己的 Organization Identifier

### 2.2 修改代码中的 Group ID
打开 `Shared/Pet.swift`，修改：
```swift
struct AppConfig {
    static let appGroupIdentifier = "group.com.yourcompany.caloriepet"  // 修改这里
    // ...
}
```

---

## 步骤 3: 配置 HealthKit

### 3.1 添加 HealthKit Capability
1. 选择 `CaloriePet` Target
2. 点击 "+ Capability"
3. 搜索并添加 "HealthKit"
4. 勾选：
   - ☑️ Active Energy
   - ☑️ Step Count

### 3.2 配置 Info.plist
1. 打开 `CaloriePet/Info.plist`
2. 添加以下键值：
   ```xml
   <key>NSHealthShareUsageDescription</key>
   <string>CaloriePet 需要访问您的健康数据来计算宠物经验值。数据仅用于本地计算，不会上传到服务器。</string>
   <key>NSHealthUpdateUsageDescription</key>
   <string>CaloriePet 需要访问您的健康数据来计算宠物经验值。</string>
   ```

---

## 步骤 4: 添加 Watch App Target

### 4.1 创建 Watch App
1. File → New → Target
2. 选择 "watchOS" → "App"
3. 填写信息：
   - **Product Name**: `CaloriePetWatch`
   - **Team**: 选择相同的 Apple ID
   - **Language**: `Swift`
   - **Interface**: `SwiftUI`
4. 勾选 "Include Notification Scene"（可选）
5. 点击 "Finish"
6. 出现提示时，点击 "Activate"

### 4.2 配置 Watch App 的 App Groups
1. 选择 `CaloriePetWatch` Target
2. 点击 "Signing & Capabilities"
3. 点击 "+ Capability"
4. 添加 "App Groups"
5. **必须选择相同的 Group ID**: `group.com.yourcompany.caloriepet`

### 4.3 配置 Watch App 的 HealthKit
1. 选择 `CaloriePetWatch` Target
2. 点击 "+ Capability"
3. 添加 "HealthKit"
4. 勾选相同的权限

---

## 步骤 5: 复制代码文件

### 5.1 创建文件夹结构
在 Xcode 项目中创建以下 Groups（右键点击项目 → New Group）：
```
CaloriePet/
├── Shared/          (新建)
├── iPhone/          (新建)
└── Watch/           (新建)
```

### 5.2 添加 Shared 文件
将以下文件添加到 **Shared** 文件夹，并**同时勾选 iPhone 和 Watch Target**：

1. `Pet.swift`
2. `PetAssets.swift`（新增的美术系统）
3. `PetInteraction.swift`（新增的交互系统）
4. `PetViewModel.swift`
5. `HealthKitManager.swift`
6. `WatchConnectivityManager.swift`
7. `NotificationManager.swift`（新增的通知系统）
8. `AchievementSystem.swift`（新增的成就系统）

**添加方法**：
1. 右键点击 Shared 文件夹 → "Add Files to CaloriePet"
2. 选择文件
3. 在底部勾选 Targets：
   - ☑️ CaloriePet
   - ☑️ CaloriePetWatch

### 5.3 添加 iPhone 文件
将以下文件添加到 **iPhone** 文件夹，**只勾选 CaloriePet Target**：

1. `CaloriePetApp.swift`
2. `ContentView.swift`

### 5.4 添加 Watch 文件
将以下文件添加到 **Watch** 文件夹，**只勾选 CaloriePetWatch Target**：

1. `CaloriePetWatchApp.swift`
2. `ContentView_Watch.swift`

### 5.5 删除默认文件
删除 Xcode 自动生成的以下文件：
- `ContentView.swift`（在 CaloriePet 文件夹中）
- `CaloriePetApp.swift`（在 CaloriePet 文件夹中）
- `ContentView.swift`（在 CaloriePetWatch 文件夹中）

---

## 步骤 6: 更新 ContentView 使用新功能

### 6.1 修改 iPhone/ContentView.swift
在 `petDisplaySection` 中，将原来的宠物展示替换为可交互版本：

找到这段代码：
```swift
// 宠物展示区
Image(systemName: viewModel.pet.appearance.rawValue)
    // ...
```

替换为：
```swift
// 可交互宠物展示
InteractivePetView(viewModel: viewModel)
    .frame(height: 200)
```

在 `statusSection` 后面添加交互面板：
```swift
// 交互面板
PetInteractionPanel(viewModel: viewModel)
```

### 6.2 添加成就页面入口
在 `SettingsView` 中添加：
```swift
Section(header: Text("游戏")) {
    NavigationLink("成就") {
        AchievementListView()
    }
    
    NavigationLink("通知设置") {
        NotificationSettingsView()
    }
}
```

---

## 步骤 7: 构建和运行

### 7.1 选择 Scheme
1. 在 Xcode 顶部工具栏，点击 Scheme 选择器
2. 选择 `CaloriePet` (iPhone)
3. 或者选择 `CaloriePetWatch` (Apple Watch)

### 7.2 构建项目
1. Product → Build (Cmd+B)
2. 检查是否有错误

### 7.3 运行应用
#### 在 iPhone 模拟器上运行：
1. 选择 iPhone 15 Pro 模拟器
2. 点击运行按钮 (Cmd+R)

#### 在 Apple Watch 模拟器上运行：
1. 选择 "CaloriePetWatch" Scheme
2. 选择 Apple Watch Series 9 模拟器
3. 点击运行按钮

#### 在真机上运行：
1. 连接你的 iPhone
2. 在 Scheme 选择器中选择你的设备
3. 确保已登录 Apple ID 并配置好签名
4. 点击运行按钮

---

## 步骤 8: 添加自定义美术资源（可选）

### 8.1 准备图片资源
为每个等级准备 3 张图片（PNG 格式，推荐 512x512）：
```
Assets.xcassets/
├── pet_level1.imageset/
│   ├── pet_level1.png      (待机)
│   ├── pet_level1_happy.png (开心)
│   └── pet_level1_eating.png (进食)
├── pet_level2.imageset/
│   └── ...
└── pet_level3.imageset/
    └── ...
```

### 8.2 修改 PetAssets.swift
如果使用自定义图片而不是 SF Symbols，修改：
```swift
var mainIcon: String {
    switch level {
    case .level1:
        return "pet_level1"  // 改为图片名
    // ...
    }
}
```

---

## 🔧 常见问题排查

### 问题 1: "App Groups not enabled"
**解决**: 确保在 Signing & Capabilities 中添加了 App Groups，并且 iPhone 和 Watch 使用相同的 Group ID

### 问题 2: "HealthKit is not available"
**解决**: 
- 确保在真机上运行（模拟器 HealthKit 功能有限）
- 检查是否正确添加了 HealthKit Capability

### 问题 3: Watch 和 iPhone 数据不同步
**解决**:
- 确保两者使用相同的 App Group ID
- 确保 Watch 已与 iPhone 配对
- 检查 WatchConnectivityManager 中的 session 是否激活

### 问题 4: 编译错误 "Cannot find type Pet in scope"
**解决**: 确保 Shared 文件夹中的文件已添加到对应的 Target

### 问题 5: 通知不显示
**解决**:
- 确保已请求通知授权
- 在真机上测试（模拟器通知功能有限）
- 检查系统设置中是否允许通知

---

## 📱 使用说明

### 首次使用
1. 打开应用后，允许 HealthKit 授权
2. 允许通知授权（可选）
3. 给你的宠物起个名字

### 日常使用
1. 佩戴 Apple Watch 进行运动
2. 打开应用查看宠物状态
3. 点击宠物进行互动
4. 完成每日目标获得经验值
5. 宠物会自动进化

### 宠物进化条件
- **Lv1 → Lv2**: 累计 10,000 XP
- **Lv2 → Lv3**: 累计 30,000 XP

### 经验值获取
- 每消耗 1 卡路里 = 1 XP
- 每走 1 步 = 0.1 XP
- 抚摸宠物 = 5 XP
- 喂食 = 50 XP
- 玩耍 = 30 XP

---

## 🎨 自定义建议

### 更换宠物外观
修改 `PetAssets.swift` 中的：
```swift
var mainIcon: String { ... }  // 修改 SF Symbols 名称
var gradientColors: [Color] { ... }  // 修改颜色
```

### 调整难度
修改 `Pet.swift` 中的：
```swift
var requiredXPForNextLevel: Int { ... }  // 修改升级所需经验值
```

### 添加新成就
在 `AchievementSystem.swift` 中的 `AchievementType` 枚举添加新案例。

---

## ✅ 完成检查清单

- [ ] Xcode 项目创建成功
- [ ] App Groups 配置正确（iPhone 和 Watch 相同）
- [ ] HealthKit Capability 已添加
- [ ] Watch App Target 已创建
- [ ] 所有代码文件已复制到正确位置
- [ ] 文件已添加到正确的 Target
- [ ] Group ID 已更新到代码中
- [ ] 应用能在 iPhone 上运行
- [ ] 应用能在 Apple Watch 上运行
- [ ] HealthKit 数据能正常读取
- [ ] iPhone 和 Watch 数据能同步

完成以上步骤后，你就可以在 Apple Watch 上养电子宠物了！🎉
