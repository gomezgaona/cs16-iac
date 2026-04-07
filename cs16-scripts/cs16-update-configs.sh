#!/bin/bash
echo "Updating configs from GitHub..."
cd /tmp
rm -rf cs16-iac
git clone https://github.com/gomezgaona/cs16-iac.git
cd cs16-iac

cs16-stop
sleep 2

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

if [ -d "cs16-configs/maps" ]; then
    cp cs16-configs/maps/*.bsp /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.txt /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.res /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.nav /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    cp cs16-configs/maps/*.bmp /home/cs-server/hlserver/cstrike/maps/ 2>/dev/null || true
    echo "✅ Updated maps"
fi

if [ -d "cs16-configs" ]; then
    cp cs16-configs/*.wad /home/cs-server/hlserver/cstrike/ 2>/dev/null || true
    echo "✅ Updated texture files"
fi

rm -rf /tmp/cs16-iac
chown -R cs-server:cs-server /home/cs-server/hlserver

echo ""
echo "✅ Configuration update complete!"
echo "Start server with: cs16-start"
