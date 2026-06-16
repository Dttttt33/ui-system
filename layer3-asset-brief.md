# Layer 3: Decorative Assets — AI Style Brief (Midjourney)

> 所有视觉资产由 Midjourney 生成，统一风格后导入 Godot。
> 本文档定义：全局风格锚点、资产清单、分类 prompt 模板、技术规格。

---

## 全局风格锚点

### Style DNA

| 维度 | 描述 |
|------|------|
| 整体风格 | Casual cartoon, thick outlines, flat shading with subtle gradients |
| 参考方向 | Hay Day × Cartoon Network × Nintendo casual |
| 色调 | Warm, saturated, high-key (明亮饱和，无暗角) |
| 轮廓 | 3-4px visible dark outlines on all objects |
| 光照 | Soft top-left light, no harsh shadows, gentle ambient occlusion only |
| 材质 | Matte/flat surfaces, no photorealism, no metallic/glass |
| 透视 | Slight 3/4 top-down for game objects; side-view for characters/animals |
| 情绪 | Cheerful, friendly, approachable — designed for casual female beginners |

### Midjourney 全局后缀（每个 prompt 必带）

```
--style raw --s 200 --ar [按需] --v 6.1
```

### 风格锁定 Prompt 前缀（所有资产共用）

```
cute cartoon farm game asset, thick black outlines, flat cel shading, 
bright saturated colors, simple shapes, white background, 
game sprite style, no text, no watermark
```

---

## 资产清单

### A. 游戏对象 (Game Objects)

| # | 资产 | 用途 | 尺寸建议 | 透明背景 |
|---|------|------|----------|----------|
| A1 | Ring — Normal (amber) | 玩家投掷的套圈 | 256×256 | Yes |
| A2 | Ring — Precision (blue) | 精准模式套圈 | 256×256 | Yes |
| A3 | Ring — Shockwave (red) | 冲击波套圈 | 256×256 | Yes |
| A4 | Target — Crop (watermelon) | 农作物目标 | 192×192 | Yes |
| A5 | Target — Crop (pumpkin) | 农作物目标 | 192×192 | Yes |
| A6 | Target — Crop (corn) | 农作物目标 | 192×192 | Yes |
| A7 | Target — Animal (sheep) | 动物目标 | 256×256 | Yes |
| A8 | Target — Animal (chicken) | 动物目标 | 192×192 | Yes |
| A9 | Target — Golden Pumpkin | 金色南瓜（高分目标） | 256×256 | Yes |
| A10 | Target — Rainbow Fruit | 彩虹水果（特殊奖励） | 256×256 | Yes |
| A11 | Fox | 偷南瓜的狐狸 | 256×320 | Yes |
| A12 | Stake/Post | 套圈落点的木桩 | 128×256 | Yes |

### B. 环境背景 (Environment)

| # | 资产 | 用途 | 尺寸建议 | 透明背景 |
|---|------|------|----------|----------|
| B1 | Sky layer | 天空渐变 + 云朵 | 1920×540 | No |
| B2 | Far hills | 远景山丘 | 1920×400 | Yes (底部) |
| B3 | Mid farm buildings | 中景谷仓/风车 | 1920×500 | Yes (底部) |
| B4 | Foreground grass | 前景草地 + 花 | 1920×300 | Yes (顶部) |
| B5 | Fence section | 木栅栏（可 tile） | 512×256 | Yes |
| B6 | Hay bale | 装饰干草捆 | 192×192 | Yes |
| B7 | Tree | 卡通果树 | 256×320 | Yes |
| B8 | Sunflower | 向日葵装饰 | 128×256 | Yes |

### C. UI 装饰 (UI Decorative)

| # | 资产 | 用途 | 尺寸建议 | 透明背景 |
|---|------|------|----------|----------|
| C1 | Action illustrations ×8 | ActionCard 里的动作示意图 | 400×600 | Yes |
| C2 | Trophy / Cup | EndPanel 装饰 | 192×192 | Yes |
| C3 | Ribbon banner | "NEW RECORD" 等横幅底图 | 512×128 | Yes |
| C4 | Confetti burst | 撒花粒子素材 | 512×512 | Yes |
| C5 | Star burst rays | 星星发光射线（Perfect 时） | 512×512 | Yes |

### D. Icon Set

| # | 资产 | 用途 | 尺寸建议 |
|---|------|------|----------|
| D1 | Ring icon | HUD/菜单 | 64×64 |
| D2 | Pumpkin icon | Golden count | 64×64 |
| D3 | Fox head icon | Fox warning | 64×64 |
| D4 | Star icon | Score rating | 64×64 |
| D5 | Hand L/R icons | 手侧指示 | 64×64 |
| D6 | Fire/combo icon | Combo 状态 | 64×64 |

---

## 分类 Prompt 模板

### A. 游戏对象

#### A1-A3: Rings

```
/imagine cute cartoon ring toss ring, thick black outlines, flat cel shading, 
bright [amber/blue/red] colored rubber ring, simple donut shape, slight 3D depth, 
game sprite style, single object centered, white background, 
no text, no watermark --style raw --s 200 --ar 1:1 --v 6.1
```

#### A4-A6: Crop Targets

```
/imagine cute cartoon [watermelon/pumpkin/corn], thick black outlines, 
flat cel shading, bright saturated colors, farm vegetable game sprite, 
simple round shape, sitting on ground, slight top-down 3/4 view, 
white background, no text, no watermark --style raw --s 200 --ar 1:1 --v 6.1
```

#### A7-A8: Animal Targets

```
/imagine cute cartoon [sheep/chicken], thick black outlines, flat cel shading, 
bright colors, chibi proportions, big head small body, friendly expression, 
farm animal game character, side view facing right, 
white background, no text, no watermark --style raw --s 200 --ar 1:1 --v 6.1
```

#### A9: Golden Pumpkin

```
/imagine cute cartoon golden pumpkin, thick black outlines, flat cel shading, 
shiny gold color with sparkle highlights, magical glowing effect, 
precious game collectible, simple shape, centered, 
white background, no text, no watermark --style raw --s 200 --ar 1:1 --v 6.1
```

#### A10: Rainbow Fruit

```
/imagine cute cartoon magical rainbow apple, thick black outlines, 
flat cel shading, rainbow gradient colors (red orange yellow green blue), 
sparkle effects, glowing, special power-up game item, centered, 
white background, no text, no watermark --style raw --s 200 --ar 1:1 --v 6.1
```

#### A11: Fox

```
/imagine cute cartoon fox character, thick black outlines, flat cel shading, 
orange fur, mischievous sneaky expression, holding something, 
full body side view, running pose, bushy tail, chibi proportions, 
farm game villain character, white background, 
no text, no watermark --style raw --s 200 --ar 4:5 --v 6.1
```

#### A12: Stake/Post

```
/imagine cute cartoon wooden stake post, thick black outlines, flat cel shading, 
simple brown wood grain texture, farm style, stuck in green grass patch, 
game target post for ring toss, centered, 
white background, no text, no watermark --style raw --s 200 --ar 1:2 --v 6.1
```

### B. 环境背景

#### B1: Sky

```
/imagine cartoon farm game sky background, horizontal panorama, 
bright blue gradient sky, fluffy white clouds, warm sunlight, 
cheerful atmosphere, flat illustration style, no ground visible, 
game background layer, no text --style raw --s 200 --ar 16:5 --v 6.1
```

#### B2-B3: Parallax Layers

```
/imagine cartoon farm game background layer, horizontal panorama, 
[rolling green hills with wildflowers / red barn and white windmill with silo], 
bright saturated colors, thick outlines, flat cel shading, 
side scrolling game background, bottom transparent area, 
no text, no watermark --style raw --s 200 --ar 16:5 --v 6.1
```

#### B4: Foreground Grass

```
/imagine cartoon grass foreground layer, thick blades of green grass, 
small colorful wildflowers scattered, flat cel shading, thick outlines, 
bright green, horizontal strip, game foreground decoration, 
transparent top, no text --style raw --s 200 --ar 16:3 --v 6.1
```

#### B5-B8: Props

```
/imagine cute cartoon [wooden farm fence section / hay bale / fruit tree / sunflower], 
thick black outlines, flat cel shading, bright saturated colors, 
simple shapes, farm decoration game prop, centered, 
white background, no text, no watermark --style raw --s 200 --ar 1:1 --v 6.1
```

### C. UI 装饰

#### C1: Action Illustrations

```
/imagine cute cartoon fitness exercise illustration, [specific exercise name], 
simple stick figure style person doing the movement, thick outlines, 
flat colors, minimal detail, green and brown color scheme, 
instructional pose diagram, white background, 
no text, no watermark --style raw --s 200 --ar 2:3 --v 6.1
```

运动列表（替换 `[specific exercise name]`）：
- Kettlebell swing
- Bicep curl with resistance band
- Deep squat
- Lawnmower pull
- Standing row
- Shoulder press
- Lateral raise
- Deadlift

#### C4-C5: Effects

```
/imagine cartoon confetti explosion burst, colorful paper pieces flying outward, 
red yellow green blue purple, celebration effect, flat style, 
transparent background feel, centered radial burst, game VFX sprite, 
no text, no watermark --style raw --s 200 --ar 1:1 --v 6.1
```

### D. Icons

```
/imagine cute cartoon game icon set, flat cel shading, thick outlines, 
[ring / golden pumpkin / fox head / star / left hand / fire], 
single icon, simple shape, bright colors, 64x64 pixel art style, 
centered on white background, no text --style raw --s 200 --ar 1:1 --v 6.1
```

---

## 技术规格

### 导出要求

| 属性 | 值 |
|------|---|
| 格式 | PNG-32 (alpha channel) |
| 色彩空间 | sRGB |
| 最大尺寸 | 2048×2048 (Godot import limit) |
| 命名规范 | `category_name_variant.png` (e.g. `target_pumpkin_golden.png`) |

### 后处理流程

1. **Midjourney 出图** → 选最佳 variant → Upscale (U1-U4)
2. **Remove.bg / Photoshop** → 去白背景，生成 alpha
3. **检查轮廓** → 确保 outline 完整，无断裂
4. **统一尺寸** → 按表格 resize，保持 power-of-2 friendly
5. **导入 Godot** → Import as `Texture2D`, filter: nearest (pixel) 或 linear (smooth)

### 风格一致性检查清单

- [ ] 轮廓线粗细一致（3-4px at export size）
- [ ] 色彩饱和度匹配 Layer 1 tokens（green=#6EC531, amber=#F5A623, red=#E8453A）
- [ ] 无 photorealistic 元素（no photo textures, lens flare, bokeh）
- [ ] 光照方向统一（top-left）
- [ ] 比例协调（animal ≈ 1.3× crop size, fox ≈ 1.5× animal）
- [ ] 表情友好（no scary/aggressive faces）

---

## Midjourney 调参指南

| 参数 | 推荐值 | 说明 |
|------|--------|------|
| `--v` | 6.1 | 最新版本，cartoon 理解最好 |
| `--style raw` | 必带 | 减少 MJ 自作主张的美化 |
| `--s` | 150-250 | Stylize 适中，太高会偏离指令 |
| `--ar` | 按资产 | sprites 用 1:1, 背景用 16:5 |
| `--no` | photorealistic, 3d render, shadow | 排除写实元素 |
| `--chaos` | 0-20 | 低 chaos 保持一致性 |

### 如果出图不一致

1. 用 `--sref [URL]` 锁定第一张满意的图作为 style reference
2. 或用 `--cref [URL]` 锁定角色一致性（fox, animals）
3. 批量出图时用同一个 seed: `--seed 12345`

---

## 优先级

| 优先级 | 资产 | 原因 |
|--------|------|------|
| P0 | A4-A9, A11, A12 | 核心 gameplay 对象 |
| P0 | B1-B4 | 场景可见最低要求 |
| P0 | C1 (×8 exercises) | ActionCard 必需 |
| P1 | A1-A3, A10 | Ring 可用简单 shader 替代 |
| P1 | B5-B8, D1-D6 | 装饰增强，非阻塞 |
| P2 | C2-C5 | UI 特效，可后期补 |
