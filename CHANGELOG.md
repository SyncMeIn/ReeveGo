# Changelog

所有面向用户的版本变更均记录于此。完整二进制与校验和见 [Releases](https://github.com/SyncMeIn/ReeveGo/releases)。

## Unreleased / Latest

### 新特性
- **双模式单二进制**：支持本机桌面模式（`reeve-go ui`）与局域网多用户堡垒机模式（`reeve-go server`）。
- **受控文件工具**：新增 `sftp_read`（256KB 只读脱敏）与 `sftp_write`（128KB 受控审批写入 + SHA-256 审计）。
- **一次性临时 sudo 审批与托管免密 sudo**：支持未开启常驻 sudo 时的 `DANGEROUS` 临时提权审批，以及经 `visudo -cf` 校验的最小化 `/etc/sudoers.d/` 托管。
- **全加密备份与进程内热切换恢复**：支持 `.rgbackup`（SQLite `VACUUM INTO` + Argon2id + AES-256-GCM）导出，并在 Web 端直接完成进程内原子热切换，无需重启服务进程。
- **审计日志交互升级**：新增 6 张可点击统计卡片、多维过滤搜索、行展开详情、折叠重复、防公式注入 CSV 导出及 `reeve-go audit archive` 安全归档裁剪。
- **外部 IM 审批提醒**：支持企业微信（含 UserID 与手机号定向 `@`）、飞书、钉钉、通用 Webhook，支持通道编辑与最低风险级别过滤。
- **SSH 短连接复用池**：按主机 60 秒空闲复用底层 SSH 连接，锁定金库或修改主机时立即驱逐关闭。

### 安全加固
- TOTP 验证码增加 RFC 6238 防重放时间片校验。
- 出口脱敏补齐 `rg_tok_`、阿里云 AK、腾讯云 AK 与 IM Webhook 密钥。
- 外部通知 Webhook 禁用重定向并拦截云元数据/回环 SSRF。
- 审批通知支持按通道排队限速，避免并发审批漏报。
- Windows 原生审批弹窗支持 `Esc` 拒绝、`Ctrl+Enter`（仅 `NORMAL`/`DANGEROUS`）快捷批准，并保留 `CRITICAL` 强制二次确认。
