# Migration Log - 2026-04-07

## Changes Made

### IPv4 Public IP
- **Before:** Static allocation, Standard SKU, $3.60/month
- **After:** Static allocation, Standard SKU, $3.60/month (unchanged — Basic SKU quota = 0 in region)
- **IP before:** 20.97.5.216
- **IP after:** 4.151.190.232 ⚠️ IP changed during migration attempt

> **Note:** Attempted to switch to Basic/Dynamic to save $3.60/month, but Azure subscription
> quota for Basic IPv4 SKU in South Central US is 0. Dynamic allocation requires Basic SKU.
> Standard SKU is always Static. No cost savings on IPv4.

### IPv6 Public IP
- **Before:** Static allocation, Standard SKU, $3.60/month
- **After:** DELETED
- **Reason:** 185ms latency (routes through Europe vs 65ms IPv4). Not worth $3.60/month.

## Cost Impact
- **Previous:** ~$7.20/month (IPv4 + IPv6 static IPs)
- **Current:** ~$3.60/month (IPv4 static only)
- **Monthly savings:** $3.60/month
- **Annual savings:** $43.20/year

## Current Server Access

```bash
# Current IP
4.151.190.232

# SSH
ssh cs-server@4.151.190.232

# CS 1.6 connect
connect 4.151.190.232:27015

# Check IP anytime
az network public-ip show --resource-group cs16-server-southcentralus-rg --name cs16-pip-ipv4 --query ipAddress -o tsv
```

## What Triggers IP Change (Standard Static)
Standard Static IPs do NOT change on stop/start — the IP is reserved for the resource.
The IP only changes if the public IP resource itself is deleted and recreated (as happened during this migration).

## Helper Script
Run `.\get-server-ip.ps1` to print current IP and connection strings at any time.
