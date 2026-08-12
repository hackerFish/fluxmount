# 发布与运营手册 (Publish & Operate)

本文件回答三件事：**别人怎么用这个技能**、**WorkBuddy 怎么加载它**、**你怎么看调用次数和反馈**。
作者：张昌宇 (Changyu Zhang)。协议：MIT。

---

## 一、别人怎么用（上传到平台之后）

FluxMount 是 **WorkBuddy 技能（Skill）**，发布后有两种分发方式：

### 方式 A：上架 WorkBuddy 技能市场（SkillHub / ClawHub）
- WorkBuddy 内置 **SkillHub 技能市场**，已收录 8 万+ 技能；另有开源技能集散地 **ClawHub**，会索引 GitHub 上的 skill 仓库。
- 把本仓库推到 GitHub（见下方命令），再把仓库地址提交到 ClawHub / SkillHub 发布入口即可。本仓库的 `manifest.yaml` 已含 `name / slug / version / tags / categories / homepage` 等跨平台元数据，提交时直接被识别。
- 上架后，**用户无需懂技术**：在 WorkBuddy 对话框说一句"帮我装一个能读写 NTFS 硬盘的技能"，WorkBuddy 会自动去技能市场匹配并安装；或直接在技能市场搜索 `FluxMount` 一键安装。

### 方式 B：GitHub 直接装（开发者向）
用户把仓库克隆到本地 skills 目录（见第二节），重启 WorkBuddy 即可使用，无需经过市场审核。

---

## 二、WorkBuddy 怎么"用到"这个技能

**关键点：技能只要落到目录，WorkBuddy 会自动加载，不需要任何注册或配置。**

放置位置（二选一）：

```bash
# 用户级（所有项目都能用，推荐）
~/.workbuddy/skills/fluxmount/

# 项目级（仅当前工程共享给团队）
{你的工程}/.workbuddy/skills/fluxmount/
```

目录里必须包含 `SKILL.md`（本仓库已有）。WorkBuddy 启动时会扫描 skills 目录，读取每个 `SKILL.md` 的 **frontmatter**：

- `name`：技能唯一名（本仓库为 `fluxmount`）
- `description`：**最重要**——写清楚"什么时候该用这个技能"和触发关键词。WorkBuddy 的匹配/触发引擎就是靠这段描述来判断"用户这句话要不要调用 FluxMount"。

当用户说出"Mac 怎么往 NTFS 盘写文件""外接硬盘复制不进去""让 NTFS 盘自动可读写"等语义时，WorkBuddy 会命中 `description` 里的触发条件，自动用 Skill 工具加载本技能并执行里面的工作流程。

> 所以：**想让更多人搜到、用到，SKILL.md 的 `description` 写得好不好是胜负手。** 本仓库已针对中文口语化场景（"插件传不进文件""各种插件都不行"）做了触发词覆盖。

---

## 三、怎么看调用次数和反馈

### 1. 平台侧（最省心）
- 若上架 **ClawHub / SkillHub**，平台作者后台通常会展示该技能的 **安装量 / Star / 用户反馈**。发布后在对应平台的"我的技能 / 作者中心"查看即可。
- WorkBuddy 内若提供技能作者面板，调用统计会在那里呈现（以平台实际功能为准）。

### 2. GitHub 侧（必看，免费且实时）
在 `https://github.com/ChangyuZhang/fluxmount` 的 **Insights** 标签页：
- **Traffic**：页面访问量、克隆数（最接近"被多少人看到/下载"的指标）
- **Stars / Forks**：受欢迎度与传播度
- **Issues**：Bug 报告与功能请求（= 反馈主渠道）
- **Discussions**（建议在仓库开启）：集中收集使用体验、答疑、好评

### 3. 关于"调用次数"的诚实说明
FluxMount 刻意**不做内建埋点/联网上报**——这是为了守住"安全可控、不臃肿、不偷传数据"的产品底线。因此：
- 本地私有使用：没有逐次调用计数（也没必要）。
- 要看"被广泛使用"的证据：以 **ClawHub/SkillHub 后台安装量 + GitHub Traffic/Stars/Issues** 为准。

### 运营建议（提升 star 与反馈）
1. 开启 GitHub **Discussions**，主动回复每一条 Issue/讨论（响应速度直接影响口碑与 star）。
2. 录一段"装之前只读 vs 装之后直接拖文件"的对比动图，放进 README 顶部。
3. 打好 `macos` / `ntfs` / `macfuse` 等话题标签，发到 V2EX、少数派、Reddit r/macsysadmin 等实操帖。
4. 竞品对比表已在 README 中，强调"国内网络专治 + dry-run 预览 + 可回退"三个差异化点。

---

## 四、发布命令（本地仓库已就绪，直接推）

```bash
cd FluxMount
git init
git add .
git commit -m "FluxMount v1.0.0 - macOS NTFS read-write skill by Changyu Zhang"
git branch -M main
git remote add origin https://github.com/ChangyuZhang/fluxmount.git
git push -u origin main
```

推上去后：去 ClawHub / SkillHub 提交仓库地址完成上架；在 GitHub 仓库开启 **Issues + Discussions**；在 README 顶部补一段对比动图。

---

<details>
<summary>English summary</summary>

**How others use it:** Publish to WorkBuddy's SkillHub / ClawHub marketplace (this repo's `manifest.yaml` is already compatible). Users install with one click or just by saying "install a skill that writes NTFS disks" in WorkBuddy. Developers can also `git clone` into `~/.workbuddy/skills/fluxmount/`.

**How WorkBuddy loads it:** No registration needed. Drop the folder under `~/.workbuddy/skills/fluxmount/` (user-level) or `{workspace}/.workbuddy/skills/fluxmount/` (project-level). WorkBuddy auto-reads `SKILL.md` frontmatter; the `description` field drives trigger matching.

**Call counts & feedback:** Marketplace author dashboards show installs/stars/feedback. For GitHub, use Insights → Traffic/Stars/Issues/Discussions. FluxMount intentionally has no telemetry (privacy-by-design); distribution signals come from marketplace stats + GitHub Insights.
</details>
