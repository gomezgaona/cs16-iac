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
