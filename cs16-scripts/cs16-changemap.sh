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
    exit 1
fi
echo "🗺️  Changing map to: $FULLMAP"
screen -S cs16server -p 0 -X stuff "changelevel $FULLMAP^M"
echo "✅ Map change command sent!"
