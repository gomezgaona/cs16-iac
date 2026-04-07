#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: cs16-restore <backup-filename>"
    echo ""
    echo "Available backups:"
    az storage blob list --account-name cs16backups --container-name server-backups --output table 2>/dev/null || echo "No Azure storage configured"
    exit 1
fi
BACKUP_FILE=$1
echo "Stopping CS 1.6 server..."
cs16-stop
sleep 2
echo "Backing up current server files..."
if [ -d "/home/cs-server/hlserver" ]; then
    mv /home/cs-server/hlserver /home/cs-server/hlserver-backup-$(date +%Y%m%d-%H%M%S)
fi
echo "Downloading backup from Azure Storage..."
az storage blob download --account-name cs16backups --container-name server-backups --name "$BACKUP_FILE" --file /tmp/cs16-restore.tar.gz
echo "Extracting backup..."
cd /home/cs-server
tar -xzf /tmp/cs16-restore.tar.gz
rm /tmp/cs16-restore.tar.gz
echo "✅ Restore complete!"
echo "Start server with: cs16-start"
