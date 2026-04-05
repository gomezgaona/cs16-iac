# CS 1.6 Server - Infrastructure as Code Deployment
# This script deploys the entire CS 1.6 server infrastructure to Azure

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "cs16-server-rg",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus2"
)

Write-Host "🚀 CS 1.6 Server - Infrastructure as Code Deployment" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""

# Check if logged into Azure
Write-Host "Checking Azure login..." -ForegroundColor Yellow
$context = Get-AzContext -ErrorAction SilentlyContinue
if (!$context) {
    Write-Host "Not logged into Azure. Logging in..." -ForegroundColor Yellow
    Connect-AzAccount
}

Write-Host "✅ Logged in as: $($context.Account)" -ForegroundColor Green
Write-Host ""

# Create Resource Group
Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force
Write-Host "✅ Resource group created" -ForegroundColor Green
Write-Host ""

# Deploy Bicep template
Write-Host "Deploying infrastructure (this may take 5-10 minutes)..." -ForegroundColor Yellow
$deployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile ".\main.bicep" `
    -TemplateParameterFile ".\parameters.json" `
    -Verbose

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Deployment Outputs:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "VM Public IPv4: $($deployment.Outputs.vmPublicIPv4.Value)" -ForegroundColor White
Write-Host "VM Public IPv6: $($deployment.Outputs.vmPublicIPv6.Value)" -ForegroundColor White
Write-Host "Storage Account: $($deployment.Outputs.storageAccountName.Value)" -ForegroundColor White
Write-Host "SSH Command: $($deployment.Outputs.sshCommand.Value)" -ForegroundColor White
Write-Host ""
Write-Host "⏳ Server is installing CS 1.6 (takes ~5-10 minutes)" -ForegroundColor Yellow
Write-Host "Wait a few minutes, then SSH in and run: cs16-start" -ForegroundColor Yellow