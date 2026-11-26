# 局域网多用户堡垒机部署指南

本指南说明如何在 Linux 服务器上以 `server` 模式部署 Reeve-Go，供团队多名研发/运维通过 HTTPS 控制台与远程 Streamable HTTP MCP 协同使用。

---

## 1. 准备二进制与数据目录

```bash
sudo mkdir -p /opt/reeve-go/data
sudo cp reeve-go-linux-amd64 /opt/reeve-go/reeve-go
sudo chmod 755 /opt/reeve-go/reeve-go
```

## 2. 初始化首个管理员账号

```bash
/opt/reeve-go/reeve-go server init \
  --data-dir /opt/reeve-go/data \
  --username admin
```

按提示输入管理员登录密码（至少 8 位）。

---

## 3. 启动堡垒机服务

### 方式 A：前置 Nginx / Caddy 终止 HTTPS（生产推荐）

```bash
/opt/reeve-go/reeve-go server \
  --listen 127.0.0.1:18443 \
  --external-url https://bastion.example.com \
  --behind-proxy \
  --trusted-proxies 127.0.0.1/32 \
  --data-dir /opt/reeve-go/data
```

配套的 `systemd` 服务与反代模板请直接参考仓库中的 [deploy/](../deploy/) 目录：
- [deploy/reeve-go.service](../deploy/reeve-go.service)
- [deploy/nginx.conf](../deploy/nginx.conf)（关键：`/mcp` 需配置 `proxy_read_timeout 360s;` 与 `proxy_buffering off;`）
- [deploy/Caddyfile](../deploy/Caddyfile)

### 方式 B：局域网无反代自签 HTTPS 快速启动

```bash
/opt/reeve-go/reeve-go server \
  --listen 0.0.0.0:8443 \
  --external-url https://10.0.1.10:8443 \
  --self-signed \
  --data-dir /opt/reeve-go/data
```

首次启动会在数据目录自动生成 CA 与服务端证书，控制台提供 CA 证书下载。

---

## 4. 控制台初始化配置流程

1. 浏览器访问 `https://bastion.example.com`（绿色盾牌图标），使用管理员账号登录。
2. 点击右上角 **「初始化金库」** 设置金库主密码并解锁。
3. **资产组与布防**：创建资产组（`dev`/`staging` 默认放行，`prod` 默认撤防，可开启 **SoD 双人复核** 并绑定专属通知通道）。
4. **服务器**：新增 SSH 服务器（可直接勾选绑定到资产组），点击 **「测试并锁定指纹」** 钉选主机公钥。
5. **用户与 ACL**：创建团队成员（`operator` / `approver` / `admin` / `auditor`），按资产组配置策略上限、sudo 权限与审批权。
6. **通知通道**：配置企业微信 / 飞书 / 钉钉 / Webhook 审批提醒，支持按「最低级别」过滤与企微定向 `@` 审批人（支持 UserID 或手机号）。
7. **个人安全**：推荐所有审批人与管理员绑定 **TOTP 二次验证**（支持扫码绑定）。

---

## 5. AI 客户端接入远程堡垒机

在控制台 **「MCP Token」** 签发个人 Token 后，弹窗会直接生成可一键复制的 MCP 配置：

### 方式 1：直连标准 Streamable HTTP（推荐）
```json
{
  "mcpServers": {
    "reeve-http": {
      "url": "https://bastion.example.com/mcp",
      "transport": "http",
      "headers": {
        "Authorization": "Bearer rg_tok_xxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### 方式 2：本机 stdio 薄桥（兼容仅支持 stdio 的客户端）
```json
{
  "mcpServers": {
    "reeve-bastion": {
      "command": "/path/to/reeve-go",
      "args": ["mcp"],
      "env": {
        "REEVEGO_SERVER": "https://bastion.example.com",
        "REEVEGO_TOKEN": "rg_tok_xxxxxxxxxxxxxxxx"
      }
    }
  }
}
```
