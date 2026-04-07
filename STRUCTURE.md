# CS 1.6 IaC Project Structure

```
cs16-iac/
├── README.md                   # Main documentation
├── STRUCTURE.md               # This file
├── .gitignore                 # Git ignore patterns
├── main.bicep                 # Infrastructure template (Dynamic IPs, Ubuntu 22.04)
├── parameters.json            # Deployment parameters
├── deploy.ps1                 # PowerShell deployment script
├── destroy.ps1                # Cleanup script
├── cs16-setup.sh              # Complete server setup script
├── cs16-scripts/              # Management scripts (backed up to GitHub)
│   ├── README.md              # Script documentation
│   ├── cs16-start.sh          # Start server
│   ├── cs16-stop.sh           # Stop server
│   ├── cs16-restart.sh        # Restart server
│   ├── cs16-status.sh         # Check status
│   ├── cs16-console.sh        # Access console
│   ├── cs16-changemap.sh      # Change map
│   ├── cs16-backup.sh         # Create backup
│   ├── cs16-restore.sh        # Restore backup
│   └── cs16-update-configs.sh # Update from GitHub
└── cs16-configs/              # Server configuration
    ├── server.cfg             # CS 1.6 config
    ├── mapcycle.txt           # Map rotation
    ├── motd.txt               # Message of day (optional)
    ├── maps/                  # Custom maps
    │   ├── *.bsp              # Map files
    │   ├── *.txt              # Descriptions
    │   ├── *.res              # Resources
    │   ├── *.nav              # Navigation
    │   └── *.bmp              # Overviews
    └── *.wad                  # Textures
```

## Key Changes from Original

1. **Dynamic IPs** - Saves $7.20/month
2. **IPv6 Removed** - Poor routing (185ms vs 65ms IPv4)
3. **Scripts Backed Up** - All management scripts in cs16-scripts/
4. **Complete Setup** - cs16-setup.sh installs everything
5. **GitHub-Driven** - Configs and scripts pulled from repo

## Deployment Flow

1. Run deploy.ps1 → Creates Azure infrastructure
2. SSH into VM → Run cs16-setup.sh
3. Setup script → Pulls configs from GitHub
4. Setup script → Installs management scripts from GitHub
5. Server ready → Run cs16-start
