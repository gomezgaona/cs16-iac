#!/bin/bash
if screen -list | grep -q "cs16server"; then
    echo "✅ CS 1.6 Server is RUNNING"
else
    echo "❌ CS 1.6 Server is NOT running"
    echo "Use 'cs16-start' to start the server"
fi
