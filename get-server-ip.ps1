param(
    [string]$ResourceGroup = "cs16-server-southcentralus-rg",
    [string]$PublicIPName = "cs16-pip-ipv4"
)

$ipv4 = az network public-ip show `
  --resource-group $ResourceGroup `
  --name $PublicIPName `
  --query ipAddress `
  --output tsv

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CS 1.6 Server Current IP Address" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IPv4: $ipv4" -ForegroundColor Green
Write-Host ""
Write-Host "SSH Command:" -ForegroundColor Yellow
Write-Host "  ssh cs-server@$ipv4" -ForegroundColor White
Write-Host ""
Write-Host "CS 1.6 Connect:" -ForegroundColor Yellow
Write-Host "  connect ${ipv4}:27015" -ForegroundColor White
Write-Host ""
Write-Host "Ping Test:" -ForegroundColor Yellow
Write-Host "  ping $ipv4" -ForegroundColor White
Write-Host ""
