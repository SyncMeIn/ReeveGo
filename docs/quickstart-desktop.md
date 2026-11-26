# 桌面端快速上手（个人模式）

本指南适用于个人开发者在 Windows / macOS 本机运行 Reeve-Go，并将 Claude Code、Cursor、Codex 等 AI 客户端接入受控 SSH 运维。

---

## 1. 下载与启动

从 [Releases](https://github.com/SyncMeIn/ReeveGo/releases/latest) 下载对应平台的可执行文件（或使用首页一键安装脚本）。

```powershell
# Windows 启动桌面工作台与系统托盘
.\reeve-go-windows-amd64.exe ui
```

启动后：
- 右下角出现系统托盘图标，自动打开本机管理台（仅监听 `127.0.0.1` 随机端口，蓝色盾牌图标）。
- 首次打开请在右上角点击 **「初始化金库」** 设置主密码（至少 10 位）。

---

## 2. 添加 SSH 服务器与配置策略

1. 在 **「服务器管理」** 点击 **「+ 添加服务器」**，填写别名、地址、端口、用户名及密码/私钥 PEM。
2. 点击 **「测试连接」** 完成首次主机指纹锁定（TOFU）。
3. 点击 **「策略」** 选择 AI 策略档位：
   - `disabled`：禁止 AI 一切操作
   - `readonly`：仅允许只读工具（`system_info` / `disk_usage` / `tail_log` / `sftp_read`）
   - `approval`（默认推荐）：所有操作均需人工审批
   - `allowlist`：命中自定义正则表达式自动放行，其余审批
   - `trusted`：常规写操作放行，但危险命令与 sudo 仍强制拦截/审批
4. 点击顶部 **「放行」** 胶囊开启布防窗口（未放行时所有改动型操作直接拒绝）。

---

## 3. 接入 AI 客户端（零主密码薄桥）

在桌面工作台左侧进入 **「MCP 接入」**，一键复制生成的 JSON 粘贴到你的 AI 客户端配置中：

```json
{
  "mcpServers": {
    "reeve-go": {
      "command": "D:\\path\\to\\reeve-go-windows-amd64.exe",
      "args": ["mcp"]
    }
  }
}
```

> **安全说明**：客户端配置中不包含任何主密码或服务器凭据。AI 调用工具时，`reeve-go mcp` 仅通过本机 `rpc.json` 转发给运行中的桌面工作台。

---

## 4. 原生审批弹窗快捷键

当 AI 触发需要审批的命令时，Windows 将弹出置顶语法高亮审批窗口（按风险分级呈现蓝 / 橙 / 红边框与 5 分钟倒计时）：

- **`Esc`**：立即拒绝（默认焦点在拒绝按钮，防止误触放行）
- **`Ctrl + Enter`**：快捷批准（仅对 `NORMAL` / `DANGEROUS` 档生效）
- **`CRITICAL`（极高危）**：禁用快捷批准，必须手敲服务器别名 + 输入金库主密码后点击「验证并批准」
- 审批时可在「补充说明 / 拒绝理由」输入框填写指令（自动脱敏后回传给 AI，方便指导 AI 修正命令）。
