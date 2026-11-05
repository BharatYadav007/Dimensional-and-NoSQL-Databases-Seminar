[CmdletBinding()]
param([switch]$NoBuild)
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
if (-not $NoBuild) {
    Invoke-SeminarCompose -ComposeArgs @('--profile','demo','build','python-demo')
}
Invoke-SeminarCompose -ComposeArgs @('--profile','demo','run','--rm','python-demo')
