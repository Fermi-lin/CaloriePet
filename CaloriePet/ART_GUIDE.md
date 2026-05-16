# CaloriePet 美术资源指南

## 🎨 当前美术方案

目前代码使用 **SF Symbols** 作为宠物外观，这是苹果官方图标库，优点：
- ✅ 无需额外图片资源
- ✅ 自动支持深色模式
- ✅ 可缩放不失真
- ✅ 支持动画效果

## 📦 当前宠物外观

| 等级 | 图标 | 名称 | 颜色主题 |
|------|------|------|----------|
| Lv1 | 🥚 `egg.fill` | 蛋宝宝 | 蛋黄色 #FFD93D |
| Lv2 | 🐦 `bird.fill` | 小鸟兽 | 翠绿色 #6BCB77 |
| Lv3 | 🔥 `flame.fill` | 烈焰凤凰 | 火焰红 #FF6B6B |

## 🖼️ 使用自定义图片

如果你想使用自己的美术资源，有以下几种方案：

### 方案 1: 简单替换 SF Symbols

修改 `PetAssets.swift`：

```swift
var mainIcon: String {
    switch level {
    case .level1:
        return "star.fill"  // 改为其他 SF Symbol
    case .level2:
        return "hare.fill"
    case .level3:
        return "dragon.fill"
    }
}
```

浏览所有可用图标：[SF Symbols App](https://developer.apple.com/sf-symbols/)

### 方案 2: 使用自定义 PNG 图片

#### 步骤 1: 准备图片
为每个等级准备 3 种状态的图片：

```
Assets.xcassets/
├── Pet_Level1/
│   ├── idle.imageset/
│   │   ├── idle.png (1x)
│   │   ├── idle@2x.png (2x)
│   │   ├── idle@3x.png (3x)
│   │   └── Contents.json
│   ├── happy.imageset/
│   └── eating.imageset/
├── Pet_Level2/
│   └── ...
└── Pet_Level3/
    └── ...
```

**图片规格建议**：
- 尺寸: 512x512 像素
- 格式: PNG（支持透明背景）
- 风格: 扁平化设计，与 iOS 风格统一

#### 步骤 2: 修改代码

修改 `PetAssets.swift`：

```swift
struct PetAppearanceAssets {
    let level: PetLevel
    
    /// 主图片（用于待机状态）
    var mainImage: Image {
        switch level {
        case .level1:
            return Image("Pet_Level1/idle")
        case .level2:
            return Image("Pet_Level2/idle")
        case .level3:
            return Image("Pet_Level3/idle")
        }
    }
    
    /// 开心状态图片
    var happyImage: Image {
        switch level {
        case .level1:
            return Image("Pet_Level1/happy")
        // ...
        }
    }
}
```

### 方案 3: 使用 Lottie 动画

如果想添加更丰富的动画效果，可以使用 Lottie。

#### 步骤 1: 添加依赖
在 Xcode 中：
1. File → Add Packages
2. 添加 `https://github.com/airbnb/lottie-ios`

#### 步骤 2: 准备 Lottie 文件
下载或创建 `.json` 格式的 Lottie 动画文件：
```
Resources/
├── pet_level1_idle.json
├── pet_level1_happy.json
├── pet_level2_idle.json
└── ...
```

#### 步骤 3: 修改代码

```swift
import Lottie

struct LottiePetView: View {
    let level: PetLevel
    let state: PetState
    
    var animationName: String {
        switch (level, state) {
        case (.level1, .normal):
            return "pet_level1_idle"
        case (.level1, .happy):
            return "pet_level1_happy"
        // ...
        default:
            return "pet_level1_idle"
        }
    }
    
    var body: some View {
        LottieView(animation: .named(animationName))
            .playing()
            .looping()
    }
}
```

## 🎨 美术风格建议

### 风格 1: 像素风 (Pixel Art)
- 适合复古游戏风格
- 尺寸: 32x32 或 64x64 像素
- 工具: Aseprite, Pixaki

### 风格 2: 扁平插画 (Flat Illustration)
- 适合现代简洁风格
- 尺寸: 512x512 像素
- 工具: Figma, Adobe Illustrator

### 风格 3: 3D 卡通 (3D Cartoon)
- 适合更生动的效果
- 可以使用 3D 渲染图或 3D 模型
- 工具: Blender, Cinema 4D

## 🛠️ 推荐设计工具

### 免费工具
1. **Figma** - 界面设计和矢量插画
2. **GIMP** - 位图编辑
3. **Inkscape** - 矢量图形
4. **Blender** - 3D 建模和渲染

### 付费工具
1. **Adobe Illustrator** - 专业矢量设计
2. **Adobe Photoshop** - 专业位图编辑
3. **Procreate** (iPad) - 手绘插画
4. **Aseprite** - 像素画专用

## 📐 设计规范

### 颜色建议
使用协调的配色方案：

**方案 1: 暖色调**
- Lv1: #FFE5B4 (桃色)
- Lv2: #FFB347 (橙色)
- Lv3: #FF6B6B (珊瑚红)

**方案 2: 冷色调**
- Lv1: #B4E7FF (天蓝)
- Lv2: #47B3FF (蓝色)
- Lv3: #6B6BFF (紫蓝)

**方案 3: 自然色调**
- Lv1: #C8E6C9 (浅绿)
- Lv2: #81C784 (绿色)
- Lv3: #2E7D32 (深绿)

### 尺寸规范
| 用途 | 尺寸 | 说明 |
|------|------|------|
| App Icon | 1024x1024 | 应用商店图标 |
| 宠物展示 | 512x512 | 主界面宠物 |
| 缩略图 | 256x256 | 列表中使用 |
| 通知图标 | 120x120 | 通知中心 |

## 🎯 进化设计建议

### Lv1 → Lv2 设计要点
- 保持核心特征的一致性
- 增加一些成长特征（如长出翅膀）
- 颜色可以稍微变深或变鲜艳

### Lv2 → Lv3 设计要点
- 显著的变化，体现"完全体"
- 可以添加特效元素（如火焰、光环）
- 颜色更加华丽

## 📱 实际替换示例

假设你设计了一套新的宠物图片：

### 1. 添加图片到项目
```
Assets.xcassets/
├── pet_egg.imageset/
│   ├── pet_egg.png
│   ├── pet_egg@2x.png
│   ├── pet_egg@3x.png
│   └── Contents.json
├── pet_dragon_baby.imageset/
└── pet_dragon_adult.imageset/
```

### 2. 修改 PetAssets.swift
```swift
extension PetAppearanceAssets {
    var mainImage: Image {
        switch level {
        case .level1:
            return Image("pet_egg")
        case .level2:
            return Image("pet_dragon_baby")
        case .level3:
            return Image("pet_dragon_adult")
        }
    }
}
```

### 3. 修改 PetAnimationView
```swift
struct PetAnimationView: View {
    // ...
    
    var body: some View {
        assets.mainImage
            .resizable()
            .scaledToFit()
            // 添加动画效果
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
    }
}
```

## 🚀 快速开始

如果你不想自己设计，可以使用以下免费资源：

### 免费素材网站
1. **OpenGameArt.org** - 游戏素材
2. **itch.io** - 独立游戏素材
3. **Game-icons.net** - 游戏图标
4. **Flaticon** - 扁平化图标

### AI 生成工具
1. **Midjourney** - 高质量插画
2. **DALL-E** - OpenAI 的图像生成
3. **Stable Diffusion** - 开源 AI 绘画

提示词示例：
```
Cute pixel art dragon egg, glowing, 
white background, game asset, 64x64 pixels
```

## ✅ 检查清单

替换美术资源前检查：
- [ ] 图片尺寸符合规范
- [ ] 已准备 @2x 和 @3x 版本
- [ ] 图片已添加到 Assets.xcassets
- [ ] 图片名称与代码中一致
- [ ] 已测试不同设备上的显示效果
- [ ] 已测试深色模式下的显示效果

---

**总结**: 当前使用 SF Symbols 是最简单可靠的方案。如果你想让应用更有特色，可以按照上述指南替换为自定义图片或动画。
