# 添加新动作指南

本文档说明如何向 Motion Feedback 系统添加新的训练动作。

## 需要交付的内容

每个新动作需要提供以下 5 项：

### 1. PNG 序列帧

- 命名格式：`{prefix}_{00000}.png` 到 `{prefix}_{N}.png`
- 帧率：30fps
- 帧数：通常 100-200 帧（一个完整 rep 的去程+回程）
- 背景：透明 PNG
- 放置路径：`assets/motion/{action_key}/`

示例：`assets/motion/swing/swing_00000.png` ~ `swing_00119.png`（120 帧）

### 2. ROM 路径

动作在 900×580 画布上的运动轨迹。两种类型：

**直线 (line)**：起点 → 终点
```json
{
  "type": "line",
  "points": [[500, 330], [555, 235]]
}
```

**二次贝塞尔曲线 (quadratic)**：起点 → 控制点 → 终点
```json
{
  "type": "quadratic",
  "points": [[540, 430], [395, 360], [345, 195]]
}
```

起点 = 动作开始位置（手柄起始点），终点 = 动作最大幅度位置。

### 3. COP 面板参数

压力中心可视化区域的位置和大小（900×580 坐标）：

```json
{
  "center": [140, 430],
  "size": [250, 145],
  "safeSize": [192, 92],
  "radius": 36,
  "safeRadius": 28
}
```

| 字段 | 含义 |
|------|------|
| center | 面板中心点 [x, y] |
| size | 面板总尺寸 [宽, 高] |
| safeSize | 绿色安全区尺寸 [宽, 高] |
| radius | 面板圆角 |
| safeRadius | 安全区圆角 |

### 4. 速度标准

标准线缆速度范围，用于生成绿色目标区域：

```json
{
  "exercise": "动作英文全称",
  "repDuration": 2.5,
  "pullOutSpeed": { "min": 0.45, "max": 0.65 },
  "returnInSpeed": { "min": 0.30, "max": 0.43 }
}
```

| 字段 | 含义 |
|------|------|
| repDuration | 一次完整动作耗时（秒） |
| pullOutSpeed | 去程标准速度范围 (m/s) |
| returnInSpeed | 回程标准速度范围 (m/s) |

### 5. 帧在画布上的位置

序列帧图片在 900×580 画布中的放置区域：

```json
{
  "dir": "res://assets/motion/swing",
  "prefix": "swing",
  "count": 120,
  "fps": 30,
  "rect": [226, -18, 450, 600]
}
```

`rect` = `[x, y, width, height]`，即图片左上角坐标和显示尺寸。

## 去哪里填写

把上述数据加到 `motion_feedback_config.json` 的 `actions` 对象里：

```json
{
  "actions": {
    "row": { ... },
    "swing": { ... },
    "press": { ... },
    "你的新动作key": {
      "displayName": "显示名称",
      "speedProfileKey": "和 standardCableSpeedRange.exercises 里的 exercise 字段对应",
      "romPath": { ... },
      "copPanel": { ... },
      "athleteFrames": { ... }
    }
  }
}
```

同时在 `standardCableSpeedRange.exercises` 数组里加一条速度标准。

## 坐标系说明

- 画布尺寸：900×580
- 原点 (0,0)：左上角
- x 向右增大，y 向下增大
- 在 ActionCard 内嵌时，画布会被 `xMidYMid slice` 裁切到 2:3 竖向区域（左右裁切，只有中间约 386px 宽度可见）
- COP 面板在 ActionCard 外部渲染，不受裁切影响

## 参考现有动作

| Key | 显示名 | ROM 类型 | 帧数 | repDuration |
|-----|--------|---------|------|-------------|
| row | Lunge Single-Arm Row | line | 134 | 5.0s |
| swing | Squat Swing | quadratic | 120 | 2.5s |
| press | Single-Arm Incline Chest Press | line | 182 | 7.0s |

## 如何验证

在本地打开 `reference/reference.html`，它会加载 `assets/motion/` 下的 PNG 帧并播放动画。确认：

1. 人物帧显示位置正确
2. ROM 路径起终点和人物手柄位置吻合
3. COP 面板不和人物重叠
4. 速度区域（绿色带）在动画过程中合理移动
