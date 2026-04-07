# CS 1.6 Server - Infrastructure as Code

Automated provisioning of a Counter-Strike 1.6 dedicated server on Azure using Bicep IaC.

## Infrastructure Details

| Property | Value |
|---|---|
| Region | South Central US (Texas) |
| VM Size | Standard_B1s (1 vCPU, 1 GB RAM) |
| OS | Ubuntu 22.04 LTS (Jammy) |
| Disk | 30 GB Standard HDD |
| Hostname | azure-b1 |
| SSH Username | cs-server |
| Game Port | UDP/TCP 27015 |
| Expected latency from Colorado | 45-55 ms |

## Cost Estimate

| Resource | Monthly |
|---|---|
| VM (B1s) | ~$7.59 |
| OS Disk (30 GB Standard HDD) | ~$1.50 |
| Blob Storage (backups) | ~$0.10 |
| Network egress | ~$1-5 |
| **Total** | **~$10-15** |

## Prerequisites

- Azure subscription
- Azure PowerShell module: `Install-Module -Name Az`
- SSH key pair (ed25519 recommended)

## Repository Structure

```
cs16-iac/
├── main.bicep              # Bicep infrastructure template
├── parameters.json         # Deployment parameters
├── deploy.ps1              # PowerShell deployment script
├── destroy.ps1             # Cleanup / teardown script
├── cs16-setup.sh           # Manual server setup script (run after deploy)
├── README.md               # This file
└── cs16-configs/           # Server configuration files
    ├── server.cfg          # CS 1.6 server settings
    ├── mapcycle.txt        # Map rotation
    ├── maps/               # Custom map files
    │   ├── *.bsp           # Map geometry
    │   ├── *.txt           # Map info
    │   ├── *.res           # Resource lists
    │   ├── *.nav           # Bot navigation
    │   └── *.bmp           # Thumbnails
    └── *.wad               # Texture files
```

## Quick Start

### 1. Clone the repository

```powershell
git clone https://github.com/gomezgaona/cs16-iac.git
cd cs16-iac
```

### 2. Update SSH key

Edit `parameters.json` and replace the `sshPublicKey` value with your own public key.

### 3. Deploy infrastructure

```powershell
.\deploy.ps1 -ResourceGroupName "cs16-server-rg" -Location "southcentralus"
```

The script creates a resource group, provisions the VM, storage account, VNet, NSG, and dual-stack public IPs. It takes about 5-10 minutes.

> **Note:** The VM extension was removed from the template. CS 1.6 is NOT installed automatically. You must run the setup script manually after the VM is created (see step 4).

### 4. Install CS 1.6 (manual)

SSH into the VM using the IP printed at the end of the deployment:

```bash
ssh cs-server@<PUBLIC_IP>
```

Download and run the setup script:

```bash
curl -o cs16-setup.sh https://raw.githubusercontent.com/gomezgaona/cs16-iac/main/cs16-setup.sh
chmod +x cs16-setup.sh
sudo bash cs16-setup.sh
```

The script will:
- Install system dependencies and SteamCMD
- Download and install the CS 1.6 dedicated server (~1 GB)
- Clone this repository and copy all configs, maps, and textures
- Create all management commands in `/usr/local/bin/`

Installation takes approximately 10-15 minutes depending on network speed.

### 5. Start the server

```bash
cs16-start
```

Verify it's running:

```bash
cs16-status
```

## Management Commands

Run these after SSH'ing into the server:

```bash
cs16-start                  # Start the CS 1.6 server
cs16-stop                   # Stop the server
cs16-restart                # Restart the server
cs16-status                 # Check if server is running
cs16-console                # Attach to server console (Ctrl+A then D to detach)
cs16-changemap <mapname>    # Change map (auto-detects prefix: de_, cs_, awp_, etc.)
cs16-backup                 # Create a .tar.gz backup in /tmp/
cs16-restore <file>         # Restore from a backup file
cs16-update-configs         # Pull latest configs from GitHub and apply
```

### Map change examples

```bash
cs16-changemap dust2
cs16-changemap italy
cs16-changemap minimilitia
cs16-changemap awp_minimilitia   # full name also works
```

## Updating Configs

1. Edit files in `cs16-configs/` locally
2. Commit and push:
   ```bash
   git add cs16-configs/
   git commit -m "Update server configs"
   git push
   ```
3. SSH into the server and run:
   ```bash
   cs16-update-configs
   cs16-start
   ```

## Backup and Restore

### Create a backup

```bash
cs16-backup
```

### Upload backup to Azure Blob Storage

```bash
az storage blob upload \
  --account-name <STORAGE_ACCOUNT> \
  --container-name server-backups \
  --name cs16-backup-20260406.tar.gz \
  --file /tmp/cs16-backup-20260406.tar.gz
```

### List backups

```bash
az storage blob list \
  --account-name <STORAGE_ACCOUNT> \
  --container-name server-backups \
  --output table
```

### Restore from backup

```bash
cs16-restore cs16-backup-20260406.tar.gz
cs16-start
```

## Teardown

To delete all Azure resources:

```powershell
.\destroy.ps1 -ResourceGroupName "cs16-server-rg"
```

## License

MIT
