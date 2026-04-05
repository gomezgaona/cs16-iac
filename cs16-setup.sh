#!/bin/bash

set -e  # Exit on error

echo "========================================="
echo "CS 1.6 Server Setup - Starting..."
echo "========================================="

# Update system
echo "Updating system packages..."
apt-get update
apt-get install -y lib32gcc-s1 lib32stdc++6 wget tar screen git

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Create user directory
mkdir -p /home/cs-server
cd /home/cs-server

# Download and install SteamCMD
echo "Installing SteamCMD..."
wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf steamcmd_linux.tar.gz
rm steamcmd_linux.tar.gz

# Install CS 1.6 Dedicated Server
echo "Installing CS 1.6 Dedicated Server (this takes 5-10 minutes)..."
./steamcmd.sh +force_install_dir /home/cs-server/hlserver +login anonymous +app_update 90 validate +quit

# Clone configuration repository
echo "Cloning configuration from GitHub..."
cd /tmp
git clone https://github.com/jgomezg/cs16-iac.git
cd cs16-iac

# Copy server.cfg if it exists
if [ -f "cs16-configs/server.cfg" ]; then
    echo "Copying server.cfg..."
    cp cs16-configs/server.cfg /home/cs-server/hlserver/cstrike/
fi

# Copy mapcycle.txt if it exists
if [ -f "cs16-configs/mapcycle.txt" ]; then
    echo "Copying mapcycle.txt..."
    cp cs16-configs/mapcycle.txt /home/cs-server/hlserver/cstrike/
fi

# Copy motd.txt if it exists
if [ -f "cs16-configs/motd.txt" ]; then
    echo "Copying motd.txt..."
    cp cs16-configs/motd.txt /home/cs-server/hlserver/cstrike/
fi

# Copy custom maps if they exist
if [ -d "cs16-configs/maps" ]; then
    echo "Copying custom maps..."
    cp cs16-configs/maps/*.bsp /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.txt /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.res /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.nav /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.bmp /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
fi

# Copy .wad files if they exist
if [ -d "cs16-configs" ]; then
    echo "Copying texture files (.wad)..."
    cp cs16-configs/*.wad /home/cs-server/hlserver/cstrike/ 2>/dev/null || true
fi

# Cleanup
rm -rf /tmp/cs16-iac

# Create management scripts
echo "Creating management scripts..."

cat > /usr/local/bin/cs16-start << 'STARTEOF'
#!/bin/bash
cd /home/cs-server/hlserver
screen -dmS cs16server ./hlds_run -game cstrike +map awp_minimilitia +maxplayers 16 +port 27015
echo "CS 1.6 Server started in background (screen session: cs16server)"
echo "Use 'cs16-status' to check if it's running"
echo "Use 'cs16-console' to view/interact with the server console"
STARTEOF

cat > /usr/local/bin/cs16-stop << 'STOPEOF'
#!/bin/bash
screen -S cs16server -X quit
echo "CS 1.6 Server stopped"
STOPEOF

cat > /usr/local/bin/cs16-restart << 'RESTARTEOF'
#!/bin/bash
echo "Stopping CS 1.6 Server..."
screen -S cs16server -X quit
sleep 2
echo "Starting CS 1.6 Server..."
cd /home/cs-server/hlserver
screen -dmS cs16server ./hlds_run -game cstrike +map awp_minimilitia +maxplayers 16 +port 27015
echo "CS 1.6 Server restarted"
RESTARTEOF

cat > /usr/local/bin/cs16-status << 'STATUSEOF'
#!/bin/bash
if screen -list | grep -q "cs16server"; then
    echo "✅ CS 1.6 Server is RUNNING"
    echo ""
    echo "Server details:"
    screen -S cs16server -X stuff "status$(printf \\r)"
    sleep 1
else
    echo "❌ CS 1.6 Server is NOT running"
    echo "Use 'cs16-start' to start the server"
fi
STATUSEOF

cat > /usr/local/bin/cs16-console << 'CONSOLEEOF'
#!/bin/bash
if screen -list | grep -q "cs16server"; then
    echo "Attaching to CS 1.6 console..."
    echo "Press Ctrl+A then D to detach (server keeps running)"
    sleep 2
    screen -r cs16server
else
    echo "❌ CS 1.6 Server is not running"
    echo "Use 'cs16-start' to start the server first"
fi
CONSOLEEOF

cat > /usr/local/bin/cs16-changemap << 'CHANGEMAPEOF'
#!/bin/bash
if ! screen -list | grep -q "cs16server"; then
    echo "❌ CS 1.6 Server is not running"
    echo "Use 'cs16-start' to start the server first"
    exit 1
fi
if [ -z "$1" ]; then
    echo "Usage: cs16-changemap <mapname>"
    echo ""
    echo "Examples:"
    echo "  cs16-changemap dust2"
    echo "  cs16-changemap italy"
    echo "  cs16-changemap minimilitia"
    echo ""
    echo "Available maps in mapcycle:"
    cat /home/cs-server/hlserver/cstrike/mapcycle.txt
    exit 1
fi
MAPNAME=$1
PREFIXES=("de_" "cs_" "awp_" "as_" "fy_")
FULLMAP=""
for PREFIX in "${PREFIXES[@]}"; do
    TESTMAP="${PREFIX}${MAPNAME}"
    if [ -f "/home/cs-server/hlserver/cstrike/maps/${TESTMAP}.bsp" ]; then
        FULLMAP=$TESTMAP
        break
    fi
done
if [ -z "$FULLMAP" ] && [ -f "/home/cs-server/hlserver/cstrike/maps/${MAPNAME}.bsp" ]; then
    FULLMAP=$MAPNAME
fi
if [ -z "$FULLMAP" ]; then
    echo "❌ Map not found: $MAPNAME"
    echo ""
    echo "Try one of these available maps:"
    ls /home/cs-server/hlserver/cstrike/maps/*.bsp 2>/dev/null | xargs -n 1 basename | sed 's/.bsp$//' | sed 's/^de_//;s/^cs_//;s/^awp_//;s/^as_//;s/^fy_//'
    exit 1
fi
echo "🗺️  Changing map to: $FULLMAP"
screen -S cs16server -p 0 -X stuff "changelevel $FULLMAP^M"
echo "✅ Map change command sent!"
echo "Use 'cs16-console' to see the map change in action"
CHANGEMAPEOF

cat > /usr/local/bin/cs16-backup << 'BACKUPEOF'
#!/bin/bash
echo "Creating backup..."
BACKUP_NAME="cs16-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
cd /home/cs-server
tar -czf "/tmp/${BACKUP_NAME}" hlserver/
echo "✅ Backup created: /tmp/${BACKUP_NAME}"
echo ""
echo "To upload to Azure Storage, run:"
echo "az storage blob upload --account-name STORAGE_ACCOUNT --container-name server-backups --name ${BACKUP_NAME} --file /tmp/${BACKUP_NAME}"
BACKUPEOF

cat > /usr/local/bin/cs16-restore << 'RESTOREEOF'
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
RESTOREEOF

cat > /usr/local/bin/cs16-update-configs << 'UPDATEEOF'
#!/bin/bash
echo "Updating configs from GitHub..."
cd /tmp
rm -rf cs16-iac
git clone https://github.com/jgomezg/cs16-iac.git
cd cs16-iac

# Stop server before updating
cs16-stop
sleep 2

# Copy updated configs
if [ -f "cs16-configs/server.cfg" ]; then
    cp cs16-configs/server.cfg /home/cs-server/hlserver/cstrike/
    echo "✅ Updated server.cfg"
fi

if [ -f "cs16-configs/mapcycle.txt" ]; then
    cp cs16-configs/mapcycle.txt /home/cs-server/hlserver/cstrike/
    echo "✅ Updated mapcycle.txt"
fi

if [ -f "cs16-configs/motd.txt" ]; then
    cp cs16-configs/motd.txt /home/cs-server/hlserver/cstrike/
    echo "✅ Updated motd.txt"
fi

# Copy maps
if [ -d "cs16-configs/maps" ]; then
    cp cs16-configs/maps/*.bsp /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.txt /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.res /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.nav /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.bmp /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    echo "✅ Updated maps"
fi

# Copy .wad files
if [ -d "cs16-configs" ]; then
    cp cs16-configs/*.wad /home/cs-server/hlserver/cstrike/ 2>/dev/null || true
    echo "✅ Updated texture files"
fi

rm -rf /tmp/cs16-iac
chown -R cs-server:cs-server /home/cs-server/hlserver

echo ""
echo "✅ Configuration update complete!"
echo "Start server with: cs16-start"
UPDATEEOF

# Make all scripts executable
chmod +x /usr/local/bin/cs16-start
chmod +x /usr/local/bin/cs16-stop
chmod +x /usr/local/bin/cs16-restart
chmod +x /usr/local/bin/cs16-status
chmod +x /usr/local/bin/cs16-console
chmod +x /usr/local/bin/cs16-changemap
chmod +x /usr/local/bin/cs16-backup
chmod +x /usr/local/bin/cs16-restore
chmod +x /usr/local/bin/cs16-update-configs

# Set ownership
chown -R cs-server:cs-server /home/cs-server

echo ""
echo "========================================="
echo "✅ CS 1.6 Server Setup Complete!"
echo "========================================="
echo ""
echo "Available commands:"
echo "  cs16-start           - Start the server"
echo "  cs16-stop            - Stop the server"
echo "  cs16-restart         - Restart the server"
echo "  cs16-status          - Check server status"
echo "  cs16-console         - Access server console"
echo "  cs16-changemap       - Change map"
echo "  cs16-backup          - Create backup"
echo "  cs16-restore         - Restore from backup"
echo "  cs16-update-configs  - Pull latest configs from GitHub"
echo ""
echo "To start the server: cs16-start"
echo ""