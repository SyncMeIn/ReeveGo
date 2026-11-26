# 常见问题与排障（FAQ）

### Q1：反代部署堡垒机后，AI 客户端调 `/mcp` 返回 `403 Forbidden`？
请检查以下两点：
1. **域名必须完全一致**：客户端配置的 URL、Nginx `proxy_set_header Host $host;` 与启动参数 `--external-url https://...` 三者域名必须一字不差（外层 `validHost` 严格校验防 DNS 重绑定）。
2. **Token CIDR 白名单**：若签发 Token 时填写了 `CIDR 来源 IP 白名单`，请确保客户端出口 IP 在范围内，且 Nginx 透传了 `X-Forwarded-For`、`--trusted-proxies` 包含反代 IP（如 `127.0.0.1/32`）。

### Q2：为什么 `list_servers` 返回 `{"armed": false, "servers": []}`？
堡垒机采用 Fail-Closed 资产组隔离，请依次确认：
1. 服务器已在「服务器」编辑页或「资产组与布防」中**绑定到至少一个资产组**（未分组主机默认不可见）；
2. 非管理员账号已在「用户与 ACL」中配置了该资产组的 ACL；
3. 该 Token 的「授权资产组」勾选了对应资产组；
4. 若 `armed` 为 `false`，请在「资产组与布防」点击 **「放行」**（`prod` 生产组默认撤防）。

### Q3：AI 执行只读 Shell 命令为什么被直接拒绝而不是弹审批？
检查审计详情是否提示 `disarmed`（资产组未放行）。`ssh_exec` 在策略上属于改动型工具，撤防状态下所有改动型工具都会直接拒绝而不弹审批；请先开启对应资产组放行，或让 AI 优先调用 `system_info` / `disk_usage` / `tail_log` / `sftp_read` 等专用只读工具。

### Q4：审批等待超过 1 分钟时 MCP 连接断开（504 Gateway Timeout）？
Reeve-Go 支持最长 5 分钟人工阻塞审批。若前置 Nginx，请确保 `/mcp` location 配置了：
```nginx
proxy_buffering off;
proxy_read_timeout 360s;
proxy_send_timeout 360s;
```

### Q5：忘记管理员密码如何重置？
在服务器本机执行 CLI 重置命令（需指定正确的 `--data-dir`）：
```bash
/opt/reeve-go/reeve-go user --data-dir /opt/reeve-go/data reset-password admin
```

### Q6：如何确认当前运行的版本号？
- 命令行执行 `reeve-go --version`；
- 或直接查看桌面端 / 堡垒机控制台左下角的版本号标识。
