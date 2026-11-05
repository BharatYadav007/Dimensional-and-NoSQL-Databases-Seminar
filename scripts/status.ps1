. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
Invoke-SeminarCompose -ComposeArgs @('ps','-a')
