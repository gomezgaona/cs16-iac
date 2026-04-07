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

**Region:** South Central US (Texas)

- VM (B1s): ~$7.59/month
- Disk (30GB Standard HDD): ~$1.50/month
- Storage (backups): ~$0.10/month
- Network egress: ~$1-5/month
- Dynamic IPv4: $0/month (while running)

**Total: ~$9-11/month**

**Previous cost with static IPs:** ~$16/month
**Monthly savings:** ~$7/month ($84/year)

**Note:** IP address may change if VM is stopped/deallocated. Use `az vm restart` instead of deallocate to preserve IP.

## Latency Results

Measured latency to South Central US (Texas) deployment:

| Location | IPv4 Latency | IPv6 Latency | Notes |
|----------|-------------|--------------|-------|
| Durango, CO | 65ms | 185ms | IPv6 routes through Europe! |
| Charlotte, NC | 30ms | N/A | Excellent for SE US |
| Columbia, SC (est.) | 35-40ms | N/A | Great for players |

**Recommendation:** Always use IPv4. IPv6 has poor peering/routing.

## Important: Dynamic IP Behavior

This deployment uses **dynamic public IPs** to save $7.20/month.

**IP stays the same when:**
- ✅ Rebooting from inside VM (`sudo reboot`)
- ✅ Using `az vm restart`
- ✅ Normal operation

**IP changes when:**
- ❌ Using `az vm stop` (deallocate) then `az vm start`
- ❌ Stopping VM from Azure Portal

**To preserve IP:** Always use restart, not stop/start.

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
├── cs16-setup.sh           # Complete server setup script
├── STRUCTURE.md            # Detailed project structure
├── README.md               # This file
├── cs16-scripts/           # Management scripts (backed up to GitHub)
│   ├── cs16-start.sh
│   ├── cs16-stop.sh
│   ├── cs16-restart.sh
│   ├── cs16-status.sh
│   ├── cs16-console.sh
│   ├── cs16-changemap.sh
│   ├── cs16-backup.sh
│   ├── cs16-restore.sh
│   └── cs16-update-configs.sh
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

The script creates a resource group, provisions the VM, storage account, VNet, NSG, and public IP. It takes about 5-10 minutes.

> **Note:** The VM extension was removed from the template. CS 1.6 is NOT installed automatically. You must run the setup script manually after the VM is created (see step 4).

### 4. Install CS 1.6 (manual)

## Quick Installation

After VM deployment, SSH in and run:

```bash
wget https://raw.githubusercontent.com/gomezgaona/cs16-iac/main/cs16-setup.sh
chmod +x cs16-setup.sh
sudo ./cs16-setup.sh
```

This installs CS 1.6, pulls configs from GitHub, and sets up all management scripts.

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
