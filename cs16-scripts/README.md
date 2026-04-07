# CS 1.6 Server Management Scripts

These scripts are installed to `/usr/local/bin/` on the Azure VM.

## Installation

SSH into the server and run:

```bash
# Copy each script from GitHub
for script in cs16-start cs16-stop cs16-restart cs16-status cs16-console cs16-changemap cs16-backup cs16-restore cs16-update-configs; do
    sudo curl -o /usr/local/bin/$script https://raw.githubusercontent.com/gomezgaona/cs16-iac/main/cs16-scripts/${script}.sh
    sudo chmod +x /usr/local/bin/$script
done
```

## Available Commands

- `cs16-start` - Start the CS 1.6 server
- `cs16-stop` - Stop the server
- `cs16-restart` - Restart the server
- `cs16-status` - Check if server is running
- `cs16-console` - Access server console (Ctrl+A then D to exit)
- `cs16-changemap <map>` - Change map (auto-detects prefix)
- `cs16-backup` - Create backup tarball
- `cs16-restore <file>` - Restore from backup
- `cs16-update-configs` - Pull latest configs from GitHub
