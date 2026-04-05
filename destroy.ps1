# Destroy CS 1.6 Server Infrastructure

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "cs16-server-rg"
)

Write-Host "⚠️  WARNING: This will delete ALL resources in $ResourceGroupName" -ForegroundColor Red
$confirm = Read-Host "Type 'DELETE' to confirm"

if ($confirm -eq "DELETE") {
    Write-Host "Deleting resource group..." -ForegroundColor Yellow
    Remove-AzResourceGroup -Name $ResourceGroupName -Force
    Write-Host "✅ Resource group deleted" -ForegroundColor Green
} else {
    Write-Host "❌ Deletion cancelled" -ForegroundColor Yellow
}