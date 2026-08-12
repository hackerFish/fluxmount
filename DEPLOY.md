# FluxMount 多平台发布手册（实测命令）

本文件给出的命令均来自各平台官方文档/实测，**直接照抄即可**。所有操作只在你自己的账号下进行，不影响任何机器配置。

> 仓库已公开：`https://github.com/hackerFish/fluxmount`
> 作者署名：`张昌宇 <476929948@qq.com>`

---

## 1. ClawHub（一次发布，覆盖所有兼容 Agent Skills 的桌面 agent）

ClawHub 是 OpenClaw 生态的公开技能 registry，发布后 `clawhub install @hackerFish/fluxmount` 或 `openclaw skills install @hackerFish/fluxmount` 即可安装。

### 步骤
```bash
# ① 安装 CLI（任选其一）
npm i -g clawhub            # 或 pnpm add -g clawhub

# ② 登录（用你的 GitHub 账号 OAuth；账号需注册满 14 天才能过上传门槛）
clawhub login

# ③ 预览发布（强烈建议先 dry-run，检查元数据与文件规范，不上传）
clawhub skill publish . --dry-run

# ④ 正式发布（在仓库根目录执行，仓库根已有 SKILL.md）
clawhub skill publish . \
  --slug fluxmount \
  --name "FluxMount" \
  --version 1.0.0 \
  --changelog "首版发布：macOS NTFS 读写、插上即用、开机与热插拔自动挂载、安全可回退、国内网络加固" \
  --tags "ntfs,macos,macfuse,ntfs-3g,filesystem,skill,agent-skills,external-drive,read-write"
```

也可用网页端：访问 `https://clawhub.ai/skills/publish` 直接上传整个仓库文件夹。

也可以用仓库内封装脚本：`./deploy/clawhub.sh`（需先 `clawhub login`）。

### 发布后管理
```bash
clawhub whoami                                   # 查看当前身份
clawhub skill publish . --version 1.1.0 --changelog "修复触发词匹配"   # 更新版本
clawhub list                                      # 已安装列表
```
> ClawHub 会跑自动安全检查，新版本可能短暂不出现在公开目录，直到审核完成——属正常。

---

## 2. Qoder（以 .zip 上传自定义 Skill）

Qoder 通过 API 上传 zip。**注意**：Qoder Cloud 是纯云端，没有你的物理外接硬盘，挂载动作无法在云端真正执行；上传仅用于跨平台技能收录/展示。在 Qoder 桌面端 / 本地形态下才能真挂载。

### 步骤
生成 Qoder 专用 zip（仓库内脚本会自动重新打包，SKILL.md 位于 `fluxmount/` 一级子目录，符合要求）：
```bash
QODER_PAT=你的Qoder令牌 ./deploy/qoder.sh
```

或手动上传（zip 已就绪于 `/Users/matiansa/cy/c/fluxmount-qoder.zip`）：
```bash
curl -X POST "https://api.qoder.com/api/v1/cloud/skills" \
  -H "Authorization: Bearer $QODER_PAT" \
  -F "name=fluxmount" \
  -F "type=custom" \
  -F "description=FluxMount - macOS NTFS read-write skill by Changyu Zhang" \
  -F "file=@fluxmount-qoder.zip"
```
- 端点：`https://api.qoder.com/api/v1/cloud/skills`（阿里云版为 `https://api.qoder.com.cn/api/v1/cloud/skills`）
- 成功返回 `201 Created`，含 `id`（如 `skill_019e...`）。
- 绑定到 Agent（可选）：
  ```bash
  curl -X PUT "https://api.qoder.com/api/v1/cloud/agents/agent_你的ID" \
    -H "Authorization: Bearer $QODER_PAT" -H "Content-Type: application/json" \
    -d '{"version":1,"skills":[{"type":"custom","skill_id":"skill_你的ID"}]}'
  ```
- 版本更新：重新打包改名 `fluxmount-v2.zip` 再 POST 一次即可（服务端版本自增）。

---

## 3. GitHub Topics（提升可被搜索/发现概率）

在 `https://github.com/hackerFish/fluxmount` 页面右侧「About → ⚙️ → Topics」中点加，粘贴以下标签（每行一个，回车添加）：

```
ntfs
macos
macfuse
ntfs-3g
filesystem
agent-skills
claude-skills
skill
external-drive
hard-drive
read-write
mount
automation
china
hackintosh
```

也可用 API 一次性设置（需带你的 GitHub PAT）：
```bash
curl -X PUT "https://api.github.com/repos/hackerFish/fluxmount/topics" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -d '{"names":["ntfs","macos","macfuse","ntfs-3g","filesystem","agent-skills","claude-skills","skill","external-drive","hard-drive","read-write","mount","automation","china","hackintosh"]}'
```

---

## 4. SkillHub / WorkBuddy（用户侧自动加载，无需你额外发布）

用户只需把 `fluxmount/` 文件夹放到：
- 用户级：`~/.workbuddy/skills/fluxmount/`
- 项目级：`{工程}/.workbuddy/skills/fluxmount/`

WorkBuddy 启动扫描 `SKILL.md` 的 `description` 触发词即可调用。若想上架 WorkBuddy 技能市场，按 WorkBuddy 官方「推荐市场」提交入口提交仓库地址即可（manifest.yaml 已带好元数据）。

---

## 5. 扣子 Coze（本地 Skill 模式）

网页/云端 bot 无法执行本地挂载，仅「本地部署 / 本地 Skill」形态可用。发布方式：在 Coze 的「技能」→「本地技能」中挂载仓库目录，或按 Coze 官方本地 Skill 规范上传。详见 `PLATFORMS.md`。

---

## 发布顺序建议
1. **GitHub**（已完成，已公开）
2. **ClawHub**（覆盖所有桌面 agent，杠杆最高）
3. **Qoder**（补全跨平台收录）
4. **GitHub Topics**（顺手提高可发现性）
5. **SkillHub / 扣子**（按需）
