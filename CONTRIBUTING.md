# 贡献指南 (Contributing)

感谢你关注 **FluxMount**！这是一个面向 macOS 用户的 NTFS 读写技能，目标是"傻瓜式、一次到位、插上即用、不再复发"。

## 开发约定

- **语言**：所有脚本为 POSIX / Bash，目标在 macOS 12+ 运行。
- **风格**：函数式拆解、清晰注释、错误信息用中文（面向最终用户）。
- **安全**：任何会改动系统的操作前，必须支持 `--dry-run` 预览；卸载必须可还原。
- **幂等**：脚本重复执行不应造成副作用（已可读写则跳过）。

## 本地测试

```bash
# 语法检查（CI 也会跑）
for f in scripts/*.sh; do bash -n "$f"; done

# 静态检查（可选，需 brew install shellcheck）
shellcheck scripts/*.sh

# 只读预览（不改任何系统）
bash scripts/install.sh --dry-run

# 健康检查
bash scripts/install.sh --doctor
```

## 提交 Issue / PR

- **Bug**：请附上 `bash scripts/install.sh --doctor` 的输出、macOS 版本、芯片类型（Intel / Apple Silicon）。
- **新功能**：先开 Issue 讨论，避免重复劳动。
- **PR**：请保持小而专注，并确认本地测试通过。

## 许可证

本项目以 MIT 协议发布，版权归 **张昌宇 (Changyu Zhang)** 所有。
