#!/bin/bash
echo "Creating backup..."
BACKUP_NAME="cs16-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
cd /home/cs-server
tar -czf "/tmp/${BACKUP_NAME}" hlserver/
echo "✅ Backup created: /tmp/${BACKUP_NAME}"
echo ""
echo "To upload to Azure Storage, run:"
echo "az storage blob upload --account-name STORAGE_ACCOUNT --container-name server-backups --name ${BACKUP_NAME} --file /tmp/${BACKUP_NAME}"
