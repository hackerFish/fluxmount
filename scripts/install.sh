#!/bin/bash
# ============================================================================
#  FluxMount  ·  install.sh  (傻瓜式一键安装)
#  作者: 张昌宇 (Changyu Zhang)
#  功能: 让 Mac 自由读写外接 NTFS 硬盘。自动检测环境、装好 macFUSE + ntfs-3g、
#        部署脚本、配置免密 sudo 与开机/热插拔自动挂载。
#  用法:
#      bash install.sh            # 完整安装
#      bash install.sh --doctor   # 只做健康检查，报告当前环境与问题
#      bash install.sh --dry-run  # 仅预览将要做什么，不改动任何系统
#      bash install.sh --uninstall# 卸载(同 uninstall.sh)
#
#  安全: 安装前自动备份被覆盖的文件到 ~/.fluxmount-backup；绝不删除用户数据；
#        只新增/覆盖本工具自身的文件。详情见 SAFETY.md。
# ============================================================================
set -uo pipefail

AUTHOR="张昌宇 (Changyu Zhang)"
BIN="/usr/local/bin"
MOUNT_SH="$BIN/mount-ntfs-rw"
AUTO_SH="$BIN/ntfs-automount"
AGENT_LABEL="com.changyu.fluxmount"
AGENT_PLIST="$HOME/Library/LaunchAgents/$AGENT_LABEL.plist"
SUDOERS="/etc/sudoers.d/fluxmount"
BACKUP_DIR="$HOME/.fluxmount-backup"
MACFUSE_DMG="macfuse-5.3.3.dmg"
MACFUSE_URLS=(
  "https://kgithub.com/macfuse/macfuse/releases/download/macfuse-5.3.3/macfuse-5.3.3.dmg"
  "https://mirror.ghproxy.com/https://github.com/macfuse/macfuse/releases/download/macfuse-5.3.3/macfuse-5.3.3.dmg"
  "https://ghproxy.net/https://github.com/macfuse/macfuse/releases/download/macfuse-5.3.3/macfuse-5.3.3.dmg"
  "https://ghproxy.com/https://github.com/macfuse/macfuse/releases/download/macfuse-5.3.3/macfuse-5.3.3.dmg"
)

# 备份一个已存在的文件(仅当存在且备份目录已建)
backup_if_exists() {
  local f="$1"
  [ -e "$f" ] || return 0
  mkdir -p "$BACKUP_DIR"
  cp -a "$f" "$BACKUP_DIR/$(echo "$f" | tr '/' '_')" 2>/dev/null && \
    echo "  💾 已备份: $f -> $BACKUP_DIR" || echo "  ⚠️ 备份失败: $f"
}

banner() {
  echo "=========================================================="
  echo "   FluxMount  —  让 Mac 自由读写 NTFS 硬盘"
  echo "   作者: $AUTHOR"
  echo "=========================================================="
}

# ---------------------------------------------------------------- doctor
doctor() {
  echo "🩺 FluxMount · 健康检查"
  echo "----------------------------------------"
  local arch; arch=$(uname -m)
  echo "架构: $arch | macOS: $(sw_vers -productVersion 2>/dev/null)"
  echo "用户: $(whoami)"

  echo -n "macFUSE 系统扩展: "; [ -d /Library/Filesystems/macfuse.fs ] && echo "✅ 已装" || echo "❌ 未装"
  echo -n "ntfs-3g 程序:      "; command -v ntfs-3g >/dev/null 2>&1 && echo "✅ $(ntfs-3g --version 2>/dev/null | head -1)" || ([ -x /usr/local/bin/ntfs-3g ] && echo "✅ /usr/local/bin/ntfs-3g" || echo "❌ 未装")

  echo -n "脚本就位:          "; [ -x "$MOUNT_SH" ] && [ -x "$AUTO_SH" ] && echo "✅" || echo "❌ 缺失"
  echo -n "免密 sudo:         "; sudo -n "$MOUNT_SH" --check >/dev/null 2>&1 && echo "✅" || echo "⚠️ 未配置(自动挂载会需密码)"

  local agent; agent=$(launchctl list 2>/dev/null | grep -c "$AGENT_LABEL")
  echo -n "自动挂载代理:      "; [ "$agent" -gt 0 ] && echo "✅ 已注册" || echo "❌ 未注册"

  echo -n "当前 NTFS 挂载:    "; mount | grep -iq macfuse && echo "✅ 有可读写 NTFS 挂载" || (mount | grep -iq ' ntfs ' && echo "⚠️ 存在只读 NTFS(需重新挂载)" || echo "ℹ️ 当前未插 NTFS 盘")

  echo "----------------------------------------"
  echo "结论: 若上面有 ❌，运行  bash install.sh  一键修复。"
}

# ---------------------------------------------------------------- dry-run
dry_run() {
  echo "🔍 FluxMount · dry-run (预览，不做任何改动)"
  echo "----------------------------------------"
  echo "将执行以下动作:"
  echo "  1) 若不存在: 安装 macFUSE (国内镜像兜底 GitHub 被墙)"
  echo "  2) 若不存在: 安装 ntfs-3g (brew tap gromgit/homebrew-fuse + ntfs-3g-mac)"
  echo "  3) 部署脚本: $MOUNT_SH  $AUTO_SH"
  echo "  4) 配置免密 sudo: $SUDOERS (仅放行 mount-ntfs-rw)"
  echo "  5) 注册自动挂载: $AGENT_PLIST (开机+热插拔)"
  echo "  6) 立即以可读写挂载当前 NTFS 盘"
  echo ""
  echo "📁 安装前将自动备份被覆盖的文件到: $BACKUP_DIR"
  echo "🛡️  本工具不会删除/改动你 NTFS 盘里的任何数据 (详见 SAFETY.md)"
  echo "✅ 若想真正执行，去掉 --dry-run 再运行: bash install.sh"
}

# ---------------------------------------------------------------- install
if [ "${1:-}" = "--doctor" ]; then doctor; exit 0; fi
if [ "${1:-}" = "--status" ]; then exec "$(dirname "$0")/mount-ntfs-rw" --status; fi
if [ "${1:-}" = "--dry-run" ]; then dry_run; exit 0; fi
if [ "${1:-}" = "--uninstall" ]; then exec bash "$(dirname "$0")/uninstall.sh"; fi
[ "$(id -u)" -eq 0 ] && { echo "❌ 请勿用 sudo 运行本脚本（Homebrew 不允许 root）。直接 bash install.sh 即可。"; exit 1; }

# 预检：仅支持 macOS
if [ "$(uname)" != "Darwin" ]; then
  echo "❌ FluxMount 仅支持 macOS，当前系统为 $(uname)。"
  exit 1
fi

banner

# 1) 安装 macFUSE (若未装)
if [ ! -d /Library/Filesystems/macfuse.fs ] && ! pkgutil --pkgs 2>/dev/null | grep -qi macfuse; then
  echo ""
  echo "📦 [1/4] 安装 macFUSE (国内镜像兜底 GitHub 被墙)..."
  dmg=""
  for u in "${MACFUSE_URLS[@]}"; do
    echo "  ⬇️  尝试: $u"
    if curl -L --connect-timeout 20 --max-time 180 -o "/tmp/$MACFUSE_DMG" "$u" 2>/dev/null && [ -s "/tmp/$MACFUSE_DMG" ]; then
      dmg="/tmp/$MACFUSE_DMG"; echo "  ✅ 下载成功"; break
    fi
  done
  if [ -z "$dmg" ]; then
    echo "❌ 所有镜像都下载失败。请开代理/VPN 后手动下载 https://github.com/macfuse/macfuse/releases/download/macfuse-5.3.3/macfuse-5.3.3.dmg 并双击安装，然后重跑本脚本。"
    exit 1
  fi
  xattr -d com.apple.quarantine "$dmg" 2>/dev/null || true
  mnt=$(hdiutil attach "$dmg" -nobrowse -noautoopen 2>/dev/null | awk -F'\t' '/Volumes/{print $NF}')
  pkg=$(find "$mnt" -maxdepth 2 -name '*.pkg' 2>/dev/null | head -1)
  # 安全: 安装前校验代码签名，防止下载被篡改(对应 SAFETY.md 的"可信"承诺)
  if command -v pkgutil >/dev/null 2>&1 && pkgutil --check-signature "$pkg" >/dev/null 2>&1; then
    echo "  🔏 安装包签名校验通过 ✅"
  else
    echo "  ❌ 安装包签名校验失败，疑似被篡改或下载不完整，已中止安装以确保安全。"
    hdiutil detach "$mnt" >/dev/null 2>&1 || true
    exit 1
  fi
  echo "  🔐 即将安装 macFUSE 系统扩展，请输入管理员密码:"
  sudo installer -pkg "$pkg" -target / >/dev/null 2>&1 && echo "  ✅ macFUSE 安装完成" || echo "  ❌ macFUSE 安装失败"
  hdiutil detach "$mnt" >/dev/null 2>&1 || true
else
  echo "✅ [1/4] macFUSE 已安装，跳过。"
fi

# 2) 安装 ntfs-3g (若未装) —— 用 gromgit tap 的正确姿势，规避 Homebrew Tier-3 无包
if ! command -v ntfs-3g >/dev/null 2>&1 && [ ! -x /usr/local/bin/ntfs-3g ]; then
  echo ""
  echo "📦 [2/4] 安装 ntfs-3g..."
  if command -v brew >/dev/null 2>&1; then
    echo "  🍺 尝试 brew tap gromgit/homebrew-fuse + ntfs-3g-mac (国内推荐, 有预编译包)"
    HOMEBREW_NO_AUTO_UPDATE=1 brew tap gromgit/homebrew-fuse 2>&1 | tail -1
    if HOMEBREW_NO_AUTO_UPDATE=1 brew install ntfs-3g-mac 2>&1 | tail -3; then
      echo "  ✅ ntfs-3g 安装完成"
    else
      echo "  ⚠️  brew 路线失败(可能仍被墙/无包)，请运行 build 说明或手动安装。"
    fi
  else
    echo "  ⚠️  未检测到 Homebrew，请先安装 Homebrew 后重跑，或手动安装 ntfs-3g。"
  fi
  if ! command -v ntfs-3g >/dev/null 2>&1 && [ ! -x /usr/local/bin/ntfs-3g ]; then
    echo "  ❌ ntfs-3g 仍未就绪。请手动安装后重跑: brew install --cask macfuse && brew tap gromgit/homebrew-fuse && brew install ntfs-3g-mac"
    exit 1
  fi
else
  echo "✅ [2/4] ntfs-3g 已存在 ($(ntfs-3g --version 2>/dev/null | head -1 || echo /usr/local/bin/ntfs-3g))，跳过。"
fi

# 3) 部署脚本 + 免密 sudo + 自动挂载代理 (安装前先备份被覆盖的文件)
echo ""
echo "📦 [3/4] 部署脚本与自动挂载..."
backup_if_exists "$MOUNT_SH"
backup_if_exists "$AUTO_SH"
backup_if_exists "$SUDOERS"
backup_if_exists "$AGENT_PLIST"
sudo cp "$(dirname "$0")/mount-ntfs-rw" "$MOUNT_SH"
sudo cp "$(dirname "$0")/ntfs-automount" "$AUTO_SH"
sudo chmod +x "$MOUNT_SH" "$AUTO_SH"
echo "  ✅ 脚本已装到 $BIN"

# 免密 sudo (仅放行 mount-ntfs-rw)
echo "$USER ALL=(root) NOPASSWD: $MOUNT_SH" | sudo tee "$SUDOERS" >/dev/null
sudo chmod 440 "$SUDOERS"
echo "  ✅ 已配置免密 sudo (自动挂载不会弹密码框)"

# 清理旧版(若有)，避免重复触发
OLD_AGENT="$HOME/Library/LaunchAgents/com.user.ntfs-automount.plist"
if [ -f "$OLD_AGENT" ]; then
  launchctl bootout "gui/$(id -u)/com.user.ntfs-automount" 2>/dev/null || true
  rm -f "$OLD_AGENT"
fi
[ -f /etc/sudoers.d/ntfs-automount ] && sudo rm -f /etc/sudoers.d/ntfs-automount

# LaunchAgent plist
cat > "$AGENT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$AGENT_LABEL</string>
  <key>ProgramArguments</key>
  <array><string>$AUTO_SH</string></array>
  <key>RunAtLoad</key><true/>
  <key>StartOnMount</key><true/>
  <key>StandardErrorPath</key><string>/tmp/fluxmount.log</string>
  <key>StandardOutPath</key><string>/tmp/fluxmount.log</string>
</dict>
</plist>
PLIST
launchctl bootout "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$AGENT_PLIST" 2>/dev/null && echo "  ✅ 自动挂载代理已注册(开机+热插拔)" || echo "  ⚠️  代理注册需在图形会话终端执行，请在本机终端重跑一次本脚本"

# 4) 立即挂载
echo ""
echo "📦 [4/4] 立即以可读写挂载当前 NTFS 盘..."
sudo "$MOUNT_SH" || true

echo ""
echo "=========================================================="
echo "✅ 安装完成！接下来只差一步(每个 Mac 只需一次):"
echo "   1) 打开 系统设置 → 隐私与安全性"
echo "   2) 找到 \"来自开发者 Benjamin Fleischer 的系统软件已被阻止\"，点【允许】"
echo "   3) 重启电脑"
echo "   4) 重启后插上 NTFS 盘，等 5~8 秒即自动可读写，无需再敲命令。"
echo "----------------------------------------------------------"
echo "💡 随时自检:  bash install.sh --doctor"
echo "💡 预览改动:  bash install.sh --dry-run"
echo "💡 手动挂载:  sudo mount-ntfs-rw"
echo "💡 卸载还原:  bash uninstall.sh"
echo "💡 由 张昌宇 (Changyu Zhang) 出品 · FluxMount"
echo "=========================================================="
