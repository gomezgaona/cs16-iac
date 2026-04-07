#!/bin/bash
echo "Stopping CS 1.6 Server..."
screen -S cs16server -X quit
sleep 2
echo "Starting CS 1.6 Server..."
cd /home/cs-server/hlserver
screen -dmS cs16server ./hlds_run -game cstrike +map awp_minimilitia +maxplayers 16 +port 27015
echo "CS 1.6 Server restarted"
