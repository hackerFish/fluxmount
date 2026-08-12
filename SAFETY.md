# FluxMount · 安全与可回退说明

本文件面向"担心弄坏电脑 / 担心数据丢失"的用户，明确说明 FluxMount **改什么、不动什么、如何还原**。

## 本工具会改动的地方（全部可逆）

安装后，FluxMount 只会在你的系统里新增 / 覆盖以下**它自己的文件**，且安装前会自动备份被覆盖的文件到 `~/.fluxmount-backup`：

| 改动 | 路径 | 说明 |
|------|------|------|
| 挂载脚本 | `/usr/local/bin/mount-ntfs-rw` | 我们提供的核心脚本（覆盖前会备份） |
| 自动挂载入口 | `/usr/local/bin/ntfs-automount` | LaunchAgent 调用的入口（覆盖前会备份） |
| 免密 sudo 规则 | `/etc/sudoers.d/fluxmount` | **仅放行** `mount-ntfs-rw` 这一条命令免密码，不碰系统其他 sudo 配置（覆盖前会备份） |
| 开机/热插拔代理 | `~/Library/LaunchAgents/com.changyu.fluxmount.plist` | 自动挂载触发器（覆盖前会备份） |
| 第三方驱动（可选安装） | macFUSE、ntfs-3g | 开源驱动本体；来自官方或国内镜像，由 Homebrew / 官方 pkg 安装 |

## 本工具**绝不**做这些事

- ❌ **绝不删除、修改、移动你 NTFS 硬盘里的任何数据**。它只做一件事：把系统"只读挂载"的分区"重新挂载为读写"。已实测不影响盘内文件。
- ❌ 绝不执行 `rm -rf` 你的个人目录、文档、下载等。
- ❌ 绝不改动系统其他 sudoers、其他 LaunchAgent、其他磁盘。
- ❌ 绝不格式化、绝不读写你要保护的盘之外的内容。

## 受控执行（你始终掌握主动权）

- 所有需要管理员权限的步骤，都会由 **Homebrew / macOS 安装器** 当场弹窗向你索要密码，**不会偷偷提权**。
- 安装前想先看一眼会动哪里？先跑：
  ```bash
  bash install.sh --dry-run
  ```
  它会列出将要写入的每个路径，**不改动任何东西**。
- 系统扩展批准、重启这类关键决策，必须由你在图形界面手动点【允许】，脚本无法替你做。

## 如何回退 / 还原（可恢复）

随时一键还原到"安装前"的状态：

```bash
bash uninstall.sh
```

它会：

1. 卸载所有 FluxMount 产生的可读写挂载（用 `diskutil unmount`，安全弹出）；
2. 停掉并移除 `com.changyu.fluxmount` 自动挂载代理；
3. 删除免密 sudo 规则 `/etc/sudoers.d/fluxmount`；
4. 删除 `/usr/local/bin/mount-ntfs-rw`、`/usr/local/bin/ntfs-automount`；
5. **若 `~/.fluxmount-backup` 里存在安装前备份，则把原文件还原回去**（例如你之前自己放的同名脚本）。

> 说明：macFUSE / ntfs-3g 两个驱动本体不在卸载范围内（它们是独立开源软件）。若你想彻底移除它们，请另行用 `brew uninstall` 或官方卸载器，二者也不影响你的数据。

## 万一想更稳妥

- 在执行任何磁盘操作前，先把 NTFS 盘里的重要文件备份到别处（最佳实践，任何磁盘工具都建议）。
- 只在确认弹窗"访问可移除宗卷"时点【允许】—— 那是 macOS 的权限询问，不是删除提示。
