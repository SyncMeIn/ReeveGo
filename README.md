# Reeve-Go

**让 AI 安全运维你的服务器，而不交出任何凭据与底线。**

Reeve-Go 是一个面向 AI Coding Agent（Claude Code、Cursor、Codex、Devin 等）的 **零依赖、单二进制 AI 安全运维控制面与局域网堡垒机**。它位于 AI 客户端与真实 SSH 服务器之间，确保大模型**永远看不到服务器 IP、密码或私钥**，所有高危操作必须经过人类审批，所有输出自动脱敏，所有操作写入不可篡改的加密审计链。

> 本仓库为 **Reeve-Go 官方公开分发与帮助中心**，提供跨平台预编译二进制（[Releases](https://github.com/SyncMeIn/ReeveGo/releases)）、一键安装脚本、部署模板与完整使用文档。

---

## 为什么选择 Reeve-Go？

| 风险维度 | 直接给 AI 配 SSH / 无护栏 MCP | 使用 Reeve-Go 安全控制面 |
| :--- | :--- | :--- |
| **服务器凭据安全** | 密码/私钥暴露在上下文或配置中 | AES-256-GCM 加密金库，**零明文进大模型**，主机 IP 与用户名均隔离 |
| **高危命令误操作** | `rm -rf /`、改 `sudoers` 可能直接执行 | 内置 **91 条三级黑名单** 硬拦截 + 五档 AI 策略 + 资产组布防闸门 |
| **人工确认体验** | 终端刷屏难以看清命令风险 | 原生语法高亮风险弹窗（`Esc` 拒绝 / `Ctrl+Enter` 批准）或企微/飞书/钉钉卡片提醒 |
| **root / sudo 提权** | 易失控或被迫明文传密码 | 一次性 `DANGEROUS` 临时 sudo 审批 + 托管最小化 `/etc/sudoers.d/`（`visudo` 校验） |
| **敏感信息泄露** | 日志/配置文件里的密钥直接回传模型 | 出口自动脱敏（PEM 私钥、云 AK、JWT、DSN 密码、Token、Webhook 密钥） |
| **事后审计追责** | 普通文本日志可随意篡改 | **HMAC-SHA256 链式防篡改审计** + 统计过滤 + 离线完整性校验 + 加密归档 |
| **团队协作** | 仅限个人本机 | 单二进制同时支持 **本机桌面模式** 与 **局域网多用户堡垒机**（RBAC / SoD 双人复核 / TOTP） |

---

## 两种运行模式，一个二进制

### 1. 本机桌面模式（个人开发者）
双击或命令行运行 `reeve-go ui`，常驻系统托盘，打开本机 Web 工作台（蓝色图标）与原生置顶审批弹窗。AI 客户端通过零主密码薄桥 `reeve-go mcp` 接入。

👉 查看 [桌面端快速上手指南](docs/quickstart-desktop.md)

### 2. 局域网多用户堡垒机模式（运维 / 研发团队）
在 Linux 服务器运行 `reeve-go server`，提供 HTTPS 多角色控制台（绿色图标）、标准 Streamable HTTP `/mcp` 端点、资产组隔离、SoD 双人复核、企微/飞书/钉钉分级提醒与进程内热切换加密备份。

👉 查看 [局域网堡垒机部署指南](docs/deploy-bastion.md)

---

## 快速安装

### Linux / macOS
```bash
curl -fsSL https://raw.githubusercontent.com/SyncMeIn/ReeveGo/main/scripts/install.sh | sh
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/SyncMeIn/ReeveGo/main/scripts/install.ps1 | iex
```

或前往 [GitHub Releases](https://github.com/SyncMeIn/ReeveGo/releases/latest) 手动下载对应平台二进制，并使用 `sha256sums.txt` 校验完整性：

```bash
sha256sum -c sha256sums.txt --ignore-missing
```

---

## 内置 MCP 工具一览

| 工具名 | 分类 | 能力与安全护栏 |
| :--- | :--- | :--- |
| `list_servers` | 元工具 | 仅返回已授权服务器的别名、生效策略与标签（**绝不返回 IP/用户名/凭据**） |
| `system_info` | 只读 | 采集目标机 OS、内核、CPU、内存与运行时长 |
| `disk_usage` | 只读 | 查看磁盘挂载与空间占用（`df -h`） |
| `tail_log` | 只读 | 读取日志尾部（最多 500 行，敏感路径拦截 + 自动脱敏） |
| `sftp_read` | 只读 | 受控读取文本/配置文件（上限 256KB，敏感路径拦截 + 自动脱敏） |
| `sftp_write` | 改动型 | 受控写入文件（上限 128KB，走审批策略 + SHA-256 审计） |
| `ssh_exec` | 改动型 | 受控执行 Shell 命令（91 条黑名单 + 五档策略 + 审批 + 脱敏 + 审计链） |

---

## 文档导航

- [桌面端快速上手与 AI 客户端接入](docs/quickstart-desktop.md)
- [局域网多用户堡垒机部署指南](docs/deploy-bastion.md)
- [临时 sudo 审批与托管免密 sudo 指南](docs/sudo-guide.md)
- [全加密备份与进程内热切换恢复](docs/backup-restore.md)
- [安全架构白皮书](docs/security-whitepaper.md)
- [常见问题与排障（FAQ）](docs/faq.md)
- [安全漏洞披露与校验说明](SECURITY.md)

---

## 致敬

本项目在设计过程中参考了 [reeve 工具](https://reeve.ruoyi.plus/) 的相关原理与思路，并从中获得灵感。在此向 reeve 致敬。

---

## 问题反馈

使用中遇到任何问题或功能建议，欢迎在本仓库提交 [Issue](https://github.com/SyncMeIn/ReeveGo/issues)。安全漏洞请优先按 [SECURITY.md](SECURITY.md) 指引私密报告。
