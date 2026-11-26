# Reeve-Go 安全架构白皮书

## 1. 零凭据暴露架构

```text
AI Client (Claude / Cursor / Codex / Devin)
   │  仅见：服务器别名、策略档位、脱敏输出
   │  MCP (stdio 薄桥 或 Streamable HTTP + Bearer Token)
   ▼
Reeve-Go 控制面（策略引擎 → 审批队列 → 出口脱敏 → HMAC 审计链）
   │  仅在受保护内存内解封 AES-256-GCM 凭据，锁定即清零
   │  SSH (强制 HostKey 指纹校验 + 60s 短连接复用池)
   ▼
目标 Linux / Windows SSH 服务器
```

---

## 2. 七层纵深防线

1. **凭据加密与隔离**：
   - 服务器密码/私钥采用 **Argon2id + AES-256-GCM** 加密落盘，由金库主密码派生 DEK；
   - 堡垒机 TOTP 密钥与通知通道配置由独立的 `server_secret.key` 加密，与金库 DEK 解耦；
   - `list_servers` 与所有 MCP 错误消息永不泄露服务器真实 IP、端口、用户名或凭据。
2. **多分组最严 RBAC（Fail-Closed）**：
   - 未绑定到任何资产组的主机默认隐藏且拒绝执行；
   - 一台主机属于多个资产组时遵循最严交集：任意一组撤防则拒绝、任意一组开启 SoD 则强制双人复核、策略与 sudo 权限取用户 ACL 与主机配置的最小交集。
3. **91 条三级黑名单 + 五档策略**：
   - 硬拦截反弹 Shell、Fork Bomb、`rm -rf /`、写 `/etc/sudoers*`、读 `/etc/shadow` 与私钥文件等；
   - 支持 `disabled` / `readonly` / `approval` / `allowlist` / `trusted` 五档策略及资产组布防总开关。
4. **分级审批与职责分离（SoD）**：
   - `NORMAL` / `DANGEROUS` / `CRITICAL` 三级风险划分；
   - `CRITICAL` 极高危强制二次确认（手敲目标别名 + 个人密码/TOTP），物理禁止 IM 回调一键放行与快捷键放行；
   - 限时免审批仅允许 `NORMAL` 档，并按 `(user_id, server, tool)` 严格隔离；
   - 单用户并发待审批配额限制，防止 AI 审批轰炸。
5. **身份认证与抗重放**：
   - 登录密码采用 Argon2id 哈希，Session Cookie 强制 `HttpOnly` + `Secure` + `SameSite=Strict`，写接口强制 `Origin` + `X-CSRF-Token` 双重校验；
   - TOTP 遵循 RFC 6238 §5.2 记录已消费时间片，防止 90 秒窗口内重放；
   - IM 交互回调强制 HMAC-SHA256 签名 + `±60s` 时间窗 + Nonce 防重放；
   - 外部 Webhook 禁用 302 重定向并阻断回环与云元数据（`169.254.169.254`）盲 SSRF。
6. **出口自动脱敏**：
   - 所有命令输出、日志读取、审批备注在返回给 AI 与写入审计前，均自动脱敏 PEM 私钥、AWS/阿里云/腾讯云 AK、GitHub/OpenAI/Slack Token、Reeve-Go `rg_tok_`、JWT、数据库 DSN 密码、IM Webhook 密钥等。
7. **防篡改加密审计链**：
   - SQLite 触发器物理禁止 `UPDATE` 与绕过锚点的 `DELETE`；
   - 每行日志通过 HMAC-SHA256 与前一行链接，支持控制台在线校验、离线验链（`reeve-go audit verify`）与签名锚点归档裁剪（`reeve-go audit archive`）。
