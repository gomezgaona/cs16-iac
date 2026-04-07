#!/bin/bash
cd /home/cs-server/hlserver
screen -dmS cs16server ./hlds_run -game cstrike +map awp_minimilitia +maxplayers 16 +port 27015
echo "CS 1.6 Server started in background (screen session: cs16server)"
echo "Use 'cs16-status' to check if it's running"
echo "Use 'cs16-console' to view/interact with the server console"
