#!/usr/bin/env bash
# FluxMount → Qoder Cloud 上传脚本（自定义 Skill，以 .zip 上传）
# 用法：  QODER_PAT=你的令牌 ./deploy/qoder.sh
#
# 注意：Qoder Cloud 为纯云端运行环境，没有你的物理外接硬盘，
#       因此挂载动作无法在云端真正执行；本上传仅用于跨平台技能收录与展示。
#       在 Qoder 桌面端 / 本地形态下才可真正挂载。
set -euo pipefail
: "${QODER_PAT:?请设置环境变量 QODER_PAT（Qoder 个人访问令牌，见 Qoder 设置页）}"

cd "$(dirname "$0")/.."

# 重新打包（SKILL.md 位于 fluxmount/ 一级子目录，符合 Qoder 要求）
rm -rf _pkg fluxmount-qoder.zip
mkdir -p _pkg/fluxmount
cp SKILL.md README.md SAFETY.md LICENSE manifest.yaml _pkg/fluxmount/
cp -R scripts references _pkg/fluxmount/
( cd _pkg && zip -r -q ../fluxmount-qoder.zip fluxmount )
rm -rf _pkg

echo ">>> 已生成 fluxmount-qoder.zip，开始上传 Qoder Cloud ..."
curl -X POST "https://api.qoder.com/api/v1/cloud/skills" \
  -H "Authorization: Bearer $QODER_PAT" \
  -F "name=fluxmount" \
  -F "type=custom" \
  -F "description=FluxMount - macOS NTFS read-write skill by Changyu Zhang" \
  -F "file=@fluxmount-qoder.zip"

echo ""
echo ">>> 上传完成。可在 Qoder 的 Skills 列表查看；如需绑定到 Agent，用返回的 skill_xxx id 调用 PUT /cloud/agents/{agent_id}。"
