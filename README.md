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