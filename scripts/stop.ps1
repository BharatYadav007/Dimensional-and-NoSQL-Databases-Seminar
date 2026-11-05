[CmdletBinding()]
param([switch]$RemoveContainers)
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
if ($RemoveContainers) { Invoke-SeminarCompose -ComposeArgs @('down') }
else { Invoke-SeminarCompose -ComposeArgs @('stop') }
Write-Host 'Database volumes and stored data have been kept.'
