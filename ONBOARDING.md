# FluxMount 上架清单（傻瓜版）

作者：张昌宇 (Changyu Zhang) · GitHub: [@hackerFish](https://github.com/hackerFish)
邮箱：476929948@qq.com

本文件给你一步步照着做即可。⚠️ 凡标注「在你自己的电脑上执行」的步骤，都**不要**在别人的机器/沙箱里跑——尤其涉及 `git push` 和账号登录。

---

## 0. 先决条件（一次搞定）

1. 在你自己的电脑上登录 GitHub 网页 → 进入 **Settings → Emails**，确认 `476929948@qq.com` 已验证（否则 commit 不会挂到你账号下，显示灰色未关联）。
2. 在 GitHub 新建一个**空仓库**，名字叫 `fluxmount`，**不要**勾选自动生成 README（保持空仓库）。
3. 本机装好 `git`，并登录 `gh`（`brew install gh` 后执行 `gh auth login`，选 GitHub.com、HTTPS、按提示浏览器授权）。

---

## 1. 推到 GitHub（在你自己电脑的终端执行）

> 仓库已在 `/Users/matiansa/cy/c/FluxMount/` 完成 `git init` 与 3 个 commit，作者已写成你。把下面命令复制到**你登录了 GitHub 的终端**执行：

```bash
cd FluxMount
git branch -M main
git remote add origin https://github.com/hackerFish/fluxmount.git
git push -u origin main
```

推完去 `https://github.com/hackerFish/fluxmount` 看一眼，应能看到 SKILL.md、README.md、scripts/ 等全部文件，且 commit 作者是「张昌宇」。

---

## 2. ClawHub 上架（覆盖所有兼容 Agent Skills 的桌面 agent）

ClawHub 是跨平台技能市场，**一次发布**即可让 OpenClaw、Claude Desktop 等所有兼容 Agent Skills 的本地 agent 装上。

- 方式 A（推荐）：在支持 `clawhub` 的终端直接
  ```bash
  clawhub publish ./FluxMount        # 或按平台提示指向上面的 GitHub 仓库
  ```
- 方式 B：打开 ClawHub 官网 → 提交 GitHub 仓库地址 `https://github.com/hackerFish/fluxmount` → 填名称/简介（可直接复用 `manifest.yaml` 内容）→ 提交审核。
- 用户侧安装（给你做宣传用）：
  ```bash
  clawhub install fluxmount
  # 或
  npx skills add hackerFish/fluxmount
  ```

---

## 3. SkillHub / WorkBuddy 上架

WorkBuddy 用户既可以直接放目录用，也可以上架 SkillHub 市场被搜索到。

- **直接可用（无需上架）**：用户把文件夹放到
  - 用户级：`~/.workbuddy/skills/fluxmount/`
  - 项目级：`{工程}/.workbuddy/skills/fluxmount/`
  WorkBuddy 启动即扫描 `SKILL.md`，靠 `description` 触发。
- **上架市场**：打开 WorkBuddy → 技能/推荐市场 → 发布技能 → 选择本地 `FluxMount` 目录或填写 GitHub 地址 `https://github.com/hackerFish/fluxmount` → 提交。上架后用户说「帮我装个能读写 NTFS 硬盘的技能」即可自动匹配安装。

---

## 4. Qoder 上架（上传 zip）

Qoder 接受 `.zip` 格式的技能包。我们已经打好 **`fluxmount-qoder.zip`**（标准 `fluxmount/` 包裹结构）。

- **方式 A（界面上传，推荐）**：
  1. 打开 Qoder → Settings / Skills（或 `管理技能`）→ 导入技能 / Import Skill。
  2. 选择「从 zip 导入」→ 选中 `fluxmount-qoder.zip`。
  3. 确认技能名 `fluxmount`、触发描述无误 → 启用。
  4. 在 QoderWork / 桌面版里对 NTFS 磁盘说「帮我挂载这个 NTFS 硬盘可读写」即可执行。
- **方式 B（API，CI 用）**：
  ```bash
  curl -X POST https://<你的Qoder域名>/api/v1/cloud/skills \
    -H "Authorization: Bearer $QODER_TOKEN" \
    -F "file=@fluxmount-qoder.zip"
  ```
- ⚠️ **纯云端 Qoder Cloud 跑不了本地挂载**（云端没有你的物理硬盘），需用 QoderWork / 桌面版，或当作「知识/流程型技能」教用户怎么做。

目录形态（开发者手动放）：`.qoder/skills/fluxmount/`，把 `fluxmount/` 目录内容放进去即可。

---

## 5. 扣子 Coze 上架（本地 Skill 模式）

扣子网页版/云端 bot **无法执行本地 bash 挂载**（云端无你的硬盘）。请用「本地 Skill」形态：

- 本地部署的 Coze / 支持挂载 skills 目录的环境：把 `fluxmount/` 目录放到 Coze 的 skills 挂载目录（参考其文档的 `skills/<name>/SKILL.md` 约定），重启即生效。
- 技能商店 `coze.cn/skills`：提交时选「本地技能 / Local Skill」类型，填写 GitHub 地址 `https://github.com/hackerFish/fluxmount`，简介复用 `manifest.yaml`。
- 网页版用户得到的是「指引型技能」（告诉用户怎么做），而非自动挂载——这是所有动本地硬件技能的共性限制。

---

## 6. 发布后：怎么看调用次数和反馈

- **平台后台**：ClawHub / SkillHub / Qoder / Coze 上架后，作者控制台会显示安装量、Star、用户反馈。
- **GitHub（免费实时最直观）**：
  - 仓库 **Insights → Traffic**：页面访问量、克隆量（最接近「被多少人下载」）。
  - **Stars / Forks / Issues / Discussions**：反馈主渠道。建议在仓库开启 **Discussions**（Settings → Features → 勾选 Discussions）。
- **本地私有使用无逐次计数**：FluxMount 刻意**不做内建埋点/联网上报**，守住「安全可控、不偷传数据」的底线。要看「被广泛使用」的证据，以平台后台 + GitHub Insights 为准。

---

## 7. 发布顺序建议（杠杆最高）

1. **GitHub 先推** → 2. **ClawHub**（一次覆盖所有桌面 agent）→ 3. **SkillHub/WorkBuddy** → 4. **Qoder 上传 zip** → 5. **扣子本地 Skill**。
发完后补一段「装前只读 vs 装后直接拖文件」的对比动图到 README 顶部，最能拉 star。
