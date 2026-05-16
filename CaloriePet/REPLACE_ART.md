# 替换美术素材指南

## 📋 你需要做的事

总共 **3 步**，大约 10 分钟。

---

## 第 1 步：给你的图片重命名

把你在 raphael.app 生成的 30 张图片，按下面的规则重命名：

| 家族 | Lv1 幼体 | Lv2 成长 | Lv3 完全体 |
|------|----------|----------|------------|
| 🔥 焰爪 | `flamepaw_lv1.png` | `flamepaw_lv2.png` | `flamepaw_lv3.png` |
| 💧 潮滴 | `tidalrop_lv1.png` | `tidalrop_lv2.png` | `tidalrop_lv3.png` |
| 🌿 萌芽 | `sproutling_lv1.png` | `sproutling_lv2.png` | `sproutling_lv3.png` |
| ⚡ 电狐 | `zapkit_lv1.png` | `zapkit_lv2.png` | `zapkit_lv3.png` |
| ❄️ 霜灵 | `frosto_lv1.png` | `frosto_lv2.png` | `frosto_lv3.png` |
| 🪨 岩崽 | `pebblem_lv1.png` | `pebblem_lv2.png` | `pebblem_lv3.png` |
| 🌬️ 风铃 | `breezling_lv1.png` | `breezling_lv2.png` | `breezling_lv3.png` |
| 🌙 影喵 | `shadkit_lv1.png` | `shadkit_lv2.png` | `shadkit_lv3.png` |
| ☀️ 日光兔 | `solbit_lv1.png` | `solbit_lv2.png` | `solbit_lv3.png` |
| 🍄 荧光菇 | `funglow_lv1.png` | `funglow_lv2.png` | `funglow_lv3.png` |

> **格式要求**：PNG 格式，正方形（512×512 或 1024×1024），透明背景最佳。

---

## 第 2 步：在 Xcode 中添加图片到 Assets

### 2.1 打开 Assets.xcassets

在 Xcode 左侧项目导航器中，找到 `Assets.xcassets` 文件，点击打开。

### 2.2 逐个添加图片

对每一张图片（共 30 张）：

1. 在 Assets.xcassets 左下角点击 **"+"** 按钮
2. 选择 **"Image Set"**
3. 将左侧新建的 Image Set 重命名为对应的名称（如 `flamepaw_lv1`）
4. 把重命名好的 `.png` 图片**拖拽**到 Image Set 的插槽中
5. 确保图片出现在 **"Universal"** 槽位中

### 2.3 验证

添加完成后，在 Assets.xcassets 左侧列表中应该能看到 30 个 Image Set：

```
Assets.xcassets/
├── flamepaw_lv1.imageset
├── flamepaw_lv2.imageset
├── flamepaw_lv3.imageset
├── tidalrop_lv1.imageset
├── tidalrop_lv2.imageset
├── tidalrop_lv3.imageset
├── sproutling_lv1.imageset
├── sproutling_lv2.imageset
├── sproutling_lv3.imageset
├── zapkit_lv1.imageset
├── zapkit_lv2.imageset
├── zapkit_lv3.imageset
├── frosto_lv1.imageset
├── frosto_lv2.imageset
├── frosto_lv3.imageset
├── pebblem_lv1.imageset
├── pebblem_lv2.imageset
├── pebblem_lv3.imageset
├── breezling_lv1.imageset
├── breezling_lv2.imageset
├── breezling_lv3.imageset
├── shadkit_lv1.imageset
├── shadkit_lv2.imageset
├── shadkit_lv3.imageset
├── solbit_lv1.imageset
├── solbit_lv2.imageset
├── solbit_lv3.imageset
├── funglow_lv1.imageset
├── funglow_lv2.imageset
└── funglow_lv3.imageset
```

---

## 第 3 步：构建运行

按 `Cmd + B` 构建，然后 `Cmd + R` 运行。

如果一切正确，你会看到：
- 首次打开 app 会随机分配一个家族的 Lv1 宠物
- 点击左上角 📖 图鉴按钮可以查看所有家族
- 消耗 500 XP 可以孵化新蛋（随机获得未拥有的家族）
- 宠物进化后自动切换为对应家族的 Lv2/Lv3 图片

---

## ⚠️ 常见问题

### Q: 图片显示空白？
**A**: 检查图片名称是否和代码中完全一致（区分大小写）。Image Set 的名字必须精确匹配，比如 `flamepaw_lv1` 不能写成 `Flamepaw_lv1`。

### Q: 图片被拉伸变形？
**A**: 代码中使用了 `.scaledToFit()`，应该不会变形。如果仍有问题，确保你的图片是正方形的。

### Q: 只想先测试一两个家族？
**A**: 可以只添加 2-3 个家族的图片（6-9 张），其余的会显示为空白。不影响运行。

### Q: 想换掉某个家族的图片？
**A**: 直接在 Assets.xcassets 中替换对应 Image Set 的图片即可，不需要改代码。

### Q: 图片背景不是透明的怎么办？
**A**: 代码中宠物有背景圆圈和光晕效果，非透明背景也能正常显示。但如果想要更好的效果，建议使用工具去除背景（macOS 自带的"预览"app → 工具 → 即时 Alpha 即可抠图）。
