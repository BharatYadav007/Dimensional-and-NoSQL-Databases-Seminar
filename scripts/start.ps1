[CmdletBinding()]
param([ValidateSet('redis','cassandra','mongodb','neo4j')][string[]]$Service,
      [ValidateRange(60,3600)][int]$TimeoutSeconds = 900)
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
Invoke-SeminarCompose -ComposeArgs @('config','--quiet')
Write-Host 'Starting databases. Cassandra may need several minutes on its first start.'
$upArgs = @('up','-d','--wait','--wait-timeout',"$TimeoutSeconds")
if ($Service) { $upArgs += $Service }
Invoke-SeminarCompose -ComposeArgs $upArgs
Invoke-SeminarCompose -ComposeArgs @('ps')
