# Farm Ring Toss — UI System

完整的 UI 设计系统，从 Design Tokens → Godot 组件 → 美术资产全链路打包。**即插即用，字体已含。**

---

## 这个 repo 是什么

一个 fitness 游戏的 3 层 UI 系统，包含：
1. **可导入的 Godot 资源包** — Theme、Shader、16 个组件场景、字体、占位贴图
2. **AI 生成 Skill** — 给策划案链接，自动输出 UI/文案/贴图 三个审核 HTML
3. **设计标准** — Tokens、组件 spec、美术 brief，人和 AI 都能读

---

## Quick Start — 给开发

### 拿走就用（2 步）

**Step 1:** 把 `dev-export/` 整个复制到你的 Godot 项目：

```
your-project/
└── common/
    └── ui/            ← 把 dev-export/ 里的内容放这里
        ├── theme/ui_theme.tres
        ├── shaders/  (3 个 .gdshader)
        ├── scenes/   (16 个 .tscn)
        ├── fonts/    (2 个 .ttf ← 已包含!)
        └── textures/placeholders/ (9 个占位贴图)
```

**Step 2:** Project Settings:

| 设置 | 值 |
|-----|---|
| Viewport | 480×854 |
| Stretch Mode | canvas_items |
| Stretch Aspect | expand |
| Custom Font | `res://common/ui/fonts/Fredoka-Medium.ttf` |

搞定。开场景拖组件就有正确外观。

---

## 字体

| 字体 | 用途 | 字号 | 许可 |
|------|------|------|------|
| **Luckiest Guy** | Display / HUD / 分数 / 打击反馈 | 42, 32, 28, 22 | OFL |
| **Fredoka Medium** | Body / 标签 / 说明 / Caption | 18, 14, 12, 10 | OFL |

两个 TTF 已在 `dev-export/fonts/` 里，不需要额外下载。

---

## dev-export/ 内容清单

```
dev-export/
├── theme/
│   ├── ui_theme.tres          # 全局 Theme (所有 StyleBoxFlat)
│   └── styleboxes.tres        # StyleBox 参考文档
├── shaders/
│   ├── badge_sphere.gdshader  # 球形高光 (badge/icon button)
│   ├── progress_fill.gdshader # 进度条填充 + 满格金色
│   └── button_shine.gdshader  # 按钮顶部高光条
├── scenes/                    # 16 个自包含 .tscn 组件
│   ├── action_card.tscn       # 动作卡 (name + icon + hand + reps)
│   ├── score_hud.tscn         # 右上角计分面板
│   ├── rep_counter.tscn       # REP 计数药丸
│   ├── progress_bar.tscn      # 回合进度条
│   ├── charge_bar.tscn        # Burst 充能条
│   ├── hit_result_text.tscn   # 打击反馈文字 (PERFECT!)
│   ├── phase_banner.tscn      # 回合开始横幅
│   ├── switch_hand.tscn       # 换手提示
│   ├── return_rhythm_bar.tscn # 回位节奏条
│   ├── multi_hit_result.tscn  # 多环连击结果
│   ├── burst_hint.tscn        # Burst 可用提示
│   ├── end_panel.tscn         # 结算面板 (star + stats + button)
│   ├── hud_container.tscn     # HUD 布局框架
│   ├── rainbow_fullscreen.tscn# 全屏彩虹特效
│   ├── fox_warning.tscn       # 狐狸警告
│   └── golden_countdown.tscn  # 金色倒计时
├── fonts/
│   ├── LuckiestGuy-Regular.ttf
│   ├── Fredoka-Medium.ttf
│   └── font_config.tres       # 字号/用途参考
├── textures/placeholders/     # GradientTexture2D 占位
│   ├── ring_red/green/gold/blue.tres
│   ├── peg_base.tres
│   ├── fox_sprite.tres
│   ├── hand_icon.tres
│   ├── star_filled.tres
│   └── farm_bg.tres
├── project_settings.cfg       # 推荐的 project.godot 设置
└── README.md                  # dev-export 专属说明
```

---

## Demo Asset Gen — 给策划/美术

### 模式 1: Generate

```
/demo-asset-gen <飞书策划案URL>
```

输出三个 HTML：
- `ui-preview.html` — UI 组件 live preview (有动画、正确尺寸)
- `copy-preview.html` — 文案审核 (AI生成 + revision 框)
- `assets-preview.html` — 贴图/MJ prompt (AI生成 + revision 框)

### 模式 2: Learn

```
/demo-asset-gen learn <修改后的文件夹>
```

美术填完 revision 框后，skill 对比 original vs revised → 提取 pattern → 写入 `revision-rules.json` → 下次自动应用。越用越准。

---

## 设计规则

| 规则 | 值 |
|------|---|
| Border | 3–5px 厚描边 |
| Depth | border_bottom = border + bar (3-5px)，**绝对禁止 drop shadow** |
| Radius | 14–28px (卡片), 999px (药丸/条) |
| Pressed | bottom bar 消失, content 下移 bar 高度 |
| 颜色 | Green `#6EC531`, Amber `#F5A623`, Red `#E8453A`, Gold `#FFD700`, Cream `#FFF5D6` |
| 描边色 | 比 bg 暗 25-30% |
| 最小文字 | 18px body / 22px HUD (TV 1.5m 可读) |

---

## Repo 结构

```
ui-system/
├── dev-export/                     # ⭐ Godot 即插即用包 (本体)
├── demo-ring-toss/                 # 示例输出 (套圈 demo 的三个 HTML)
├── .claude/skills/demo-asset-gen/  # Claude Code Skill 定义
├── tokens.json                     # Layer 1 Design Tokens (JSON)
├── components-preview.html         # UI preview 质量标杆
├── layer2-components.md            # 16 组件 spec
└── layer3-asset-brief.md           # Midjourney style brief
```

---

## Target

- **Engine:** Godot 4.3+ / C# (.NET 8)
- **Display:** 16:9 landscape, TV/projector, standing 1.5m
- **Audience:** casual female beginners
- **AI art:** Midjourney v6.1 `--style raw --s 200`
