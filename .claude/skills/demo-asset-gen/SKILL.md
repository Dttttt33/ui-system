# demo-asset-gen

> 输入策划案 → 自动输出三个 HTML 预览（UI / 文案 / 贴图），供美术 audit 和修改。
> 支持 learn from revision：对比修改前后，沉淀 style correction rules。

## 触发方式

```
/demo-asset-gen <策划案飞书文档URL或本地路径>
```

或自然语言："帮我跑一下这个策划案的素材生成"

## 两个模式

### 模式 1：Generate（默认）

输入策划案 → 输出三个 HTML 到 `ui-system/demo-{name}/`

### 模式 2：Learn from Revision

输入修改后的 HTML → 对比原始生成版，提取 diff → 沉淀规则

---

## 模式 1：Generate

### 输入

- 策划案 URL（飞书文档）或本地 markdown 文件路径
- 可选：demo 名称（默认从文档标题推断）

### 输出

```
ui-system/demo-{name}/
├── ui-preview.html       # UI 组件预览（Layer 2 级别质量）
├── copy-preview.html     # 文案位预览（slot + context + generated + revision 框）
└── assets-preview.html   # 贴图资产 + MJ prompt（generated + revision 框）
```

### 生成流程

#### Step 1: 读取策划案

```bash
lark-cli docs +fetch --api-version v2 --doc "<url_or_token>" --scope full --detail full
```

如果是本地文件，直接 Read。

#### Step 2: 分析策划案，提取

从策划案中提取以下信息：

1. **UI 组件清单**：有哪些 HUD、面板、提示、反馈组件
2. **文案位清单**：所有需要文字的位置（标签、反馈、提示、按钮等）
3. **贴图资产清单**：游戏对象、环境、UI 装饰、图标

#### Step 3: 读取 Layer 1 Design Tokens

```
Read /Users/dantong/ui-system/tokens.json
```

所有生成必须基于 Layer 1 tokens。核心规则：
- 颜色：green=#6EC531, amber=#F5A623, red=#E8453A, gold=#FFD700
- 字体：Luckiest Guy (display/HUD) + Fredoka (body/UI)
- 深度 = border + bottom bar，**永远没有 drop-shadow**
- 面板 = cream (#FFF5D6) + gold border (#D4A84B) + 4px border + bottom bar
- 按钮 = solid color + thick bottom border + top shine
- Badge = radial-gradient sphere, border-radius: 20px
- 圆角星 = rounded fat curved points (not sharp)
- 文字 min 18px body / 22px HUD（1.5m 距离可读）

#### Step 4: 读取 Revision Rules（如果存在）

```
Read /Users/dantong/ui-system/revision-rules.json
```

如果存在，在生成时应用这些已学到的规则。例如：
- "prompt 中总是加 'no gradient background' 因为美术每次都要删"
- "PERFECT 文案改成 NAILED IT 因为更符合 tone"
- "fox 的 prompt 加 'cartoon stylized not realistic'"

#### Step 5: 生成三个 HTML

##### ui-preview.html

- 质量标准 = 现有的 `components-preview.html`（已 approve 的版本）
- 有动画（CSS keyframes）
- 尺寸正确，不被裁切
- 每个组件有：
  - 编号 + 名称标签
  - 场景路径（`res://...`）
  - 简短说明（为了干啥）
  - 实际渲染的 live preview
- 使用 Layer 1 tokens 的完整 CSS 变量
- 包含 Luckiest Guy + Fredoka 字体
- 背景 = 游戏场景渐变（天空→草地）

##### copy-preview.html

- 四列表格：Slot | Context | Generated | Revision
- Slot = 标签分类 (HUD/FEEDBACK/PROMPT/END/SYSTEM) + 位置名
- Context = 这个文案位的需求和约束
- Generated = AI 生成的文案（用正确字体渲染）
- Revision = 空白 textarea（橙色虚线框）
- 底部附 copy guidelines（字体规则、tone、大小写规则）
- 文案规则：
  - HUD/feedback: Luckiest Guy, UPPERCASE
  - System/instructional: Fredoka, sentence case
  - Tone: encouraging, playful, never punishing
  - 短！玩家运动中只瞄 <0.5s

##### assets-preview.html

- 每个资产一张卡片：ID + 名称 + 尺寸 + 优先级 badge
- 每张卡片包含 asset-purpose（用途说明）
- **双栏 prompt**：
  - 左 = AI Generated（绿色标签，深色代码块，有 copy 按钮）
  - 右 = Revision（橙色虚线 textarea，placeholder "Paste your revised prompt here..."）
- Midjourney prompt 规则：
  - 全局前缀：`cute cartoon farm game asset, thick black outlines, flat cel shading, bright saturated colors, simple shapes, white background, game sprite style, no text, no watermark`
  - 全局后缀：`--style raw --s 200 --v 6.1` + 按需 `--ar`
  - Sprites: `--ar 1:1`
  - 背景: `--ar 16:5`
  - 人物: `--ar 4:5` 或 `2:3`
- 底部附 post-processing checklist 和 consistency tips (--sref, --cref, --seed)

---

## 模式 2：Learn from Revision

### 触发

```
/demo-asset-gen learn <修改后的HTML路径或文件夹>
```

或自然语言："学习一下美术改了什么"

### 流程

#### Step 1: 对比 diff

对每个 HTML 文件，对比 revision textarea 中的内容 vs 原始 generated 内容。

对于 assets-preview.html：
- 扫描所有 `.prompt-revision` textarea
- 非空的 = 美术做了修改
- 提取：资产 ID + 原始 prompt + 修改后 prompt

对于 copy-preview.html：
- 扫描所有 `.revision-input` textarea
- 非空的 = 有修改
- 提取：slot 名 + 原始文案 + 修改后文案

对于 ui-preview.html：
- 对比文件 git diff（如果有 git）
- 或者对比和原始生成版的区别

#### Step 2: 分析 pattern

从所有 revision 中提取可泛化的规则：

**Prompt revisions:**
- 是加了什么词？（例如总是加 "no gradient"）
- 是删了什么？（例如总是删 "slight 3D depth"）
- 是改了描述方式？（例如 "chibi" → "SD style"）
- 是改了参数？（例如 --s 200 → --s 150）

**Copy revisions:**
- 是 tone 调整？（更 casual? 更 short?）
- 是具体词替换？（PERFECT → NAILED IT?）
- 是大小写/格式变更？

**UI revisions:**
- 是尺寸调整？
- 是颜色微调？
- 是组件结构变更？

#### Step 3: 写入 revision-rules.json

```json
{
  "last_updated": "2026-06-16",
  "demo_source": "ring-toss",
  "prompt_rules": [
    {
      "type": "always_add",
      "value": "no gradient background",
      "reason": "美术每次都要手动删 gradient bg",
      "applies_to": "all"
    }
  ],
  "copy_rules": [
    {
      "type": "replace",
      "original": "PERFECT!",
      "revised": "NAILED IT!",
      "reason": "tone 更 casual",
      "applies_to": "feedback"
    }
  ],
  "ui_rules": [
    {
      "type": "sizing",
      "description": "End panel stat cards 需要更大 padding",
      "applies_to": "end-panel"
    }
  ]
}
```

路径：`/Users/dantong/ui-system/revision-rules.json`

#### Step 4: 确认学习结果

输出给用户：
- 学到了 N 条新规则
- 列出每条规则的摘要
- 下次生成时会自动应用

---

## 文件依赖

| 文件 | 用途 |
|------|------|
| `/Users/dantong/ui-system/tokens.json` | Layer 1 design tokens（必读） |
| `/Users/dantong/ui-system/components-preview.html` | UI preview 的质量标杆 |
| `/Users/dantong/ui-system/revision-rules.json` | 已学到的 revision 规则（可能不存在） |

## 注意事项

- 这是 coding agent 用的 skill，不是 AMI
- 输出是三个独立 HTML，不是一个
- UI preview 必须有动画、正确尺寸、不裁切
- 文案和贴图都有双栏（generated + revision）
- Learn 模式会累积规则，不会覆盖之前的
- 优先级标注：P0（核心 gameplay 必需）/ P1（增强）/ P2（后期补）
