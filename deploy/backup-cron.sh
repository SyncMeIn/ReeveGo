#!/usr/bin/env bash
set -euo pipefail

# 每日在线加密备份脚本（配合 cron 使用）
# 备份口令请通过权限 0600 的独立文件提供，切勿硬编码在脚本中
DATA_DIR="${DATA_DIR:-/opt/reeve-go/data}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/reevego}"
PASS_FILE="${PASS_FILE:-/etc/reeve-go/backup.pass}"
BIN="${BIN:-/opt/reeve-go/reeve-go}"
KEEP_DAYS="${KEEP_DAYS:-30}"

mkdir -p "${BACKUP_DIR}"
chmod 700 "${BACKUP_DIR}"

OUT="${BACKUP_DIR}/reevego-$(date +%Y%m%d-%H%M%S).rgbackup"
"${BIN}" backup --data-dir "${DATA_DIR}" --out "${OUT}" --stdin < "${PASS_FILE}"
chmod 600 "${OUT}"

find "${BACKUP_DIR}" -name 'reevego-*.rgbackup' -mtime +"${KEEP_DAYS}" -delete
echo "Backup completed: ${OUT}"
