[CmdletBinding()]
param([ValidateSet('installation','containers','redis','redis-features','redis-pubsub','cassandra','cassandra-schema','mongodb','neo4j','verification')][string]$Stage = 'containers')
$terminal = Get-Command wt -ErrorAction Stop
$shell = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $shell) { $shell = Get-Command powershell -ErrorAction Stop }
$scriptFile = Join-Path $PSScriptRoot 'evidence.ps1'
Start-Process -FilePath $terminal.Source -ArgumentList @('-w','new','--maximized','nt',
    '--title',('"NoSQL Seminar Evidence - ' + $Stage + '"'),
    ('"' + $shell.Source + '"'),'-NoLogo','-NoProfile','-NoExit','-File',('"' + $scriptFile + '"'),'-Stage',$Stage)
