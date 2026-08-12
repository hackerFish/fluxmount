#!/usr/bin/env bash
# FluxMount → ClawHub 发布脚本
# 前置：先在本地执行一次 `clawhub login`（使用你的 GitHub 账号，需注册满 14 天才能过上传门槛）。
# 之后直接运行：  ./deploy/clawhub.sh
# 仅做校验不上传可用：  clawhub skill publish . --dry-run
set -euo pipefail
cd "$(dirname "$0")/.."

clawhub skill publish . \
  --slug fluxmount \
  --name "FluxMount" \
  --version 1.0.0 \
  --changelog "首版发布：macOS NTFS 读写、插上即用、开机与热插拔自动挂载、安全可回退、国内网络加固" \
  --tags "ntfs,macos,macfuse,ntfs-3g,filesystem,skill,agent-skills,external-drive,read-write"
