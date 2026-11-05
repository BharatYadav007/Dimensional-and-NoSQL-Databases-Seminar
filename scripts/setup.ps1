[CmdletBinding()]
param([switch]$ConfigureOnly, [switch]$SkipPull, [switch]$SkipSeed)
. (Join-Path $PSScriptRoot 'common.ps1')

if (-not (Test-Path -LiteralPath $script:SeminarEnv)) {
    $template = [IO.File]::ReadAllText((Join-Path $script:SeminarRoot '.env.example'))
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        foreach ($dbName in @('REDIS','MONGODB','NEO4J')) {
            $randomBytes = New-Object byte[] 24
            $rng.GetBytes($randomBytes)
            $password = ([BitConverter]::ToString($randomBytes)).Replace('-','').ToLowerInvariant()
            $template = $template.Replace("CHANGE_ME_$dbName", $password)
        }
    } finally { $rng.Dispose() }
    [IO.File]::WriteAllText($script:SeminarEnv, $template, (New-Object Text.UTF8Encoding $false))
    Write-Host 'Created private .env with separate random database passwords.'
} else {
    Write-Host 'Keeping your existing .env and credentials.'
}
if ([IO.File]::ReadAllText($script:SeminarEnv) -match 'CHANGE_ME_') {
    throw 'Replace the CHANGE_ME password placeholders in .env before continuing.'
}
if ($ConfigureOnly) { return }
Assert-SeminarDocker
Invoke-SeminarCompose -ComposeArgs @('config','--quiet')
if (-not $SkipPull) { Invoke-SeminarCompose -ComposeArgs @('pull') }
& (Join-Path $PSScriptRoot 'start.ps1')
if (-not $SkipSeed) { & (Join-Path $PSScriptRoot 'initialize.ps1') }
