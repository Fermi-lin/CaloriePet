# CaloriePet 完整部署 SOP

> **当前状态**：代码已完成 ✅ | 美术素材已命名 ✅ | 等待系统更新 ⏳

---

## 📋 SOP 总览

```
阶段 A：现在可以做（无需 Xcode）
    ↓
阶段 B：Xcode 项目创建
    ↓
阶段 C：代码文件导入
    ↓
阶段 D：美术素材导入
    ↓
阶段 E：Capabilities 配置
    ↓
阶段 F：Watch App 配置
    ↓
阶段 G：构建测试
```

---

## 阶段 A：现在可以做的准备工作

### A1. 检查美术素材命名

确保你的 30 张图片命名完全正确（区分大小写）：

```
✅ 正确示例：flamepaw_lv1.png
❌ 错误示例：Flamepaw_lv1.png（首字母大写）
❌ 错误示例：flamepaw-Lv1.png（用了横线）
❌ 错误示例：flamepaw lv1.png（用了空格）
```

**完整命名清单**（复制后逐个核对）：

```
flamepaw_lv1.png
flamepaw_lv2.png
flamepaw_lv3.png
tidalrop_lv1.png
tidalrop_lv2.png
tidalrop_lv3.png
sproutling_lv1.png
sproutling_lv2.png
sproutling_lv3.png
zapkit_lv1.png
zapkit_lv2.png
zapkit_lv3.png
frosto_lv1.png
frosto_lv2.png
frosto_lv3.png
pebblem_lv1.png
pebblem_lv2.png
pebblem_lv3.png
breezling_lv1.png
breezling_lv2.png
breezling_lv3.png
shadkit_lv1.png
shadkit_lv2.png
shadkit_lv3.png
solbit_lv1.png
solbit_lv2.png
solbit_lv3.png
funglow_lv1.png
funglow_lv2.png
funglow_lv3.png
```

### A2. 整理代码文件

把代码文件整理到一个文件夹，方便稍后导入：

```
CaloriePet/
├── Shared/                    ← iPhone + Watch 共享
│   ├── Pet.swift
│   ├── PetAssets.swift
│   ├── PetInteraction.swift
│   ├── PetViewModel.swift
│   ├── HealthKitManager.swift
│   ├── WatchConnectivityManager.swift
│   ├── NotificationManager.swift
│   ├── AchievementSystem.swift
│   └── DebugTools.swift
├── iPhone/                    ← 仅 iPhone
│   ├── CaloriePetApp.swift
│   └── ContentView.swift
├── Watch/                     ← 仅 Watch
│   ├── CaloriePetWatchApp.swift
│   └── ContentView_Watch.swift
└── Art/                       ← 美术素材
    ├── flamepaw_lv1.png
    ├── flamepaw_lv2.png
    ├── ...（共30张）
    └── funglow_lv3.png
```

### A3. 准备开发者信息

在 Xcode 配置时需要用到：

| 信息项 | 你的值 | 备注 |
|--------|--------|------|
| Apple ID | ________________ | 用于签名 |
| Team | ________________ | 选择你的开发者账号 |
| Organization Identifier | `com.yourname` | 反向域名格式 |
| App Group ID | `group.com.yourname.caloriepet` | 必须记住这个！ |

**示例**：
- 如果你的 Apple ID 是 `zhangsan@icloud.com`
- Organization Identifier 可以是 `com.zhangsan`
- App Group ID 就是 `group.com.zhangsan.caloriepet`

### A4. 修改代码中的 App Group ID

打开 `Shared/Pet.swift`，找到第 451 行左右：

```swift
struct AppConfig {
    static let appGroupIdentifier = "group.com.yourcompany.caloriepet"
    // ...
}
```

把 `group.com.yourcompany.caloriepet` 改成你的 App Group ID。

---

## 阶段 B：Xcode 项目创建

### B1. 创建 iOS 项目

1. 打开 Xcode
2. `File` → `New` → `Project`
3. 选择 **iOS** → **App**
4. 填写信息：

| 字段 | 填写内容 |
|------|----------|
| Product Name | `CaloriePet` |
| Team | 选择你的 Apple ID |
| Organization Identifier | `com.yourname`（你准备的） |
| Interface | `SwiftUI` |
| Language | `Swift` |
| Storage | `None` |

5. 点击 `Next` → 选择保存位置 → `Create`

### B2. 删除默认文件

Xcode 会自动生成一些文件，需要删除：

1. 在左侧项目导航器中，找到 `ContentView.swift` → 右键 → `Delete` → `Move to Trash`
2. 找到 `CaloriePetApp.swift` → 同样删除

---

## 阶段 C：代码文件导入

### C1. 创建文件夹结构

1. 在左侧项目导航器中，右键点击 `CaloriePet` 文件夹
2. `New Group` → 命名为 `Shared`
3. 再创建 `iPhone` 和 `Watch` 两个 Group

结构应该是：
```
CaloriePet/
├── Shared/
├── iPhone/
├── Watch/
├── Assets.xcassets
├── CaloriePet.entitlements
└── Info.plist
```

### C2. 导入 Shared 文件

1. 右键点击 `Shared` 文件夹
2. `Add Files to "CaloriePet"...`
3. 选择所有 Shared 文件夹中的 `.swift` 文件（9个）
4. **重要**：在底部 `Added folders` 选择 `Create groups`
5. **重要**：在 `Add to targets` 勾选 `CaloriePet`（先只勾这一个）
6. 点击 `Add`

### C3. 导入 iPhone 文件

1. 右键点击 `iPhone` 文件夹
2. `Add Files to "CaloriePet"...`
3. 选择 `CaloriePetApp.swift` 和 `ContentView.swift`
4. 确保只勾选 `CaloriePet` Target
5. 点击 `Add`

---

## 阶段 D：美术素材导入

### D1. 打开 Assets.xcassets

在左侧项目导航器中，双击 `Assets.xcassets`

### D2. 批量导入图片

**方法一：拖拽导入（推荐）**

1. 在 Finder 中打开你的美术素材文件夹
2. 全选 30 张 `.png` 图片
3. 直接拖拽到 Assets.xcassets 的左侧列表区域
4. Xcode 会自动为每张图片创建 Image Set

**方法二：逐个导入**

1. 在 Assets.xcassets 左下角点击 `+`
2. 选择 `Image Set`
3. 重命名为 `flamepaw_lv1`
4. 把对应的 `.png` 拖入插槽
5. 重复 30 次...

### D3. 验证导入结果

在 Assets.xcassets 左侧列表中，应该能看到 30 个 Image Set：

```
Assets.xcassets/
├── AppIcon
├── AccentColor
├── flamepaw_lv1
├── flamepaw_lv2
├── flamepaw_lv3
├── tidalrop_lv1
├── ...（共30个）
└── funglow_lv3
```

---

## 阶段 E：Capabilities 配置

### E1. 配置 App Groups

1. 点击左侧项目导航器最顶部的 `CaloriePet`（蓝色图标）
2. 选择 `CaloriePet` Target（不是 Project）
3. 点击 `Signing & Capabilities` 标签
4. 点击 `+ Capability`
5. 搜索 `App Groups` → 双击添加
6. 点击 `+` 添加新的 Group：
   ```
   group.com.yourname.caloriepet
   ```
   （必须和代码中的 `AppConfig.appGroupIdentifier` 一致）

### E2. 配置 HealthKit

1. 在同一个 `Signing & Capabilities` 标签页
2. 点击 `+ Capability`
3. 搜索 `HealthKit` → 双击添加
4. 在 HealthKit 区域：
   - 勾选 `HealthKit`
   - **不需要**勾选 `Clinical Health Records`

### E3. 配置 Info.plist

1. 在左侧找到 `Info.plist`
2. 添加以下键值（右键 → `Add Row`）：

| Key | Value |
|-----|-------|
| `Privacy - Health Share Usage Description` | `CaloriePet 需要访问您的健康数据来计算宠物经验值。数据仅用于本地计算，不会上传到服务器。` |
| `Privacy - Health Update Usage Description` | `CaloriePet 需要访问您的健康数据来计算宠物经验值。` |

---

## 阶段 F：Watch App 配置

### F1. 添加 Watch Target

1. 点击 `File` → `New` → `Target...`
2. 选择 **watchOS** → **App**
3. 填写信息：

| 字段 | 填写内容 |
|------|----------|
| Product Name | `CaloriePetWatch` |
| Team | 选择相同的 Apple ID |
| Language | `Swift` |
| Interface | `SwiftUI` |

4. 点击 `Finish`
5. 弹出提示时，点击 `Activate`

### F2. 配置 Watch App 的 App Groups

1. 选择 `CaloriePetWatch` Target
2. 点击 `Signing & Capabilities`
3. 点击 `+ Capability` → 添加 `App Groups`
4. **必须选择相同的 Group ID**：`group.com.yourname.caloriepet`

### F3. 配置 Watch App 的 HealthKit

1. 在同一个 Target
2. 点击 `+ Capability` → 添加 `HealthKit`

### F4. 导入 Watch 代码文件

1. 在左侧项目导航器中，找到 `CaloriePetWatch` 文件夹
2. 删除自动生成的 `ContentView.swift`
3. 右键点击 `Watch` 文件夹 → `Add Files to "CaloriePet"`
4. 选择 `CaloriePetWatchApp.swift` 和 `ContentView_Watch.swift`
5. **重要**：只勾选 `CaloriePetWatch` Target
6. 点击 `Add`

### F5. 更新 Shared 文件的 Target

1. 在左侧找到 `Shared` 文件夹
2. 选中所有 Shared 文件夹中的 `.swift` 文件
3. 在右侧 `Target Membership` 区域
4. 勾选 `CaloriePetWatch`（让这些文件同时属于 iPhone 和 Watch）

---

## 阶段 G：构建测试

### G1. 选择运行目标

1. 在 Xcode 顶部工具栏，点击 Scheme 选择器（CaloriePet 旁边）
2. 选择 `CaloriePet` + 你的 iPhone 或模拟器

### G2. 构建项目

按 `Cmd + B` 构建

**如果报错**：
- ❌ `Cannot find type 'Pet' in scope` → Shared 文件没有添加到正确的 Target
- ❌ `No such module 'HealthKit'` → HealthKit Capability 没有添加
- ❌ `App Groups not enabled` → App Groups 没有配置正确

### G3. 运行测试

按 `Cmd + R` 运行

**首次运行会弹出**：
1. HealthKit 授权请求 → 点击"允许"
2. 通知授权请求 → 点击"允许"

### G4. 测试功能清单

| 功能 | 测试方法 | 预期结果 |
|------|----------|----------|
| 宠物显示 | 打开 App | 显示一个随机家族的 Lv1 宠物 |
| 图片加载 | 查看宠物区域 | 显示你的自定义图片（不是 SF Symbols） |
| 图鉴页面 | 点击左上角书本图标 | 显示 10 个家族网格 |
| 孵蛋功能 | 在图鉴页点击"孵蛋" | 消耗 500 XP，随机获得新家族 |
| 进化功能 | 积累足够 XP | 宠物升级并切换图片 |
| Watch 同步 | 在 Watch 上打开 App | 显示相同的宠物和进度 |

---

## ✅ 完成检查清单

打印出来，逐项勾选：

### 阶段 A（现在可做）
- [ ] A1. 美术素材命名正确（30张）
- [ ] A2. 代码文件整理好
- [ ] A3. 准备好开发者信息
- [ ] A4. 修改代码中的 App Group ID

### 阶段 B（Xcode 项目创建）
- [ ] B1. 创建 iOS 项目成功
- [ ] B2. 删除默认文件

### 阶段 C（代码导入）
- [ ] C1. 创建文件夹结构
- [ ] C2. 导入 Shared 文件
- [ ] C3. 导入 iPhone 文件

### 阶段 D（美术导入）
- [ ] D1. 打开 Assets.xcassets
- [ ] D2. 导入 30 张图片
- [ ] D3. 验证导入结果

### 阶段 E（Capabilities）
- [ ] E1. 配置 App Groups
- [ ] E2. 配置 HealthKit
- [ ] E3. 配置 Info.plist

### 阶段 F（Watch 配置）
- [ ] F1. 添加 Watch Target
- [ ] F2. 配置 Watch App Groups
- [ ] F3. 配置 Watch HealthKit
- [ ] F4. 导入 Watch 代码
- [ ] F5. 更新 Shared 文件 Target

### 阶段 G（构建测试）
- [ ] G1. 选择运行目标
- [ ] G2. 构建成功
- [ ] G3. 运行成功
- [ ] G4. 功能测试通过

---

## 🆘 遇到问题？

### 常见错误排查

| 错误信息 | 解决方法 |
|----------|----------|
| `Cannot find 'PetFamily' in scope` | Shared 文件没有勾选正确的 Target |
| `App Groups not enabled` | 检查 iPhone 和 Watch 是否使用相同的 Group ID |
| `HealthKit is not available` | 在真机上测试（模拟器 HealthKit 功能有限） |
| 图片显示空白 | 检查图片名称是否和代码中完全一致 |
| Watch 和 iPhone 数据不同步 | 确保两者使用相同的 App Group ID |

### 需要帮助？

如果遇到问题，把错误信息截图或复制给我，我帮你排查。
