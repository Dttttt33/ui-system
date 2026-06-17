# Motion Feedback UI Component - Godot Integration Spec

版本：2026-06-16  
对应组件：`ui-preview.html` 中的 `9. MOTION FEEDBACK`  
当前参考实现：`cop-rom-speed-ui-versions.html`

## 1. 组件目标

`Motion Feedback` 是体感训练游戏中的实时动作反馈组件，用来同时表达：

- ROM：动作幅度 / 线缆位移路径
- Speed：线缆移动速度是否在标准范围内
- COP：压力中心 / 重心稳定性
- Direction：用户下一步应该沿哪个方向运动
- Rep Phase：当前动作处于去程、回程或未来可恢复的 Hold 阶段

该组件不是普通装饰 HUD，而是训练中的实时纠错界面。Godot 接入时应优先保证反馈与传感器数据同步。

当前版本已移除：

- 顶部提示牌 `Coach Ticket`
- 固定 HUD 标签 `ROM 68%` / `COP 82%`

动作提示和数值可由游戏主 HUD 或教学流程在组件外部承载，本组件内部只负责运动反馈图形本身。

## 2. 当前展示动作

当前 UI 只显示 3 个动作，其余动作数据可以保留但不渲染。

| Key | Display Name | 当前用途 |
| --- | --- | --- |
| `row` | `Lunge Single-Arm Row` | 弓步单臂划船 |
| `swing` | `Squat Swing` | 深蹲摆举 |
| `press` | `Single-Arm Incline Chest Press` | 单臂上斜推胸 |

当前 HTML 中通过以下列表控制可见动作：

```js
const visibleActionKeys = ["row", "swing", "press"];
```

Godot 中建议使用同样的 key 作为动作配置索引。

## 3. 视觉 Token

来自现有 Layer 2 UI token preview。

| Token | Value | 用途 |
| --- | --- | --- |
| `green` | `#6EC531` | 达标状态、目标区域、圆点内层 |
| `green_dark` | `#4A9B1E` | 达标圆点外层、描边 |
| `red` | `#E8453A` | ROM 圆点未进入目标区域 |
| `red_dark` | `#C43028` | 未达标圆点外层 |
| `blue_light` | `#87CEEB` | ROM 全路径虚线 |
| `blue` | `#4A9DD9` | ROM 已完成进度轨迹 |
| `panel_fill` | `#FFF5D6` | 外层面板 |
| `text_dark` | `#4A3728` | 深色文字 |

字体建议：

- 标题 / 强提示：`Luckiest Guy`
- 普通 UI 文案：`Fredoka`

Godot 字体资源建议放在：

```text
res://common/fonts/LuckiestGuy-Regular.ttf
res://common/fonts/Fredoka-Regular.ttf
res://common/fonts/Fredoka-SemiBold.ttf
```

## 4. Godot 场景建议

建议新建：

```text
res://common/ui/motion_feedback/motion_feedback.tscn
res://common/ui/motion_feedback/motion_feedback.gd
res://common/ui/motion_feedback/rom_path_overlay.gd
res://common/ui/motion_feedback/cop_panel.gd
res://data/motion_feedback_config.json
```

推荐节点结构：

```text
MotionFeedbackPanel (Control)
├── PanelFrame (PanelContainer)
├── Stage (Control)                      # 设计坐标 900 x 580
│   ├── AthleteFrame (TextureRect)        # PNG 序列帧人物
│   ├── CopPanel (Control)                # 圆角矩形 COP
│   │   ├── SafeArea                      # 绿色虚线圆角矩形
│   │   ├── CrossLines                    # 横纵中心线
│   │   ├── CopTrail                      # 压力中心轨迹
│   │   └── CopDot                        # 当前 COP 圆点
│   ├── RomPathOverlay (Control)          # ROM 路径、目标区、进度
│   ├── RomMarker (Control/Sprite2D)      # ROM 圆点
│   ├── DirectionArrow (Control/Sprite2D) # 方向箭头
│   └── HoldCue (Control)                 # 暂时隐藏，后续可恢复
```

Stage 内部建议固定使用 900 x 580 的设计坐标，再整体缩放到实际屏幕。

## 5. 设计坐标系

当前 HTML SVG 使用：

```text
viewBox = 0 0 900 580
```

Godot 中建议：

```gdscript
const DESIGN_SIZE := Vector2(900, 580)
```

所有 ROM 路径、COP 面板、人物图片摆放都先按 `900 x 580` 计算，然后用 Stage 的实际尺寸统一缩放。

## 6. 动作配置

建议 Godot 使用 JSON 或 Dictionary 保存动作 UI 配置。

```json
{
  "row": {
    "displayName": "Lunge Single-Arm Row",
    "coachText": "PULL TO BODY",
    "romPath": {
      "type": "line",
      "points": [[500, 330], [555, 235]]
    },
    "copPanel": {
      "center": [205, 430],
      "size": [260, 145],
      "safeSize": [200, 92],
      "radius": 36,
      "safeRadius": 28
    },
    "athleteFrames": {
      "dir": "res://assets/motion/01_lunge_single_arm_row",
      "prefix": "lunge_single_arm_row",
      "count": 134,
      "fps": 30,
      "rect": [360, 24, 390, 520]
    }
  },
  "swing": {
    "displayName": "Squat Swing",
    "coachText": "SWING UP",
    "romPath": {
      "type": "quadratic",
      "points": [[540, 430], [395, 360], [345, 195]]
    },
    "copPanel": {
      "center": [140, 430],
      "size": [250, 145],
      "safeSize": [192, 92],
      "radius": 36,
      "safeRadius": 28
    },
    "athleteFrames": {
      "dir": "res://assets/motion/03_squat_swing",
      "prefix": "squat_swing",
      "count": 120,
      "fps": 30,
      "rect": [226, -18, 450, 600]
    }
  },
  "press": {
    "displayName": "Single-Arm Incline Chest Press",
    "coachText": "PRESS FORWARD",
    "romPath": {
      "type": "line",
      "points": [[430, 405], [330, 145]]
    },
    "copPanel": {
      "center": [150, 430],
      "size": [250, 145],
      "safeSize": [192, 92],
      "radius": 36,
      "safeRadius": 28
    },
    "athleteFrames": {
      "dir": "res://assets/motion/04_single_arm_incline_chest_press",
      "prefix": "single_arm_incline_chest_press",
      "count": 182,
      "fps": 30,
      "rect": [285, 38, 390, 520]
    }
  }
}
```

注意：不要在 Godot 正式项目中使用本机绝对路径 `D:/...`。请把 PNG 序列帧复制到 `res://assets/motion/...` 下，并统一英文文件名。

## 7. 标准线缆速度范围

以下 JSON 是绿色目标区域的标准移动速率来源。

```json
{
  "standardCableSpeedRange": {
    "unit": "m/s",
    "exercises": [
      {
        "exercise": "Single-Arm Lunge Row",
        "repDuration": 5.0,
        "pullOutSpeed": {
          "min": 0.18,
          "max": 0.23
        },
        "returnInSpeed": {
          "min": 0.12,
          "max": 0.15
        }
      },
      {
        "exercise": "Squat Swing",
        "repDuration": 2.5,
        "pullOutSpeed": {
          "min": 0.45,
          "max": 0.65
        },
        "returnInSpeed": {
          "min": 0.30,
          "max": 0.43
        }
      },
      {
        "exercise": "Single-Arm Incline Chest Press",
        "repDuration": 7.0,
        "pullOutSpeed": {
          "min": 0.13,
          "max": 0.18
        },
        "returnInSpeed": {
          "min": 0.08,
          "max": 0.12
        }
      }
    ]
  }
}
```

映射关系：

| UI Key | Speed Config Exercise |
| --- | --- |
| `row` | `Single-Arm Lunge Row` |
| `swing` | `Squat Swing` |
| `press` | `Single-Arm Incline Chest Press` |

## 8. ROM 组件定义

### 8.1 蓝色虚线路径

颜色：`#87CEEB`

定义：完整 ROM 行程路径。

功能：告诉用户这次动作的理论运动路径。

Godot 实现建议：

- 自定义 `Control._draw()`
- 将路径采样成点列表
- 使用 dashed line 绘制
- dash pattern 建议：`dash = 4`, `gap = 14`

### 8.2 蓝色进度轨迹

颜色：`#4A9DD9`

定义：当前已完成的 ROM 轨迹。

规则：

- 去程：从路径起点画到当前点
- 回程：从路径尾端重新开始画到当前点
- 透明度：约 `0.5`

回程逻辑示例：

```gdscript
if forward:
    progress_start = 0.0
    progress_end = motion_rom
else:
    progress_start = motion_rom
    progress_end = 1.0
```

### 8.3 白色活动虚线

颜色：`rgba(255,255,255,0.88)`

定义：当蓝色进度轨迹覆盖蓝色虚线路径时，被覆盖部分显示成白色虚线。

Godot 实现建议：

- 先画完整蓝色虚线
- 再画蓝色进度粗线
- 最后只在 `progress_start..progress_end` 区间重新画一段白色虚线

### 8.4 绿色目标区域

颜色：绿色半透明粗线。

定义：基于标准线缆速度范围生成的可接受速度带。

功能：提示用户当前速度/进度应该落在哪个范围。ROM 圆点在该区域内则为绿色，否则为红色。

当前 HTML 的转换逻辑如下，Godot 可直接复刻：

```gdscript
func get_standard_speed_zone(standard: Dictionary, cycle: float) -> Dictionary:
    var forward := cycle < 0.5
    var half_phase := cycle * 2.0 if forward else (cycle - 0.5) * 2.0
    var range := standard.pullOutSpeed if forward else standard.returnInSpeed
    var avg_speed := (range.min + range.max) / 2.0

    var min_progress := range.min / avg_speed * half_phase
    var max_progress := range.max / avg_speed * half_phase

    var start: float
    var end: float

    if forward:
        start = min(min_progress, max_progress)
        end = max(min_progress, max_progress)
    else:
        start = min(1.0 - max_progress, 1.0 - min_progress)
        end = max(1.0 - max_progress, 1.0 - min_progress)

    var center := half_phase if forward else 1.0 - half_phase
    var min_span := 0.14

    start = clamp(start, 0.0, 1.0)
    end = clamp(end, 0.0, 1.0)

    if end - start < min_span:
        start = center - min_span / 2.0
        end = center + min_span / 2.0

    if start < 0.0:
        end -= start
        start = 0.0

    if end > 1.0:
        start -= end - 1.0
        end = 1.0

    return {
        "start": clamp(start, 0.0, 1.0 - min_span),
        "end": clamp(end, min_span, 1.0)
    }
```

## 9. ROM 圆点

定义：当前用户动作在 ROM 路径上的位置。

当前样式：

- 两层圆形
- 带轻微阴影
- 无白色描边

状态逻辑：

| 状态 | 颜色 | 含义 |
| --- | --- | --- |
| 在绿色目标区域内 | 绿色 | 当前速度 / 位置达标 |
| 在绿色目标区域外 | 红色 | 当前速度 / 位置不达标 |

判断逻辑：

```gdscript
var in_green_zone := motion_rom >= zone_start and motion_rom <= zone_end
```

## 10. 方向箭头

定义：提示当前动作方向。

当前样式：

- 蓝色系
- 双层箭头
- 保留高光
- 无白色描边

方向逻辑：

```gdscript
var next_t := clamp(motion_rom + direction * 0.02, 0.0, 1.0)
var p := sample_path(motion_rom)
var next := sample_path(next_t)
var angle := atan2(next.y - p.y, next.x - p.x)
```

箭头位置：

```gdscript
arrow.position = rom_point + Vector2(62, 0)
arrow.rotation = angle + deg_to_rad(90)
```

## 11. 人物序列帧

定义：每个动作对应一组 PNG 序列帧。

当前逻辑：

- 人物序列帧是 preview 模式的主时钟
- ROM 圆点、箭头、蓝色进度轨迹使用同一个 `motion_rom`
- 这样视觉上像是人物动作驱动 UI

当前 HTML 逻辑：

```js
const repDuration = standardSpeed
  ? standardSpeed.repDuration * 1000
  : frameDriven ? (frameCount / frameFps) * 1000 : 3300;

const cycle = (elapsed % repDuration) / repDuration;
const frameIndex = Math.round(cycle * (frameCount - 1));
const frameMotion = frameIndex / (frameCount - 1);
const motionRom = frameMotion <= .5
  ? frameMotion / .5
  : (1 - frameMotion) / .5;
```

Godot 建议：

```gdscript
func update_preview_motion(delta: float) -> void:
    elapsed += delta
    var cycle := fmod(elapsed, rep_duration) / rep_duration
    var frame_index := roundi(cycle * float(frame_count - 1))
    athlete_frame.texture = frames[frame_index]

    var frame_motion := float(frame_index) / float(frame_count - 1)
    motion_rom = frame_motion / 0.5 if frame_motion <= 0.5 else (1.0 - frame_motion) / 0.5
    motion_rom = clamp(motion_rom, 0.02, 1.0)
```

实际游戏接入传感器后，建议以硬件数据驱动：

```gdscript
motion_rom = sensor.cable_position_normalized
cable_speed_mps = sensor.cable_speed_mps
cop_position = sensor.cop_normalized
```

人物动画可以作为教练示范继续播放，也可以跟随 `motion_rom` 做帧同步。

## 12. COP 组件

COP = Center of Pressure，压力中心 / 重心稳定性。

**渲染位置：COP panel 在 ActionCard 外部、卡片下方独立渲染，不在 MotionFeedbackPanel SVG 内部。**

原因：ActionCard 内嵌 MotionFeedbackPanel 时使用 `preserveAspectRatio="xMidYMid slice"` 将 900×580 横向画布裁切到 2:3 竖向 IconArea。COP panel 通常位于画布左下角 (x=140~205, y=430)，在 slice 裁切后会被裁掉。因此 COP 作为独立 SVG/Control 渲染在卡片正下方。

当前外形：

- 圆角矩形
- 内部有绿色虚线安全区域
- 有横纵中心线
- COP 圆点会在区域内移动

Godot 数据结构：

```gdscript
cop_panel = {
    "center": Vector2(205, 430),
    "size": Vector2(260, 145),
    "safe_size": Vector2(200, 92),
    "radius": 36,
    "safe_radius": 28
}
```

实时输入建议：

```gdscript
func set_cop_normalized(value: Vector2) -> void:
    # value 建议范围：(-1,-1) 到 (1,1)，中心为 (0,0)
    var half_size := cop_panel.size * 0.5
    cop_dot.position = cop_panel.center + Vector2(
        value.x * half_size.x,
        value.y * half_size.y
    )
```

COP 安全区域用于判断稳定性：

```gdscript
var stable := abs(value.x) <= safe_half_width and abs(value.y) <= safe_half_height
```

## 13. HOLD 组件

当前状态：隐藏。

保留内容：

- 黄色虚线圈
- 顺时针填充圈
- `HOLD` 字样
- 第 3 次动作到达终点时触发的逻辑

当前 HTML 中通过：

```html
data-hold-visuals="off"
```

Godot 建议保留 `HoldCue` 节点，默认：

```gdscript
hold_cue.visible = false
```

未来恢复时：

```gdscript
if rep_index == 2 and motion_rom >= 1.0:
    hold_cue.visible = true
    hold_cue.progress = hold_progress
```

## 14. 运行时输入接口

Godot 组件建议暴露以下接口：

```gdscript
func set_exercise(action_key: String) -> void
func set_sensor_rom(progress: float, cable_speed_mps: float) -> void
func set_cop(value: Vector2) -> void
func set_rep_index(index: int) -> void
func set_preview_mode(enabled: bool) -> void
```

输入字段：

| Field | Type | Range | 说明 |
| --- | --- | --- | --- |
| `action_key` | String | `row/swing/press` | 当前动作 |
| `rom_progress` | float | `0..1` | 当前 ROM 位置 |
| `cable_speed_mps` | float | `m/s` | 当前线缆速度 |
| `cop` | Vector2 | 建议 `-1..1` | 当前 COP 偏移 |
| `rep_index` | int | `0..n` | 当前第几次动作 |
| `preview_mode` | bool | true/false | 是否使用 PNG 序列帧驱动 |

## 15. 绘制顺序

从底到顶：

1. Stage 背景
2. 地面 / 场地线
3. 人物 PNG 序列帧
4. COP 圆角矩形
5. 蓝色 ROM 虚线路径
6. 绿色目标区域
7. 蓝色 ROM 进度轨迹
8. 白色活动虚线
9. ROM 圆点
10. 方向箭头
11. HOLD cue，当前隐藏

## 16. Path Sampling

### 直线路径

```gdscript
func sample_line(p0: Vector2, p1: Vector2, t: float) -> Vector2:
    return p0.lerp(p1, clamp(t, 0.0, 1.0))
```

### 二次贝塞尔路径

```gdscript
func sample_quadratic(p0: Vector2, c: Vector2, p1: Vector2, t: float) -> Vector2:
    t = clamp(t, 0.0, 1.0)
    var u := 1.0 - t
    return u * u * p0 + 2.0 * u * t * c + t * t * p1
```

绘制 dashed path 时建议先采样成 80 到 120 个点，再按累计长度切分 dash/gap。

## 17. 接入注意事项

- 正式项目中不要读取 `D:/...`，请复制素材到 `res://assets/motion/...`
- PNG 序列帧较多，建议按动作预加载当前动作，切换动作时释放上一动作贴图
- 如果硬件已能提供线缆位置，ROM 圆点应以硬件数据为准
- 如果硬件只提供速度，需由 gameplay 层积分成 `rom_progress`
- 绿色目标区域来自标准速度范围，不代表用户真实位置
- 红/绿圆点是实时反馈，建议不要加过强动画，避免误导用户
- HOLD 组件现在隐藏，但不要删节点和逻辑

## 18. 最小 Godot 更新流程

```gdscript
func _process(delta: float) -> void:
    if preview_mode:
        update_preview_motion(delta)
    else:
        motion_rom = sensor_rom_progress
        cable_speed_mps = sensor_cable_speed

    var standard := speed_config[action_key]
    var zone := get_standard_speed_zone(standard, cycle)
    var in_zone := motion_rom >= zone.start and motion_rom <= zone.end

    rom_marker.set_success(in_zone)
    rom_marker.position = sample_rom_path(motion_rom)
    direction_arrow.position = rom_marker.position + Vector2(62, 0)
    direction_arrow.rotation = get_path_direction_angle(motion_rom)

    rom_overlay.set_path(rom_path)
    rom_overlay.set_progress(motion_rom, forward)
    rom_overlay.set_target_zone(zone.start, zone.end)

    cop_panel.set_cop(cop_value)
```

## 19. 当前功能状态

| 功能 | 当前状态 |
| --- | --- |
| 3 个动作组件 | 已实现 |
| PNG 序列帧人物 | 已实现 |
| ROM 蓝色虚线路径 | 已实现 |
| ROM 蓝色进度轨迹 | 已实现 |
| 进度覆盖处白色虚线 | 已实现 |
| 绿色目标区域按标准速度移动 | 已实现 |
| ROM 圆点区内绿、区外红 | 已实现 |
| 箭头方向提示 | 已实现 |
| COP 圆角矩形 | 已实现 |
| 顶部提示牌 Coach Ticket | 已移除 |
| 固定 HUD 标签 ROM/COP | 已移除 |
| HOLD 视觉 | 已隐藏，逻辑保留 |
