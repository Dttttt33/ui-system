# Farm Ring Toss — UI Package (Godot 4.3+)

即插即用 UI 资源包。**字体已包含**，复制整个文件夹到项目即可使用，零配置、零下载。

---

## Quick Start（2 步搞定）

### 1. 复制到项目

```
your-godot-project/
├── common/
│   └── ui/
│       ├── theme/
│       │   └── ui_theme.tres          ← 全局 Theme
│       ├── shaders/
│       │   ├── badge_sphere.gdshader  ← 球形高光 shader
│       │   ├── progress_fill.gdshader ← 进度条填充
│       │   └── button_shine.gdshader  ← 按钮顶部光
│       ├── scenes/
│       │   ├── action_card.tscn
│       │   ├── burst_hint.tscn
│       │   ├── charge_bar.tscn
│       │   ├── end_panel.tscn
│       │   ├── fox_warning.tscn
│       │   ├── golden_countdown.tscn
│       │   ├── hit_result_text.tscn
│       │   ├── hud_container.tscn
│       │   ├── multi_hit_result.tscn
│       │   ├── phase_banner.tscn
│       │   ├── progress_bar.tscn
│       │   ├── rainbow_fullscreen.tscn
│       │   ├── rep_counter.tscn
│       │   ├── return_rhythm_bar.tscn
│       │   ├── score_hud.tscn
│       │   └── switch_hand.tscn
│       ├── fonts/
│       │   ├── LuckiestGuy-Regular.ttf   ← 已包含 (Display/HUD)
│       │   ├── Fredoka-Medium.ttf         ← 已包含 (Body/UI)
│       │   └── font_config.tres           ← 配置参考
│       └── textures/
│           └── placeholders/              ← 开发用占位贴图
│               ├── ring_red.tres
│               ├── ring_green.tres
│               ├── ring_gold.tres
│               ├── ring_blue.tres
│               ├── peg_base.tres
│               ├── fox_sprite.tres
│               ├── hand_icon.tres
│               ├── star_filled.tres
│               └── farm_bg.tres
```

### 2. 配置项目设置

在 `Project > Project Settings` 中设置：

| 设置路径 | 值 |
|---------|---|
| Display > Window > Viewport Width | `480` |
| Display > Window > Viewport Height | `854` |
| Display > Window > Stretch Mode | `canvas_items` |
| Display > Window > Stretch Aspect | `expand` |
| GUI > Theme > Custom Font | `res://common/ui/fonts/Fredoka-Medium.ttf` |

或直接把 `project_settings.cfg` 中的内容复制到 `project.godot`。

---

## 文件说明

### Theme (`ui_theme.tres`)

全局 Theme 资源，包含所有 StyleBoxFlat 定义。应用到场景根节点即可让所有子节点继承样式。

```gdscript
# 在场景根节点
$Root.theme = preload("res://common/ui/theme/ui_theme.tres")
```

包含的样式：
- `PanelContainer/styles/panel` — cream 主面板 (border 4px, bottom bar 4px, radius 24)
- `Button/styles/normal` — green 主按钮 (border 3px, bottom bar 5px, radius 14)
- `Button/styles/pressed` — pressed 态 (bottom bar 消失, content 下移 3px)
- `Button/styles/hover` — 略亮绿

### Shaders

| 文件 | 用途 | 关键参数 |
|------|------|---------|
| `badge_sphere.gdshader` | 圆形 badge 的球形渐变高光 | `highlight_pos(0.38, 0.28)`, `border_width=3`, `bottom_shadow=7` |
| `progress_fill.gdshader` | 进度条/charge 条的填充 | `progress(0-1)`, `is_full` 时变金色, `shine_height=0.35` |
| `button_shine.gdshader` | 按钮顶部高光条 | `shine_height=0.38`, `shine_opacity=0.45` |

### Scenes（16 个组件）

每个 `.tscn` 都是自包含的——样式内联为 sub_resource，不依赖外部 Theme（但推荐配合 Theme 使用）。

| 场景 | 说明 | 关键节点 |
|------|------|---------|
| `action_card.tscn` | 动作卡片 | NameTab + IconArea + HandPill + RepBlocks |
| `score_hud.tscn` | 右上角计分 | ScoreBadge + CaughtBadge |
| `rep_counter.tscn` | REP 计数药丸 | 单 Label |
| `progress_bar.tscn` | 回合进度条 | Track(StyleBox) + Fill(Shader) + Label |
| `charge_bar.tscn` | Burst 充能条 | 同上，amber 色 |
| `hit_result_text.tscn` | 命中反馈文字 | 居中 Label, outline 6px |
| `phase_banner.tscn` | 回合开始横幅 | Title + Subtitle |
| `switch_hand.tscn` | 换手提示 | Icon + Title + Subtitle |
| `return_rhythm_bar.tscn` | 回位节奏条 | Track + Indicator |
| `multi_hit_result.tscn` | 多环命中结果 | Combo + Score + Quality |
| `burst_hint.tscn` | Burst 可用提示 | 底部金色 pill |
| `end_panel.tscn` | 结算面板 | Title + Stars + 3x StatCards + Button |
| `hud_container.tscn` | HUD 布局框架 | CanvasLayer > TopBar + BottomBar |
| `rainbow_fullscreen.tscn` | 全屏彩虹特效 | Overlay + CenterPanel |
| `fox_warning.tscn` | 狐狸警告 | 红色 pill + icon |
| `golden_countdown.tscn` | 金色倒计时 | 圆形金色 badge |

### Placeholder Textures

`GradientTexture2D` 资源，可直接赋给 `Sprite2D.texture` 或 `TextureRect.texture`。

替换为正式美术时只需把 `.tres` 换成 `.png` 并更新引用路径。

---

## 设计规则速查

| 规则 | 值 |
|------|---|
| Border width | 3–5px (厚描边风格) |
| Bottom depth bar | border + 3~5px (制造立体感) |
| Corner radius | 14–28px (卡片/按钮), 999px (药丸/条) |
| 绝对禁止 | Drop shadow (shadow_size=0) |
| Pressed 态 | bottom bar 消失, content_margin_top += bar高度 |
| 颜色 | Green #6EC531, Amber #F5A623, Red #E8453A, Gold #FFD700, Cream #FFF5D6 |
| 深色描边 | 比 bg 暗 25-30% |
| 字体 | Luckiest Guy (display), Fredoka Medium (body) |

---

## 字体 (Fonts)

已包含在 `fonts/` 目录中，Godot 打开项目时自动导入。

| 字体 | 文件 | 用途 | 字号 |
|------|------|------|------|
| Luckiest Guy | `LuckiestGuy-Regular.ttf` | Display / HUD / 分数 / 标题 | 42 (反馈), 32 (phase), 28 (score), 22 (HUD) |
| Fredoka Medium | `Fredoka-Medium.ttf` | Body / UI / 标签 / 说明 | 18 (body), 14 (subtitle), 12 (caption), 10 (tiny) |

字体来源：[Google Fonts](https://fonts.google.com) (OFL License)

在 GDScript 中加载字体：
```gdscript
var display_font = preload("res://common/ui/fonts/LuckiestGuy-Regular.ttf")
var body_font = preload("res://common/ui/fonts/Fredoka-Medium.ttf")
```

---

## 使用示例

```gdscript
# 实例化一个 action card
var card = preload("res://common/ui/scenes/action_card.tscn").instantiate()
card.get_node("VBox/NameTab/NameLabel").text = "Bicep Curl"
card.get_node("VBox/HandPill/HandLabel").text = "Right hand"
add_child(card)

# 更新 progress bar
var bar = $HUD/ProgressBar
bar.get_node("Fill").material.set_shader_parameter("progress", 0.75)
bar.get_node("Label").text = "15 / 20"

# Burst 充满变金色
$ChargeBar/Fill.material.set_shader_parameter("is_full", true)
```

---

## 目录映射

本包的 `dev-export/` 目录结构对应 Godot 项目中的路径：

```
dev-export/theme/     →  res://common/ui/theme/
dev-export/shaders/   →  res://common/ui/shaders/
dev-export/scenes/    →  res://common/ui/scenes/
dev-export/fonts/     →  res://common/ui/fonts/
dev-export/textures/  →  res://common/ui/textures/
```
