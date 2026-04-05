# CS 1.6 Server - Infrastructure as Code

Automated deployment of a Counter-Strike 1.6 server on Azure using Infrastructure as Code (Bicep).

## Features

- ✅ Automated VM provisioning (B1s, Ubuntu 24.04 LTS)
- ✅ Dual-stack networking (IPv4 + IPv6)
- ✅ Automatic CS 1.6 server installation
- ✅ Custom maps and configs from GitHub
- ✅ Azure Blob Storage for backups
- ✅ Easy-to-use management commands
- ✅ One-command deployment

## Prerequisites

- Azure subscription
- Azure PowerShell module (`Install-Module -Name Az`)
- Git (for version control)

## Quick Start

### 1. Clone Repository
```powershell
git clone https://github.com/jgomezg/cs16-iac.git
cd cs16-iac
```

### 2. Update SSH Key

Edit `parameters.json` and add your SSH public key.

### 3. Deploy
```powershell
.\deploy.ps1
```

Wait 10-15 minutes for deployment to complete.

### 4. Connect
```bash
ssh cs-server@<PUBLIC_IP>
cs16-start
```

## Directory Structure
cs16-iac/
├── main.bicep              # Main infrastructure template
├── parameters.json         # Deployment parameters
├── cs16-setup.sh          # Server setup script
├── deploy.ps1             # Deployment script
├── destroy.ps1            # Cleanup script
├── README.md              # This file
└── cs16-configs/          # Server configuration
├── server.cfg         # Server settings
├── mapcycle.txt       # Map rotation
├── motd.txt           # Message of the day
├── maps/              # Custom maps
│   ├── *.bsp          # Map files
│   ├── *.txt          # Map descriptions
│   ├── *.res          # Resource lists
│   └── *.nav          # Bot navigation
└── *.wad              # Texture files

## Management Commands

After SSH'ing into the server:
```bash
cs16-start              # Start the CS 1.6 server
cs16-stop               # Stop the server
cs16-restart            # Restart the server
cs16-status             # Check if server is running
cs16-console            # Access server console (Ctrl+A then D to exit)
cs16-changemap italy    # Change map (auto-detects prefix)
cs16-backup             # Create backup
cs16-restore <file>     # Restore from backup
cs16-update-configs     # Pull latest configs from GitHub
```

## Updating Configs

1. Edit files in `cs16-configs/` locally
2. Commit and push to GitHub:
```bash
   git add cs16-configs/
   git commit -m "Updated server configs"
   git push
```
3. SSH into server and run:
```bash
   cs16-update-configs
   cs16-start
```

## Cost Estimate

- VM (B1s): ~$7.59/month
- Disk (30GB Standard HDD): ~$1.50/month
- Storage (backups): ~$0.10/month
- Network egress: ~$1-5/month (depending on traffic)

**Total: ~$10-15/month**

## Backup & Restore

### Create Backup
```bash
cs16-backup
```

### List Backups
```bash
az storage blob list --account-name <STORAGE_ACCOUNT> --container-name server-backups --output table
```

### Restore Backup
```bash
cs16-restore cs16-backup-20260405.tar.gz
cs16-start
```

## Cleanup

To destroy all resources:
```powershell
.\destroy.ps1
```

## License

MIT