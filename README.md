# FluxMount — macOS NTFS Read-Write Toolkit

> [中文](#中文) · [English](#english)
>
> 让 macOS 自由读写外接 NTFS 硬盘 —— 傻瓜式、一次到位、插上即用、不再复发。
> Make macOS read & write external NTFS drives — one-shot setup, plug-and-use, never relapses.
>
> 作者 / Author: **张昌宇 (Changyu Zhang)** · 协议 / License: MIT

---

### 🔌 装前 vs 装后（Before / After）

| | 🚫 装前（原生 macOS） | ✅ 装后（FluxMount） |
|---|---|---|
| 写入文件 | 弹出"只读"，无法复制 / 拖入 | 直接拖进去，像本地盘一样用 |
| 传文件 | 各种插件、网盘都传不进去 | 即插即用，随意读写 |
| 每次插盘 | 要敲命令重新挂载 | 自动可读写（开机 + 热插拔） |
| 多盘 / 重名 | 易冲突、需手动处理 | 遍历挂载、保留原卷名 |
| 安全性 | — | 只重挂载、不删数据、可一键回退 |

> English: Before FluxMount, macOS mounts NTFS **read-only** — you can see the files but cannot write. After, your NTFS drive behaves like a native writable disk: plug in and drag files, auto-mount on boot & hotplug, fully reversible and safe.

## 中文

### 为什么需要它

macOS 原生对 NTFS 硬盘**只支持只读挂载**。你把 Windows 格式的 SSD / 移动硬盘插上 Mac，能看不能写，各种"传输助手""网盘插件"都传不进去 —— **这不是插件不行，是系统锁了写权限**。

FluxMount 用开源的 [macFUSE](https://github.com/macfuse/macfuse) + [ntfs-3g](https://github.com/tuxera/ntfs-3g) 把硬盘**重新挂载为可读写**，并配好开机 / 热插拔自动挂载，从此插上就能直接拖文件。

### 一键安装

```bash
bash install.sh            # 完整安装（自动装驱动、部署脚本、配自动挂载）
bash install.sh --doctor   # 只做健康检查，报告当前环境
bash install.sh --status   # 查看所有 NTFS 盘的可读写状态
bash install.sh --dry-run  # 只预览将要做什么，不改动任何系统
```

安装后只需**每个 Mac 一次**的人工操作：

1. 系统设置 → 隐私与安全性 → 点【允许】"Benjamin Fleischer"的系统软件
2. 重启
3. 插上 NTFS 盘，等 5~8 秒，自动可读写，无需再敲命令

用完安全弹出：`diskutil unmount /Volumes/<盘名>`

### 傻瓜式 & 安全设计

- **国内网络专治**：macFUSE 下载走 kgithub / ghproxy 多个国内镜像兜底；ntfs-3g 用 `brew tap gromgit/homebrew-fuse` + `brew install ntfs-3g-mac`（有预编译包），避开 Homebrew Tier-3 无包与 GitHub 被墙。
- **一次到位**：单命令安装 + `doctor` 自检 + `dry-run` 预览，自动处理"系统扩展批准 / 免密 sudo / 代理注册"三件最易翻车的事。
- **防复发**：开机（RunAtLoad）+ 热插拔（StartOnMount）双触发；幂等（已可读写则跳过，不干扰正在用的盘）；退避重试 + 写权限校验。
- **多盘支持**：遍历所有只读 NTFS 分区逐个重挂载，挂回原卷名（Finder 名字不变）。
- **安全可控、可回退**：免密 sudo 仅放行 `mount-ntfs-rw` 一条命令；**安装前自动备份被覆盖文件到 `~/.fluxmount-backup`**，`uninstall.sh` 可完整还原；**只重挂载、绝不删除或改动盘内数据**。详见 [SAFETY.md](SAFETY.md)。
- **下载可信**：安装 macFUSE 前校验代码签名（`pkgutil --check-signature`），防止下载被篡改。

### 竞品对比 & 我们的特色

| 能力 | macos-ntfs-smart-mount | Nigate | NTFS Tool | Mounty | **FluxMount** |
|------|:---:|:---:|:---:|:---:|:---:|
| 免费开源 | ✅ | ✅ | ✅ | ✅ | ✅ |
| macFUSE + ntfs-3g | ✅ | (封装) | ✅ | ❌(内置写) | ✅ |
| 国内镜像兜底 GitHub 被墙 | ❌ | ⚠️(多CDN) | ❌ | ❌ | ✅ **专治** |
| 规避 Homebrew Tier-3 无包 | ✅(ntfs-3g-mac) | — | ❌ | — | ✅ |
| 开机 + 热插拔自动挂载 | ❌(手动) | ✅(GUI) | 🚧(路线图) | ✅ | ✅ |
| 多盘支持 | ❌ | ⚠️ | ✅ | ❌ | ✅ |
| 命令行无 GUI 依赖 | ✅ | ⚠️ | ❌ | ✅ | ✅ |
| 健康检查 / 自检 | ❌ | ❌ | ❌ | ❌ | ✅ **doctor/status** |
| dry-run 预览 | ❌ | ❌ | ❌ | ❌ | ✅ |
| 干净卸载 / 可回退 | ❌ | ⚠️ | ❌ | ❌ | ✅ **备份还原** |
| 下载签名校验 | ❌ | ❌ | ❌ | ❌ | ✅ **独有** |
| 中文文档 / 品牌 | ✅ | ✅ | ✅ | ✅ | ✅ **张昌宇出品** |

> 我们吸收并改进了竞品优点：smart-mount 的 `ntfs-3g-mac` 正确装法与中英文档、Nigate 的多 CDN 镜像与热插拔、NTFS Tool 的退避重试与多盘处理；并补齐了它们都忽略的**国内网络适配、免密 sudo、代理注册、自检、dry-run、下载签名校验与可回退卸载**。

### 文件结构

```
fluxmount/
├── SKILL.md                 # WorkBuddy skill 入口
├── README.md                # 本文件（中/英双语）
├── SAFETY.md                # 安全与可回退说明
├── manifest.yaml            # OpenClaw / ClawHub 跨平台元数据
├── LICENSE                  # MIT (张昌宇)
├── scripts/
│   ├── mount-ntfs-rw        # 核心挂载(多盘/幂等/退避/校验/dry-run/status)
│   ├── ntfs-automount       # LaunchAgent 热插拔入口
│   ├── install.sh           # 傻瓜式一键安装 + doctor + status + dry-run
│   ├── uninstall.sh         # 干净回滚(仅回退自己的盘 + 恢复安装前备份)
│   └── doctor.sh            # 健康检查入口
└── references/
    └── troubleshooting.md   # 排障手册(含踩坑与竞品经验)
```

### 跨平台发布指南

FluxMount 的核心脚本是 POSIX bash，可在任何 macOS 终端运行；元数据按多平台格式提供：

- **WorkBuddy / SkillHub**：直接发布本目录（含 `SKILL.md`），或导入 `fluxmount.zip`。
- **ClawHub / OpenClaw**：使用 `manifest.yaml` 元数据，发布命令参考 `clawhub publish ./fluxmount --slug fluxmount --name "FluxMount" --version 1.0.0`。
- **GitHub / Gitee**：整仓库推送即可，README 即项目主页；建议打 `fluxmount` 主题标签（macos, ntfs, macfuse, ntfs-3g, automation）。

### 声明

挂载 / 修改磁盘有极低概率的数据风险，本工具按现状提供，作者不对任何数据损失负责。重要数据请先备份。NTFS 驱动底层依赖 macFUSE 与 ntfs-3g 的开源项目，版权归各自作者。

由 张昌宇 (Changyu Zhang) 出品 · FluxMount

---

## English

### Why you need it

macOS mounts NTFS external drives **read-only by default**. Plug a Windows-formatted SSD / USB disk into a Mac and you can see files but cannot write — and no "transfer assistant" or cloud-plugin can help, **because the OS itself locks write access**, not the apps.

FluxMount remounts the disk **read-write** using the open-source [macFUSE](https://github.com/macfuse/macfuse) + [ntfs-3g](https://github.com/tuxera/ntfs-3g), and wires up auto-mount on boot and hot-plug, so you can just drag files in after plugging in.

### One-shot install

```bash
bash install.sh            # full install (driver + scripts + auto-mount)
bash install.sh --doctor   # health check, report current environment
bash install.sh --status   # show read/write status of all NTFS disks
bash install.sh --dry-run  # preview only, change nothing
```

After install, one manual step **per Mac**:

1. System Settings → Privacy & Security → click **Allow** for "Benjamin Fleischer" system software
2. Reboot
3. Plug in the NTFS disk, wait 5–8s, it auto-mounts read-write — no more commands

Eject safely: `diskutil unmount /Volumes/<disk>`

### Foolproof & safe by design

- **China-network friendly**: macFUSE is downloaded via kgithub / ghproxy mirrors; ntfs-3g uses `brew tap gromgit/homebrew-fuse` + `brew install ntfs-3g-mac` (prebuilt bottle), avoiding Homebrew Tier-3 no-bottle and GitHub blocking.
- **One-shot**: single command + `doctor` self-check + `dry-run` preview; auto-handles the three fragile steps (system-extension approval / passwordless sudo / agent registration).
- **No relapse**: dual trigger (RunAtLoad + StartOnMount); idempotent (skips already read-write disks); retry with backoff + write-permission check.
- **Multi-disk**: remounts every read-only NTFS partition, keeping the original volume name in Finder.
- **Safe & reversible**: passwordless sudo grants only the `mount-ntfs-rw` command; **backs up overwritten files to `~/.fluxmount-backup` before install**; `uninstall.sh` fully restores; **only remounts — never deletes or alters your data**. See [SAFETY.md](SAFETY.md).
- **Trustworthy download**: verifies the macFUSE installer signature (`pkgutil --check-signature`) before installing.

### Comparison & our edge

| Capability | macos-ntfs-smart-mount | Nigate | NTFS Tool | Mounty | **FluxMount** |
|------|:---:|:---:|:---:|:---:|:---:|
| Free & open source | ✅ | ✅ | ✅ | ✅ | ✅ |
| macFUSE + ntfs-3g | ✅ | (wrapped) | ✅ | ❌(native) | ✅ |
| China mirror (GitHub blocked) | ❌ | ⚠️(multi-CDN) | ❌ | ❌ | ✅ **dedicated** |
| Avoid Homebrew Tier-3 no-bottle | ✅(ntfs-3g-mac) | — | ❌ | — | ✅ |
| Boot + hot-plug auto-mount | ❌(manual) | ✅(GUI) | 🚧(roadmap) | ✅ | ✅ |
| Multi-disk | ❌ | ⚠️ | ✅ | ❌ | ✅ |
| No GUI dependency | ✅ | ⚠️ | ❌ | ✅ | ✅ |
| Health check / self-test | ❌ | ❌ | ❌ | ❌ | ✅ **doctor/status** |
| dry-run preview | ❌ | ❌ | ❌ | ❌ | ✅ |
| Clean uninstall / rollback | ❌ | ⚠️ | ❌ | ❌ | ✅ **backup restore** |
| Download signature check | ❌ | ❌ | ❌ | ❌ | ✅ **unique** |
| Chinese docs / branding | ✅ | ✅ | ✅ | ✅ | ✅ **by Changyu Zhang** |

> We absorbed and improved on competitors: smart-mount's correct `ntfs-3g-mac` install and docs, Nigate's multi-CDN mirrors and hot-plug, NTFS Tool's backoff-retry and multi-disk handling — then added what all of them miss: **China-network support, passwordless sudo, agent registration, self-check, dry-run, signature verification, and reversible uninstall**.

### File structure

```
fluxmount/
├── SKILL.md                 # WorkBuddy skill entry
├── README.md                # this file (zh/en)
├── SAFETY.md                # safety & rollback notes
├── manifest.yaml            # OpenClaw / ClawHub cross-platform metadata
├── LICENSE                  # MIT (Changyu Zhang)
├── scripts/
│   ├── mount-ntfs-rw        # core remount (multi-disk/idempotent/retry/check/dry-run/status)
│   ├── ntfs-automount       # LaunchAgent hot-plug entry
│   ├── install.sh           # one-shot install + doctor + status + dry-run
│   ├── uninstall.sh         # clean rollback (only our disks + restore backup)
│   └── doctor.sh            # health-check entry
└── references/
    └── troubleshooting.md   # troubleshooting (pitfalls + competitor notes)
```

### Cross-platform publishing

Core scripts are POSIX bash and run in any macOS terminal; metadata ships in multi-platform formats:

- **WorkBuddy / SkillHub**: publish this directory (with `SKILL.md`) or import `fluxmount.zip`.
- **ClawHub / OpenClaw**: use `manifest.yaml`; e.g. `clawhub publish ./fluxmount --slug fluxmount --name "FluxMount" --version 1.0.0`.
- **GitHub / Gitee**: push the whole repo; README is the project homepage. Suggest topics: `macos`, `ntfs`, `macfuse`, `ntfs-3g`, `automation`.

### Disclaimer

Mounting / modifying disks carries a very low risk of data loss. Provided as-is, no warranty. Back up important data first. The NTFS driver relies on the open-source macFUSE and ntfs-3g projects, copyright their respective authors.

By 张昌宇 (Changyu Zhang) · FluxMount
