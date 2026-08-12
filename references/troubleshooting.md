# FluxMount · 排障手册

作者: 张昌宇 (Changyu Zhang)
本手册固化了真实踩坑经验，并吸收了社区竞品（macos-ntfs-smart-mount / Nigate / NTFS Tool / Mounty）的做法与已知限制。

---

## 一、根因速记

- macOS 原生 **NTFS 只读挂载**，任何 App/插件/脚本都无法写入 —— 不是插件问题，是系统锁了写权限。
- 解法 = 用 **ntfs-3g**（经 macFUSE 的 FUSE 接口）把分区**重新挂载为读写**。这一步**不删不改**盘内任何数据，只是换个挂载方式。

## 二、安装阶段典型坑

### 1. macFUSE 下载被墙（GitHub 连接重置）

- 现象: `curl: (56) Recv failure: Connection reset by peer`，下到 ~5MB 中断。
- 根因: 国内直连 GitHub release 不稳定。
- 解法: install.sh 已内置 kgithub / ghproxy 系列**国内镜像兜底**，会自动换源重试。若仍失败，开代理/VPN 手动下载 `macfuse-5.3.3.dmg` 双击安装后重跑。

### 2. Homebrew `brew install ntfs-3g` 报错 no bottle / Tier 3

- 现象: `Error: ntfs-3g: no bottle available!` + `Tier 3 configuration`。
- 根因: 2026 年 macOS 15（尤其 Intel）被 Homebrew 归为 Tier-3 旧系统，不再提供预编译 ntfs-3g bottle；`--build-from-source` 又要从 GitHub 拉源码（被墙）。
- **正确解法（关键）**: 用 `brew tap gromgit/homebrew-fuse` 后 `brew install ntfs-3g-mac`。该 tap 专为 macOS 维护，提供可用预编译包。这也是 macos-ntfs-smart-mount 的做法。
- 反例: 不要走 `--build-from-source`，新版 Xcode/Clang 会把老 C 代码的隐式函数声明、重复全局符号当**硬错误**（`1 warning and 1 error generated`），需额外加 `-Wno-implicit-function-declaration -fcommon` 仍可能失败。

### 3. 目录权限 not writable

- 现象: `Error: The following directories are not writable by your user: /usr/local/share/man/man8`
- 解法: `sudo chown -R $USER /usr/local/share/man/man8 && chmod u+w /usr/local/share/man/man8`，再重跑。

### 4. Homebrew 自动更新卡死

- 现象: 卡在 `Auto-updating Homebrew...` 假死。
- 解法: Ctrl+C 取消，重跑时带 `HOMEBREW_NO_AUTO_UPDATE=1`（install.sh 已内置）。

## 三、挂载阶段典型坑

### 5. 系统扩展未批准（最常见）

- 现象: 挂载报 `fusefs: failed to mount` / `FUSE cannot be used` / 盘停在只读的"新加卷"。
- 解法: 系统设置 → 隐私与安全性 → 点【允许】"Benjamin Fleischer"的系统软件 → **重启** → 重跑 `sudo mount-ntfs-rw`。
- 竞品提示: 部分旧教程让你进恢复模式改"降低安全性/允许内核扩展"——那是 **macFUSE 4.x (kext) 的做法**；macFUSE 5.x 用的是 **System Extension**，无需进恢复模式，只需在隐私与安全性里点允许。

### 6. "xxx 想访问可移除宗卷上的文件"弹窗

- 这是 macOS 的**访问权限**询问（不是删除！），点【允许】即可。我们的脚本不执行任何删除命令，只是卸载只读挂载 + 重新挂载。

### 7. 热插拔不自动挂载

- 多为后台弹了"访问可移除宗卷"权限框但无前台窗口看不到。去 系统设置 → 隐私与安全性 → 完全磁盘访问权限，把以下三个加进去，再拔插一次:
  - `/usr/local/bin/ntfs-automount`
  - `/usr/local/bin/mount-ntfs-rw`
  - `/usr/local/bin/ntfs-3g`
- 其次检查代理是否真注册: `launchctl print gui/$(id -u)/com.changyu.fluxmount` 应存在且 `runs>0`。

### 8. `launchctl load` 在 macOS 15 失效

- 现象: `launchctl list` 查不到、`launchctl load` 报 Input/output error。
- 根因: macOS 15 (Sequoia) 已弃用 `launchctl load`，且远程/沙箱环境会拦截写类 launchctl。
- 解法: 用现代方式 `launchctl bootout gui/$(id -u)/LABEL` 再 `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/xxx.plist`，且**必须在图形登录会话的真实终端**执行（WorkBuddy 沙箱内的 Bash 无法替你注册）。

### 9. Windows 快速启动导致挂载失败

- 来源: Nigate 的已知提示。若 NTFS 盘来自未彻底关机的 Windows（快速启动开启），可能挂载异常。需在 Windows 端彻底关机或关闭快速启动。

## 四、竞品经验借鉴（已吸收进本 skill）

- **macos-ntfs-smart-mount**: `gromgit/homebrew-fuse` + `ntfs-3g-mac` 的正确装法；安全弹出时杀掉 Spotlight/QuickLook 防止卸载卡死；中英双语文档。
- **Nigate**: 多 CDN 镜像（jsDelivr/statically）兜底 GitHub 被墙；GUI 实时监测 + 热插拔自动读写；多语言。
- **NTFS Tool**: 指数退避重试（5/10/20/60s）、防抖监测、孤立挂载目录清理、每盘失败追踪、ExFAT 免 sudo。
- **Mounty**: 用 macOS 内置实验性 NTFS 写（免 ntfs-3g），但苹果官方标注不稳定、有数据风险，本 skill 不采用。

## 五、自检、预览与卸载（安全可控）

- 健康检查: `bash install.sh --doctor`（报告 macFUSE / ntfs-3g / 脚本 / 免密 sudo / 代理 / 当前挂载 全绿即通过）。
- 改动预览: `bash install.sh --dry-run`（只打印将写入的路径，不改动任何系统）。
- 干净卸载/回退: `bash uninstall.sh`（移除代理、免密 sudo 规则、脚本；若 `~/.fluxmount-backup` 有安装前备份则还原；不动 macFUSE/ntfs-3g 本体）。
- 安全边界详见仓库根目录 `SAFETY.md`：本工具只重挂载、绝不删除或改动盘内数据。

由 张昌宇 (Changyu Zhang) 出品 · FluxMount
