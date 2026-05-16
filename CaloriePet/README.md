# CaloriePet - 卡路里养电子宠物

一款通过完成每日卡路里消耗和步数目标来喂养虚拟宠物的 iOS + Apple Watch 应用。

## 功能特点

- 🐣 **宠物进化系统**：3个进化阶段（Lv1 → Lv2 → Lv3）
- 🔥 **经验值计算**：卡路里 × 1.0 + 步数 × 0.1
- 📱 **双端同步**：iPhone 和 Apple Watch 数据实时同步
- 📊 **健康数据**：通过 HealthKit 读取活动数据
- 📈 **历史记录**：追踪每日达标情况

## 项目结构

```
CaloriePet/
├── Shared/                     # 共享代码（iPhone + Watch）
│   ├── Pet.swift              # 宠物数据模型
│   ├── HealthKitManager.swift # HealthKit 数据读取
│   ├── WatchConnectivityManager.swift  # 设备间同步
│   └── PetViewModel.swift     # 宠物状态管理
├── iPhone/                     # iPhone 应用代码
│   ├── CaloriePetApp.swift    # iOS 应用入口
│   └── ContentView.swift      # iOS 主界面
├── Watch/                      # Apple Watch 应用代码
│   ├── CaloriePetWatchApp.swift  # Watch 应用入口
│   └── ContentView_Watch.swift   # Watch 主界面
└── Config/                     # 配置文件
    ├── Info_iPhone.plist      # iOS Info.plist
    └── Info_Watch.plist       # Watch Info.plist
```

## 配置步骤

### 1. 创建 Xcode 项目

1. 打开 Xcode，创建新的 iOS App 项目
2. 添加 Watch App Target（File → New → Target → Watch App）

### 2. 配置 App Groups

1. 选择 iPhone Target → Signing & Capabilities
2. 点击 "+ Capability"，添加 "App Groups"
3. 创建新的 Group ID（如 `group.com.yourcompany.caloriepet`）
4. 对 Watch Target 重复上述步骤，使用相同的 Group ID
5. 修改 `Pet.swift` 中的 `AppConfig.appGroupIdentifier`

### 3. 配置 HealthKit

1. 选择 iPhone Target → Signing & Capabilities
2. 点击 "+ Capability"，添加 "HealthKit"
3. 勾选 "Active Energy" 和 "Step Count"
4. 对 Watch Target 重复上述步骤

### 4. 配置 Bundle Identifier

确保 iPhone App 和 Watch App 的 Bundle ID 匹配：
- iPhone: `com.yourcompany.caloriepet`
- Watch: `com.yourcompany.caloriepet.watch`
- Watch Extension: `com.yourcompany.caloriepet.watch.extension`

### 5. 复制代码文件

将代码文件复制到对应的 Target：

**Shared 文件夹**（添加到 iPhone 和 Watch Target）：
- Pet.swift
- HealthKitManager.swift
- WatchConnectivityManager.swift
- PetViewModel.swift

**iPhone 文件夹**（仅 iPhone Target）：
- CaloriePetApp.swift
- ContentView.swift

**Watch 文件夹**（仅 Watch Target）：
- CaloriePetWatchApp.swift
- ContentView_Watch.swift

## 宠物系统

### 进化阶段

| 等级 | 名称 | 所需经验值 | 外观 |
|------|------|------------|------|
| Lv1 | 幼年期 | 0 | 🥚 蛋宝宝 |
| Lv2 | 成长期 | 10,000 | 🐦 小鸟兽 |
| Lv3 | 完全体 | 30,000 | 🔥 烈焰凤凰 |

### 经验值计算

```
今日经验值 = 今日消耗卡路里 × 1.0 + 今日步数 × 0.1
```

### 宠物状态

- 😊 **开心**：今日获得较多经验值
- 😐 **普通**：正常状态
- 😟 **饿了**：超过12小时未更新

## 技术要点

### HealthKit 数据读取

```swift
// 读取活动消耗卡路里
HKQuantityType.activeEnergyBurned

// 读取步数
HKQuantityType.stepCount
```

### Watch Connectivity 同步

- 使用 `WCSession` 进行双向通信
- 支持实时消息 (`sendMessage`) 和后台传输 (`transferUserInfo`)
- 数据通过 App Groups 共享

### 数据存储

- 使用 `UserDefaults` + `App Groups` 实现数据共享
- 宠物数据编码为 JSON 存储
- 支持每日自动重置

## 开发注意事项

1. **HealthKit 授权**：首次启动时需要用户授权访问健康数据
2. **Watch 配对**：Watch App 需要与 iPhone 配对才能正常工作
3. **数据同步**：iPhone 是主数据源，Watch 通过 Watch Connectivity 同步
4. **后台刷新**：应用进入后台时会自动保存数据

## 测试建议

1. 在模拟器中测试界面布局
2. 在真机上测试 HealthKit 数据读取
3. 测试 iPhone 和 Watch 之间的数据同步
4. 验证宠物进化逻辑
5. 测试每日数据重置功能

## 许可证

MIT License
