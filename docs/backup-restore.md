# 全加密备份与进程内热切换恢复

Reeve-Go 的所有核心数据（加密凭据、资产组、ACL、用户、审计链）均存储在单一 SQLite 数据库 `reevego.db` 中，支持在线零停机全加密备份与进程内热切换恢复。

---

## 1. 加密备份格式（`.rgbackup`）

- **一致性快照**：使用 SQLite `VACUUM INTO` 在线生成事务一致快照，不锁业务读写。
- **双层加密**：除金库凭据本身的 AES-256-GCM 加密外，整个数据库文件再使用用户指定的**独立备份口令**（至少 8 位），经 **Argon2id + AES-256-GCM** 整体加密封装为 `.rgbackup`。
- **零明文元数据**：备份文件中不包含任何明文主机 IP、用户名、命令或审计文本。

---

## 2. 导出备份

### Web 控制台导出（桌面端 & 堡垒机端通用）
进入左侧 **「备份与恢复」** → 输入管理员/金库主密码二次确认 → 设置独立备份口令 → 点击下载 `reevego-YYYYMMDD-HHMMSS.rgbackup`。

### CLI 定时备份（适合配合 cron）
```bash
printf '%s\n' "$BACKUP_PASSPHRASE" | \
  /opt/reeve-go/reeve-go backup \
    --data-dir /opt/reeve-go/data \
    --out /var/backups/reevego/reevego-$(date +%F).rgbackup \
    --stdin
```
完整定时脚本模板见 [deploy/backup-cron.sh](../deploy/backup-cron.sh)。

---

## 3. 进程内热切换恢复（无需重启服务）

在 Web 控制台 **「备份与恢复」** 上传 `.rgbackup` 并输入当前密码 + 备份口令后，服务端将自动执行：
1. 在离线临时文件解密并执行 SQLite 完整性校验（`PRAGMA quick_check`）；
2. 立即锁定金库（清零内存 DEK）、取消在途待审批请求并清空临时免审授权；
3. 关闭旧 SQLite 连接释放文件锁 → 自动将旧库备份为 `reevego.db.bak-YYYYMMDD-HHMMSS` → 原子切换为新库并重新打开（任意步骤失败自动回滚到原库）；
4. 堡垒机模式自动清除旧会话 Cookie 并跳转登录页；桌面模式自动切换回锁定态，直接用新库主密码解锁即可。

### 离线 CLI 恢复
```bash
/opt/reeve-go/reeve-go restore backup.rgbackup --data-dir /opt/reeve-go/data-new
```
