#!/bin/bash

set -e

echo "========================================="
echo "CS 1.6 Server Setup - Starting..."
echo "========================================="

# Update system
echo "Updating system packages..."
sudo apt-get update
sudo apt-get install -y lib32gcc-s1 lib32stdc++6 wget tar screen git curl

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
git clone https://github.com/gomezgaona/cs16-iac.git
cd cs16-iac

# Copy server configs
if [ -f "cs16-configs/server.cfg" ]; then
    cp cs16-configs/server.cfg /home/cs-server/hlserver/cstrike/
    echo "✅ Copied server.cfg"
fi

if [ -f "cs16-configs/mapcycle.txt" ]; then
    cp cs16-configs/mapcycle.txt /home/cs-server/hlserver/cstrike/
    echo "✅ Copied mapcycle.txt"
fi

if [ -f "cs16-configs/motd.txt" ]; then
    cp cs16-configs/motd.txt /home/cs-server/hlserver/cstrike/
    echo "✅ Copied motd.txt"
fi

# Copy custom maps
if [ -d "cs16-configs/maps" ]; then
    cp cs16-configs/maps/*.bsp /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.txt /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.res /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.nav /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.bmp /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    echo "✅ Copied custom maps"
fi

# Copy .wad files
if [ -d "cs16-configs" ]; then
    cp cs16-configs/*.wad /home/cs-server/hlserver/cstrike/ 2>/dev/null || true
    echo "✅ Copied texture files"
fi

# Install management scripts from GitHub
echo "Installing management scripts..."
for script in cs16-start cs16-stop cs16-restart cs16-status cs16-console cs16-changemap cs16-backup cs16-restore cs16-update-configs; do
    sudo curl -s -o /usr/local/bin/$script https://raw.githubusercontent.com/gomezgaona/cs16-iac/main/cs16-scripts/${script}.sh
    sudo chmod +x /usr/local/bin/$script
    echo "✅ Installed $script"
done

# Cleanup
rm -rf /tmp/cs16-iac

# Set ownership
sudo chown -R cs-server:cs-server /home/cs-server

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
