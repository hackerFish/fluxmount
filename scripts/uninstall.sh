#!/bin/bash
# ============================================================================
#  FluxMount  ·  uninstall.sh  (干净卸载 / 回滚)
#  作者: 张昌宇 (Changyu Zhang)
#  功能: 移除自动挂载代理、免密 sudo 规则、部署的脚本，并尽量还原安装前的备份。
#        不会动 macFUSE/ntfs-3g 本体(若想彻底移除这两个驱动，请另行处理)。
#  安全: 卸载前先尝试从 ~/.fluxmount-backup 还原被我们覆盖过的原文件；
#        只删除本工具自身创建的文件，绝不触碰用户数据。
# ============================================================================
set -uo pipefail

AGENT_LABEL="com.changyu.fluxmount"
AGENT_PLIST="$HOME/Library/LaunchAgents/$AGENT_LABEL.plist"
SUDOERS="/etc/sudoers.d/fluxmount"
BIN="/usr/local/bin"
BACKUP_DIR="$HOME/.fluxmount-backup"
STATE_FILE="/usr/local/var/fluxmount/state"

echo "🧹 FluxMount · 卸载中..."

# 只卸载【我们自己的】可读写挂载: 严格依据安装时登记的状态文件，
# 绝不触碰其他 macFUSE 工具(如别的 NTFS 软件)挂载的盘，避免误伤。
if [ -f "$STATE_FILE" ]; then
  while IFS= read -r mp; do
    [ -z "$mp" ] && continue
    if mount | grep -qF "$mp"; then
      echo "  💿 安全弹出: $mp"
      diskutil unmount "$mp" >/dev/null 2>&1 || sudo umount "$mp" >/dev/null 2>&1
    fi
  done < "$STATE_FILE"
  sudo rm -f "$STATE_FILE" 2>/dev/null || true
  sudo rmdir /usr/local/var/fluxmount 2>/dev/null || true
else
  echo "  ℹ️  未找到挂载状态记录，跳过卸载挂载点(若仍有挂载，可手动 diskutil unmount)。"
fi

# 停掉并移除 LaunchAgent
launchctl bootout "gui/$(id -u)/$AGENT_LABEL" 2>/dev/null || true
rm -f "$AGENT_PLIST"

# 移除免密 sudo 规则
sudo rm -f "$SUDOERS"

# 还原安装前备份(若有)，否则删除我们创建的脚本
restore_or_remove() {
  local f="$1"
  local bak="$BACKUP_DIR/$(echo "$f" | tr '/' '_')"
  if [ -e "$bak" ]; then
    sudo cp -a "$bak" "$f" 2>/dev/null && echo "  ♻️  已还原安装前文件: $f" || echo "  ⚠️  还原失败: $f"
  else
    sudo rm -f "$f" 2>/dev/null && echo "  🗑️  已移除: $f" || echo "  ⚠️  移除失败(可能需手动): $f"
  fi
}
restore_or_remove "$BIN/mount-ntfs-rw"
restore_or_remove "$BIN/ntfs-automount"

echo "✅ FluxMount 已卸载/回退。"
echo "   (macFUSE / ntfs-3g 本体未动；如需卸载它们请另行处理。)"
echo "   由 张昌宇 (Changyu Zhang) 出品 · FluxMount"
