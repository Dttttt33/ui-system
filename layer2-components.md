# Layer 2: Component Scenes

> 所有组件基于 Layer 1 tokens 参数化。每个组件描述其 Godot 场景结构、暴露的 export 变量、信号、和 token 映射。
> 路径约定：`res://common/ui/` 为通用组件，`res://demos/ring-toss/ui/` 为本 demo 专用。
> 共 16 个组件：6 通用 + 10 demo 专用（7 P0 + 3 P1）。

---

## 通用组件（复用跨 demo）

### 1. RepCounter `res://common/ui/rep_counter.tscn`

**玩家看到**：`REP 8/36`，绿色 pill badge

**结构**：
```
RepCounter (PanelContainer)
├── Label (current/total)
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 背景色 | `color.brand.green` |
| 边框 | `4px solid color.brand.green-dark` |
| 底部条 | `box-shadow: 0 4px 0 color.brand.green-deep` |
| 字体 | `typography.family.display` (Luckiest Guy) |
| 字号 | `typography.scale.hud-label` (22px) |
| 文字色 | `color.text.on-green` (#FFFFFF) |
| 圆角 | `radius.pill` |
| 间距 | `spacing.layout.hud-margin` 距边 |

**Export 变量**：
```gdscript
@export var current_rep: int = 0
@export var total_reps: int = 36
```

**信号**：`rep_updated(current, total)`

---

### 2. ProgressBar `res://common/ui/total_progress.tscn`

**玩家看到**：顶部一条逐渐填满的进度条

**结构**：
```
TotalProgress (Control)
├── Track (Panel) — inset shadow track
├── Fill (Panel) — green→yellow gradient
│   └── Shine (Panel) — top highlight strip
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 轨道背景 | `#D4C4A0` |
| 轨道边框 | `3px solid #8B7A5A` |
| 轨道阴影 | `inset 0 3px 6px rgba(0,0,0,0.25)` |
| 填充色 | `linear-gradient(color.game.charge-fill → #B8E44B)` |
| 满格色 | `linear-gradient(#F5B800 → color.game.charge-full)` |
| 高光条 | `rgba(255,255,255,0.45)` |
| 高度 | 22px |
| 圆角 | `radius.pill` |

**Export 变量**：
```gdscript
@export var progress: float = 0.0  # 0.0 - 1.0
@export var show_full_glow: bool = false
```

---

### 3. ActionCard `res://common/ui/action_card.tscn`

**玩家看到**：当前动作名称 + 示意 + 手侧标签

**结构**：
```
ActionCard (PanelContainer)  — cream panel style
├── VBox
│   ├── ActionIcon (TextureRect)
│   ├── ActionName (Label) — Luckiest Guy 18px
│   └── HandSide (Label) — pill badge, "LEFT" / "RIGHT"
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 面板背景 | `color.surface.panel-fill` |
| 面板边框 | `4px solid color.surface.panel-border` |
| 面板阴影 | `0 6px 0 color.surface.panel-border-deep` |
| 圆角 | `radius.panel` (24px) |
| 动作名字体 | `typography.family.display` |
| 手侧 badge 背景 | `color.brand.green` |
| 手侧 badge 字色 | `#FFFFFF` |

**Export 变量**：
```gdscript
@export var action_name: String = "KETTLEBELL SWING"
@export var action_icon: Texture2D
@export var hand_side: String = "LEFT"  # "LEFT" | "RIGHT" | "BOTH"
```

**信号**：`card_shown`, `card_hidden`

---

### 4. ChargeBar `res://common/ui/charge_bar.tscn`

**玩家看到**：动作蓄力时填满，满格变金色

**结构**：
```
ChargeBar (Control)
├── Label ("CHARGE") — Luckiest Guy 12px, white
├── Track (Panel)
├── Fill (Panel)
│   └── Shine (Panel)
```

**Token 映射**：同 ProgressBar，额外：
| 属性 | Token |
|------|-------|
| 标签字体 | `typography.family.display` |
| 标签字色 | `color.text.hud` |
| 动画 | `animation.game.charge-fill` (1200ms ease-out) |

**Export 变量**：
```gdscript
@export var charge: float = 0.0  # 0.0 - 1.0
@export var is_full: bool = false
```

**信号**：`charge_full`, `charge_reset`

---

### 5. HitResultText `res://common/ui/hit_result_text.tscn`

**玩家看到**：`Good!` / `Perfect!` / `Try again` 弹出后淡出

**结构**：
```
HitResultText (Control)
├── Label — Luckiest Guy, scales and fades
```

**Token 映射**：
| 结果 | 颜色 | 字号 |
|------|------|------|
| Good | `color.semantic.success` | `display-md` (32px) |
| Perfect | `color.semantic.perfect` | `display-lg` (44px) |
| Miss | `color.semantic.miss` | `body` (18px) |
| Combo | `color.semantic.combo` | `hud-combo` (52px) |

| 属性 | Token |
|------|-------|
| 弹出动画 | `animation.game.hit-pop` (300ms bounce) |
| 上浮动画 | `animation.game.score-rise` (600ms decelerate) |
| 淡出 | `animation.game.miss-fade` (500ms ease-out) |
| text-shadow | `typography.effect.shadow-hard` |

**Export 变量**：
```gdscript
@export var result_type: String = "good"  # "good"|"perfect"|"miss"|"combo"
@export var text_override: String = ""
@export var score_value: int = 0
```

**方法**：`show_result(type, score)` — 播放动画后 auto-hide

---

### 6. ScoreHUD `res://common/ui/score_hud.tscn`

**玩家看到**：右上角 cream panel 里的分数

**结构**：
```
ScoreHUD (PanelContainer)  — cream panel style
├── VBox
│   ├── Label ("SCORE") — caption, letter-spacing 1.5px
│   └── ScoreLabel — Luckiest Guy 34px
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 面板背景 | `color.surface.panel-fill` |
| 面板边框 | `3px solid color.surface.panel-border` |
| 面板阴影 | `0 3px 0 color.surface.panel-border-deep` |
| 数字字体 | `typography.family.display` |
| 数字字色 | `color.text.dark` |
| 标签字色 | `color.text.light` |
| 圆角 | `radius.md` (14px) |
| 内间距 | `10px 20px` |

**Export 变量**：
```gdscript
@export var score: int = 0
@export var animate_on_change: bool = true
```

**信号**：`score_changed(old_value, new_value)`

---

## Demo 专用组件

### 7. PhaseBanner `res://demos/ring-toss/ui/phase_banner.tscn`

**玩家看到**：居中横幅 `套住远处的西瓜和羊群！`，显示 2 秒淡出

**结构**：
```
PhaseBanner (CenterContainer)
├── Panel — cream panel, short height
│   └── Label — Luckiest Guy 24px
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 面板 | cream panel style (same as default) |
| 字体 | `typography.scale.title` |
| 动画入 | `animation.game.phase-transition` (800ms ease-in-out) |
| 动画出 | `animation.game.miss-fade` (500ms) |

**Export 变量**：
```gdscript
@export var banner_text: String = "CATCH THE FAR TARGETS!"
@export var display_duration: float = 2.0
@export var auto_hide: bool = true
```

---

### 8. SwitchHandPrompt `res://demos/ring-toss/ui/switch_hand.tscn`

**玩家看到**：中央短暂出现方向箭头 + `Switch sides`

**结构**：
```
SwitchHandPrompt (CenterContainer)
├── HBox
│   ├── ArrowIcon (TextureRect) — 方向箭头
│   └── Label ("SWITCH SIDES") — Luckiest Guy 22px
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 文字色 | `color.text.hud` (#FFF) |
| text-shadow | `typography.effect.shadow-hard` |
| 动画 | `animation.game.hit-pop` (300ms bounce) |

---

### 9. ReturnRhythmBar `res://demos/ring-toss/ui/return_rhythm.tscn`

**玩家看到**：发射后出现的节奏条，理想区间绿色

**结构**：
```
ReturnRhythmBar (Control)
├── Track (Panel) — same as ProgressBar track
├── IdealZone (Panel) — green区间
├── Cursor (Panel) — moving indicator
├── ResultLabel — "Perfect" / "Too fast" / "Too slow"
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 轨道 | 同 ProgressBar track |
| 理想区间色 | `color.brand.green` + 50% opacity |
| 光标色 | `color.brand.amber` |
| Perfect 文字 | `color.semantic.perfect` |
| Too fast/slow | `color.text.light` |

**Export 变量**：
```gdscript
@export var ideal_start: float = 0.4  # 0-1 position
@export var ideal_end: float = 0.7
@export var cursor_speed: float = 1.0
```

**信号**：`rhythm_completed(result: String)`  # "perfect"|"too_fast"|"too_slow"

---

### 10. MultiHitResult `res://demos/ring-toss/ui/multi_hit.tscn`

**玩家看到**：`Double!` `Triple!` `Amazing!` + 倍率 + 总分

**结构**：
```
MultiHitResult (Control)
├── TitleLabel — "DOUBLE!" Luckiest Guy 44px
├── MultiplierLabel — "x2" 24px
├── ScoreLabel — "+480" 20px
```

**Token 映射**：
| 命中数 | 颜色 |
|--------|------|
| Double (2) | `color.brand.amber` |
| Triple (3) | `color.semantic.combo` (red) |
| Amazing (4+) | rainbow gradient |

| 属性 | Token |
|------|-------|
| 动画 | `animation.game.hit-pop` + `combo-pulse` |
| text-shadow | `typography.effect.shadow-hard` |

---

### 11. BurstHint `res://demos/ring-toss/ui/burst_hint.tscn`

**玩家看到**：爆发前 1.5 秒，屏幕边缘很轻的脉冲

**结构**：
```
BurstHint (CanvasLayer)
├── EdgeGlow (ColorRect) — 半透明边缘渐变
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 发光色 | `color.brand.amber` @ 15% opacity |
| 动画 | `animation.duration.emphasis` (800ms) + fade |
| 峰值色 | `color.semantic.perfect` @ 25% opacity |

**Export 变量**：
```gdscript
@export var lead_time: float = 1.5
@export var enabled: bool = true
```

---

### 12. EndPanel `res://demos/ring-toss/ui/end_panel.tscn`

**玩家看到**：结算面板——总分、最高命中数、金色南瓜数量

**结构**：
```
EndPanel (CenterContainer)
├── Panel — cream panel style, large
│   ├── TitleTab ("COMPLETE!") — green tab
│   ├── Stars (HBox) — 3x Star SVG (gold/empty based on score)
│   ├── StatsGrid
│   │   ├── Row: icon + "SCORE" + value
│   │   ├── Row: icon + "BEST HIT" + value
│   │   └── Row: icon + "GOLDEN" + value
│   ├── MessageLabel ("GREAT JOB!") — Luckiest Guy 32px
│   └── PlayButton — green btn "DONE"
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 面板 | cream panel style (large, 24px radius, gold border) |
| 标题 tab | green tab (same as panel-title) |
| 星星 | Star D SVG path, gold/empty |
| 数据行背景 | `color.surface.card-row` |
| 按钮 | green button style |
| message 字色 | `color.brand.green-dark` |

**Export 变量**：
```gdscript
@export var total_score: int = 0
@export var best_hit: int = 0
@export var golden_count: int = 0
@export var star_count: int = 2  # 0-3
```

**信号**：`panel_closed`

---

### 13. HUDContainer `res://demos/ring-toss/ui/hud_container.tscn`

**屏幕布局**：组合所有 HUD 元素的容器

**结构**：
```
HUDContainer (CanvasLayer)
├── TopBar (HBox)
│   ├── RepCounter (左)
│   ├── TotalProgress (中, stretch)
│   └── ScoreHUD (右)
├── CenterArea (CenterContainer)
│   ├── PhaseBanner
│   ├── SwitchHandPrompt
│   ├── HitResultText
│   └── MultiHitResult
├── BottomBar (HBox)
│   ├── ActionCard (左)
│   ├── VBox (中)
│   │   ├── ChargeBar
│   │   └── ReturnRhythmBar
│   └── Spacer (右)
├── BurstHint (全屏覆盖)
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 顶部内边距 | `spacing.layout.hud-margin` (24px) |
| 顶部元素间距 | `spacing.layout.hud-gap` (12px) |
| 安全区 | `spacing.layout.screen-safe-area` (40px) |

---

### 14. RainbowFullscreen `res://demos/ring-toss/ui/rainbow_fullscreen.tscn`

**玩家看到**：命中彩虹果时全屏 `RAINBOW!` + 彩虹渐变 + 奖励分

**结构**：
```
RainbowFullscreen (CanvasLayer)
├── Overlay (ColorRect) — 半透明白闪
├── TitleLabel ("RAINBOW!") — Luckiest Guy 56px, rainbow gradient
├── ScoreLabel ("+1200 BONUS") — Luckiest Guy 28px, gold
├── ParticleHint (CPUParticles2D) — 彩虹色纸屑 burst
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 标题渐变 | `color.game.target-rainbow` (135deg 四色) |
| 奖励字色 | `color.semantic.perfect` (gold) |
| text-shadow | `typography.effect.shadow-hard` |
| 白闪 overlay | `#FFFFFF` @ 30% → 0% (200ms) |
| 弹出动画 | `animation.game.hit-pop` (300ms bounce) + scale 1.3→1.0 |
| 停留时间 | 1.5s |
| 淡出 | `animation.game.miss-fade` (500ms) |

**Export 变量**：
```gdscript
@export var bonus_score: int = 1200
@export var show_particles: bool = true
```

**信号**：`rainbow_dismissed`

---

### 15. FoxWarning `res://demos/ring-toss/ui/fox_warning.tscn`

**玩家看到**：狐狸接近金色南瓜时，方向指示 + `Watch out!`

**结构**：
```
FoxWarning (Control)
├── HBox (CenterContainer)
│   ├── FoxIcon (TextureRect) — 32x32 狐狸头像
│   ├── ArrowIcon (TextureRect) — 指向目标方向
│   └── Label ("WATCH OUT!") — Luckiest Guy 20px
├── EdgeGlow (ColorRect) — 对应方向的边缘橙色脉冲
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 文字色 | `color.text.hud` (#FFF) |
| text-shadow | `typography.effect.shadow-hard` |
| 边缘色 | `color.brand.amber` @ 25% opacity |
| 图标 tint | `color.brand.amber` |
| 入场动画 | `animation.game.hit-pop` (300ms bounce) |
| 脉冲动画 | `animation.game.combo-pulse` (150ms × 2) |
| 停留时间 | 2s |
| 淡出 | `animation.game.miss-fade` (500ms) |

**Export 变量**：
```gdscript
@export var direction: String = "left"  # "left" | "right"
@export var urgency: float = 1.0  # 0-1, affects pulse intensity
```

**信号**：`fox_warning_shown`, `fox_warning_dismissed`

---

### 16. GoldenCountdown `res://demos/ring-toss/ui/golden_countdown.tscn`

**玩家看到**：金色南瓜旁一个逐渐缩小的圆环倒计时（4秒）

**结构**：
```
GoldenCountdown (Control)
├── RingProgress (TextureProgressBar) — circular, gold
│   └── PumpkinIcon (TextureRect) — 中心小南瓜图标
```

**Token 映射**：
| 属性 | Token |
|------|-------|
| 圆环色 (满) | `color.semantic.perfect` (gold) |
| 圆环色 (紧急 <1s) | `color.brand.red` |
| 圆环宽度 | 4px |
| 背景轨道 | `rgba(0,0,0,0.2)` |
| 整体大小 | 48×48px |
| 缩减动画 | linear, 4s → 0 |
| 紧急脉冲 | `animation.game.combo-pulse` 在 <1s 时触发 |

**Export 变量**：
```gdscript
@export var duration: float = 4.0
@export var urgent_threshold: float = 1.0
@export var follow_target: Node3D  # 世界坐标跟随南瓜
```

**信号**：`countdown_expired`, `countdown_cancelled`

---

## Token → Godot 映射规则

| Token 概念 | Godot 实现 |
|------------|-----------|
| `color.*` | `StyleBoxFlat.bg_color` / `Label.theme_override_colors` |
| `border` | `StyleBoxFlat.border_width_*` + `border_color` |
| `radius` | `StyleBoxFlat.corner_radius_*` |
| `box-shadow bottom bar` | 第二个 `Panel` 节点，偏移 Y，deeper color |
| `radial-gradient` (badges) | `ShaderMaterial` with simple radial gradient shader |
| `typography.family` | `FontFile` resource in theme |
| `typography.scale` | `Label.theme_override_font_sizes` |
| `text-shadow` | `Label` + duplicate `Label` offset (Y+2~3px, darker color) |
| `animation.easing` | `Tween.set_ease()` + `set_trans()` |
| `animation.duration` | `Tween.tween_property(...).set_duration()` |
| `inset shadow` | Overlap smaller darker `StyleBoxFlat` behind content |
| Star SVG | Import as `SVGTexture` or bake to `AtlasTexture` |

---

## 信号总线（EventBus 对接）

所有组件通过 `EventBus` autoload 接收游戏事件：

```gdscript
# EventBus.gd signals relevant to UI:
signal rep_completed(rep_index: int, result: String)
signal charge_changed(value: float)
signal score_changed(new_score: int, delta: int)
signal phase_started(phase_index: int, phase_name: String)
signal hand_switch(new_side: String)
signal ring_launched()
signal return_completed(timing: String)
signal burst_approaching(time_to_burst: float)
signal burst_triggered()
signal game_completed(stats: Dictionary)
signal rainbow_collected(score_bonus: int)
signal fox_approaching(direction: String, time_to_arrive: float)
signal fox_caught_pumpkin()
signal golden_pumpkin_spawned(world_position: Vector3)
signal golden_pumpkin_saved()
```
