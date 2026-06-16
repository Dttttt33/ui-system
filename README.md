# UI System — Demo Asset Generation Skill

A Claude Code skill that reads a game design doc and auto-generates three HTML previews for art/copy/asset audit.

## How to Use

Clone this repo, open the folder in Claude Code — the `/demo-asset-gen` skill is automatically available.

## Two Modes

| Trigger | What it does |
|---------|-------------|
| `/demo-asset-gen <策划案URL>` | 读策划案 → 基于 Layer 1 tokens → 输出三个 HTML（ui/copy/assets） |
| `/demo-asset-gen learn <修改后的文件夹>` | 对比 revision 框 vs generated → 提取 pattern → 写入 `revision-rules.json` → 下次自动应用 |

## Generate Mode

Input: 策划案飞书文档 URL（或本地 markdown）

Output:
```
ui-system/demo-{name}/
├── ui-preview.html       # UI 组件 live preview（有动画、正确尺寸）
├── copy-preview.html     # 文案位：slot + context + AI generated + revision 框
└── assets-preview.html   # 贴图资产：MJ prompt + revision 框
```

- UI preview 质量 = `components-preview.html`（动画、不裁切、Layer 1 tokens 渲染）
- 文案和贴图每一项都有双栏：AI 生成版 + 空白 revision 框供美术填写

## Learn Mode

Input: 美术 audit 并填写了 revision 框的 HTML 文件夹

Process:
1. 扫描所有非空 revision textarea
2. 对比 original vs revised，提取可泛化 pattern
3. 写入 `revision-rules.json`（prompt 规则 / copy 规则 / UI 规则）
4. 下次 generate 时自动读取并应用

越用越准。

## Repo Structure

```
.claude/skills/demo-asset-gen/   # Skill 定义（Claude Code 自动识别）
tokens.json                      # Layer 1 Design Tokens（生成的基础）
components-preview.html          # UI preview 质量标杆
layer2-components.md             # 16 组件 spec
layer3-asset-brief.md            # Midjourney style brief
dev-export/                      # 开发交付件（GDScript / JSON / Guide）
demo-ring-toss/                  # 示例输出（套圈 demo）
```

## Layer 1 Style Rules (Built-in)

- Colors: green `#6EC531`, amber `#F5A623`, red `#E8453A`, gold `#FFD700`
- Fonts: Luckiest Guy (display/HUD) + Fredoka (body/UI)
- Depth: border + bottom bar — **NO drop-shadow, ever**
- Panels: cream `#FFF5D6` + gold border + 4px + bottom bar
- Min text size: 18px body / 22px HUD (readable at 1.5m on TV)
- Star shape: rounded fat curves, not sharp points
- Badge buttons: radial-gradient sphere, border-radius 20px

## Target

- Engine: Godot 4.3+ / C# (.NET 8)
- Display: 16:9 landscape, TV/projector, standing 1.5m
- Audience: casual female beginners
- AI generation: Midjourney v6.1
