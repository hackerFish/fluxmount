# 跨平台发布矩阵 (Cross-Platform Matrix)

> 结论先行：**WorkBuddy、OpenClaw、Qoder、扣子(Coze) 都采用同一套 Anthropic「Agent Skills」开放标准**——核心就是一个"含 `SKILL.md` 的文件夹 + `name`/`description` frontmatter"。
> 所以 FluxMount **不用为每家重写**。差异只在三件事：**① 放到哪个目录 ② 怎么发布/安装 ③ 云端平台能不能跑本地 bash**。

作者：张昌宇 (Changyu Zhang) · MIT

---

## 一、为什么能跨平台

| 平台 | 技能格式 | 核心文件 | 触发方式 |
|------|----------|----------|----------|
| WorkBuddy / SkillHub | Agent Skills | `SKILL.md` + 目录 | 自然语言命中 `description` |
| OpenClaw / ClawHub | Agent Skills | `SKILL.md` + 目录 | 同上 |
| Qoder (阿里/灵码) | Agent Skills | `SKILL.md` + 目录（`.zip` 上传） | 同上 |
| 扣子 Coze | Agent Skills | `SKILL.md` + `scripts/references/assets/` | 同上 |

四家 frontmatter 都认 `name` / `description`；Qoder 额外要求 `version`（本仓库已补 `version: 1.0.0`）。未知字段（如 WorkBuddy 的 `agent_created: true`）其他平台会自动忽略，**安全**。

> FluxMount 已经是标准格式，直接复用即可，无需改写指令正文，只按平台选"投放位置/发布方式"。

---

## 二、各平台如何让用户用上 FluxMount

### 1. WorkBuddy（桌面端，跑在用户本机）
- **直接放目录**（用户级，全项目可用）：`~/.workbuddy/skills/fluxmount/`
- **项目级**（仅团队工程）：`{工程}/.workbuddy/skills/fluxmount/`
- 重启 WorkBuddy 即自动加载，对话说"Mac 怎么写 NTFS"即可触发。
- **上架市场**：推 GitHub 后提交到 SkillHub / ClawHub，用户市场内一键装。

### 2. OpenClaw / ClawHub（开源本地 Agent 框架）
- **放目录**：`~/.openclaw/workspace/skills/fluxmount/`
- **通用目录（推荐，各家 AI 编程工具都能识别）**：`~/.agents/skills/fluxmount/`
- **ClawHub 命令行**：
  ```bash
  npm i -g clawhub
  clawhub install fluxmount            # 若已上架 ClawHub
  # 或直接从 GitHub 装（Vercel 提供的 npx 方式）：
  npx skills add https://github.com/ChangyuZhang/fluxmount --skill fluxmount
  ```
- ClawHub 是**跨平台技能市场**：一次上架，所有兼容 Agent Skills 的桌面 agent（OpenClaw、Claude Desktop、DeerFlow 等）都能装 —— **这是"一处发布、多处可用"的最高杠杆**。

### 3. Qoder（阿里 / 通义灵码，Qoder / QoderWork / Qoder CLI）
- **项目级目录**：`.qoder/skills/fluxmount/SKILL.md`（结构同本仓库）
- **上传到 Qoder Cloud Agents（API）**：
  ```bash
  cd FluxMount && zip -r ../fluxmount.zip . -x '.git/*'
  curl -X POST "https://api.qoder.com.cn/api/v1/cloud/skills" \
    -H "Authorization: Bearer $QODER_PAT" \
    -F "file=@../fluxmount.zip"
  ```
  > 需要 `$QODER_PAT`（Qoder 个人访问令牌）。`name`/`description` 从 `SKILL.md` frontmatter 自动读取。
- **桌面 / QoderWork** 可从 Qoder 技能市场直接安装。
- ⚠️ 限制：Qoder **Cloud（纯云端）** 没有你的本地磁盘，跑不了本地挂载；需用 **QoderWork / 桌面端**（本地运行时）才能实际挂载 NTFS 盘。

### 4. 扣子 Coze
- 技能也是"含 `SKILL.md` 的文件夹"，结构 `SKILL.md` + `scripts/` + `references/` + `assets/`（后两者可选，本仓库已有 `scripts/references/`）。
- **发布**：扣子技能商店 `https://www.coze.cn/skills`；或用"对话生成技能 / 扣子编程上传 .skill"方式。
- **本地模式（关键）**：Coze 支持**本地 Skill**——本地部署的 Coze 环境可挂载技能目录、执行 Python/Shell 脚本。只有这种"本地/企业内网部署"形态能在用户 Mac 上跑 bash 挂载 NTFS。
- ⚠️ 限制：Coze **网页版 / 普通云端 bot** 运行在云端，**没有用户的本地 NTFS 盘**，无法执行挂载。此时 FluxMount 只能作为"知识/流程型技能"（教用户怎么做），不能自动执行。

---

## 三、云端平台的硬性边界（务必知道）

FluxMount 是**本地系统技能**：它要在**用户的 macOS 上**跑 bash、挂载**用户外接的物理 NTFS 硬盘**。

| 平台运行形态 | 能跑 FluxMount 吗 | 原因 |
|--------------|-------------------|------|
| WorkBuddy 桌面端 | ✅ 能 | 跑在本机 |
| OpenClaw 本地 | ✅ 能 | 跑在本机 |
| QoderWork / 桌面 | ✅ 能 | 跑在本机 |
| Coze 本地/企业内网部署 | ✅ 能 | 跑在本机 |
| Qoder Cloud（纯云） | ❌ 不能 | 云端无本地盘 |
| Coze 网页版/云端 bot | ❌ 不能 | 云端无本地盘 |

> 这不是 FluxMount 的缺陷，而是所有"本地硬件操作类"技能的共性。云端平台只能调用 API / 云端函数，碰不到你的硬盘。

---

## 四、推荐发布顺序（投入产出比最高）

1. **先上 ClawHub**（OpenClaw 官方面向）：一次提交，覆盖所有兼容 Agent Skills 的桌面 agent（OpenClaw、Claude Desktop 等）。命令见上。
2. **再上 WorkBuddy SkillHub**：自然语言触达桌面办公用户。
3. **Qoder**：上传 `.zip` 到 Cloud（面向 QoderWork 桌面用户）。
4. **扣子 Coze**：以"本地 Skill"形态发布，并明确标注"需本地部署环境"。

---

## 五、本仓库已做的跨平台兼容处理

- `SKILL.md` 含 `name` / `version: 1.0.0` / `description`，满足全部四家最小 frontmatter 要求。
- `scripts/` 为 POSIX bash，无平台专属依赖（仅 macOS 相关命令，属技能本体范畴）。
- `manifest.yaml` 带 `tags` / `categories` / `homepage`，供 ClawHub / SkillHub 索引。
- `README.md` 中英双语，提升全球平台可见度。
- 保留 `agent_created: true`（仅 WorkBuddy 识别，其他平台忽略）。

---

<details>
<summary>English summary</summary>

All four named platforms (WorkBuddy, OpenClaw/ClawHub, Qoder, Coze) follow the same Anthropic "Agent Skills" open standard: a folder with `SKILL.md` + `name`/`description` frontmatter. FluxMount needs no rewrite — only per-platform placement/publish. Local-only agents (WorkBuddy desktop, OpenClaw, QoderWork, Coze local deploy) can actually mount NTFS; pure-cloud agents (Qoder Cloud, Coze web) cannot reach the user's local disk. Highest-leverage move: publish to ClawHub once (covers all Agent-Skills-compatible desktop agents), then SkillHub, Qoder, and Coze-local.
</details>
