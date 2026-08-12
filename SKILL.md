---
name: fluxmount
version: 1.0.0
description: FluxMount - 让 macOS 自由读写外接 NTFS 硬盘，傻瓜式、一次到位、插上即用、不再复发。当用户把 NTFS 格式的移动硬盘或 SSD 接到 Mac 却无法写入或复制文件、抱怨各种插件都传不进去、问 Mac 怎么往 NTFS 盘里写文件、或想要开机与热插拔自动可读写挂载时使用。覆盖国内网络典型坑（GitHub 被墙、Homebrew Tier-3 无预编译包、新版 Clang 编译报错、launchctl 弃用、沙箱禁 sudo），并提供一键安装、健康自检与干净卸载。作者 张昌宇 (Changyu Zhang)。
agent_created: true
---

# FluxMount (macOS NTFS Read-Write)

让 Mac 自由读写外接 NTFS 硬盘。底层基于开源的 macFUSE + ntfs-3g，并配套开机与热插拔自动挂载，做到"插上即用、不再复发"。作者：**张昌宇 (Changyu Zhang)**，协议 MIT。

## 什么时候用这个 skill

- 用户把 NTFS 格式外接硬盘接到 Mac，能看不能写 / 复制失败 / 插件传不进文件。
- 用户问"Mac 怎么写 NTFS""有没有免费 NTFS 工具""能不能让盘自动可读写"。
- 用户已装过驱动但仍只读，需要排查（系统扩展未批准 / 免密 sudo 未配 / 代理未注册）。

## 根因（务必先讲给用户听）

macOS 原生对 NTFS **只支持只读挂载**。无论用什么 App、插件、脚本，只要系统把它挂成只读，谁都写不进去。这不是插件不行，是系统层面锁了写权限。**解法不是找更强插件，而是用 ntfs-3g 把它重新挂成读写。** 用户盘里的数据不会被改动（我们只是重新挂载，不删不改任何文件）。

## 工作流程

### 1. 识别硬盘（只读命令，无需 sudo）

```bash
diskutil list
system_profiler SPStorageDataType | grep -iA6 ntfs
mount | grep -i ntfs
```

确认磁盘节点（如 /dev/disk12s2）、卷名，以及它被 macOS 以 `(ntfs, ... read-only ...)` 只读挂载。

### 2. 一键安装（用户本机终端运行）

把 skill 的 scripts/ 目录复制到本机后运行：

```bash
bash install.sh            # 完整安装
bash install.sh --doctor   # 只做健康检查，报告当前环境与问题
bash install.sh --status   # 查看所有 NTFS 盘的可读写状态
bash install.sh --dry-run  # 只打印将要做什么，不改动任何系统（先给安全感）
```

install.sh 会自动：检测系统 → 装 macFUSE（国内镜像兜底 GitHub 被墙）→ 装 ntfs-3g（用 `brew tap gromgit/homebrew-fuse` + `brew install ntfs-3g-mac`，规避 Homebrew Tier-3 无包）→ 部署脚本到 /usr/local/bin → 配置免密 sudo → 注册开机 + 热插拔自动挂载（LaunchAgent，现代 bootstrap 方式）→ 立即挂载一次。**安装前会自动备份被覆盖的文件到 ~/.fluxmount-backup，可随时回退。**

> 注意：沙箱/远程环境通常禁止 sudo 与 launchctl 写操作，安装与批准系统扩展必须在用户**真实终端**完成，本 skill 负责生成脚本与指引，不会在你的电脑上做不可控的改动。

### 3. 用户只需一次的人工步骤（每个 Mac 一次）

1. 打开 系统设置 → 隐私与安全性
2. 找到"来自开发者 Benjamin Fleischer 的系统软件已被阻止"，点【允许】
3. 重启电脑
4. 重启后插上 NTFS 盘，等 5~8 秒即自动可读写，无需再敲命令

### 4. 验证

```bash
mount | grep macfuse              # 应看到 (macfuse, ... rw ...)
bash install.sh --doctor          # 全绿即通过
```

Finder 里直接往盘里拖文件即可。用完安全弹出：`diskutil unmount /Volumes/<盘名>`。

## 资源

- `scripts/mount-ntfs-rw` — 核心挂载脚本（多盘、幂等、退避重试、写权限校验、`--dry-run`、`--status` 状态查询）
- `scripts/ntfs-automount` — LaunchAgent 热插拔入口
- `scripts/install.sh` — 傻瓜式一键安装 + doctor 自检 + dry-run 预览
- `scripts/uninstall.sh` — 干净回滚（恢复安装前备份）
- `references/troubleshooting.md` — 排障手册（吸收竞品经验 + 国内网络坑）
- `README.md` — 面向 GitHub / SkillHub / ClawHub 的发布文档与竞品对比
- `SAFETY.md` — 安全与可回退说明（明确本工具改什么、不动什么、如何还原）
- `manifest.yaml` — OpenClaw / ClawHub 跨平台元数据

## 本 skill 相对竞品的特色（作者沉淀）

- **国内网络专治**：macFUSE 下载走 kgithub / ghproxy 多个国内镜像兜底；ntfs-3g 用 gromgit tap 的 `ntfs-3g-mac`（有预编译包），避开 Homebrew 对旧 macOS 的 Tier-3 无包与 GitHub 被墙。
- **傻瓜式一次到位**：单命令安装 + doctor 自检 + dry-run 预览，把"系统扩展批准 / 免密 sudo / 代理注册"三件最容易翻车的事都自动化或半自动化。
- **防复发**：开机（RunAtLoad）+ 热插拔（StartOnMount）双触发；幂等（已可读写则跳过，不干扰正在用的盘）；指数退避重试 + 写权限校验。
- **多盘支持**：遍历所有只读 NTFS 分区逐个重挂载，挂回原卷名（Finder 名字不变）。
- **安全可控**：免密 sudo 仅放行 `mount-ntfs-rw` 一条命令；安装前自动备份被覆盖文件，uninstall 可完整还原；**只重挂载、绝不删除或改动盘内数据**。

> 踩坑经验（已固化到 troubleshooting.md）：GitHub 被墙用国内镜像；Homebrew `brew install ntfs-3g` 在 2026 年 macOS 15 Intel 上因 Tier-3 无 bottle 失败，应改 `ntfs-3g-mac`；新版 Xcode/Clang 把隐式函数声明当硬错误导致源码编译失败；`launchctl load` 在 macOS 15 已弃用，改用 `launchctl bootstrap gui/$(id -u)`；Bash 工具沙箱会禁 sudo/launchctl 写操作，验证需用户本机执行。
