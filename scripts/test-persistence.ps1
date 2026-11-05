. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
Write-Host 'Verifying sample data before recreating the four containers.'
& (Join-Path $PSScriptRoot 'verify.ps1') -CheckSample
Write-Host 'Recreating containers while keeping all named volumes. No seed scripts are run.'
Invoke-SeminarCompose -ComposeArgs @('up','-d','--force-recreate','--wait','--wait-timeout','900')
& (Join-Path $PSScriptRoot 'verify.ps1') -CheckSample
Write-Host '[PASS] Sample data in all four databases survived container recreation without reseeding.'
