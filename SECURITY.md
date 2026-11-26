# Security Policy

Reeve-Go 定位为高敏感度的 AI 运维安全控制面，我们高度重视二进制分发完整性与漏洞响应。

## 验证下载产物完整性

每次官方发布的 [GitHub Release](https://github.com/SyncMeIn/ReeveGo/releases) 均附带 `sha256sums.txt`。部署前强烈建议核验校验和：

```bash
# Linux / macOS
sha256sum -c sha256sums.txt --ignore-missing
```

```powershell
# Windows (PowerShell)
Get-FileHash .\reeve-go-windows-amd64.exe -Algorithm SHA256
```

## 安全红线承诺

1. **零凭据入模型**：服务器真实 IP、端口、用户名、密码与私钥永不通过 MCP 暴露给 AI 客户端。
2. **本地主密码不出本机**：主密码与派生密钥仅驻留受保护内存，锁定即清零，绝不写入配置文件或日志。
3. **无密码代输 sudo**：Reeve-Go 永不替 AI 命令自动注入 sudo 密码；仅支持管理员显式批准的一次性审批或经 `visudo -cf` 校验的最小化 `/etc/sudoers.d/` 规则。
4. **防篡改审计**：所有放行、拦截、审批与管理操作均以 HMAC-SHA256 链式落盘并支持离线验链。

## 报告安全漏洞

如发现任何安全漏洞（绕过策略拦截、权限越权、凭据泄露、XSS/CSRF/SSRF 等），**请勿在公开 Issue 中直接披露利用细节**，请通过 GitHub **Security Advisories（Private vulnerability reporting）** 提交报告，并尽量附带：

- 受影响版本（执行 `reeve-go --version` 获取）与运行模式（`ui` / `server`）
- 复现步骤或最小 PoC
- 潜在影响评估

我们将在收到报告后尽快确认并发布修复版本。
