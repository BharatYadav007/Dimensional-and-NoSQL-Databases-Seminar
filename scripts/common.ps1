Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:SeminarRoot = Split-Path -Parent $PSScriptRoot
$script:SeminarCompose = Join-Path $script:SeminarRoot 'compose.yaml'
$script:SeminarEnv = Join-Path $script:SeminarRoot '.env'

function Invoke-SeminarCompose {
    param([Parameter(Mandatory)][string[]]$ComposeArgs)
    & docker compose --project-directory $script:SeminarRoot --env-file $script:SeminarEnv -f $script:SeminarCompose @ComposeArgs
    if ($LASTEXITCODE -ne 0) { throw "Docker Compose failed (exit $LASTEXITCODE). Run scripts/troubleshoot.ps1." }
}

function Assert-SeminarDocker {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw 'Install Docker Desktop with the WSL 2 backend and Linux containers.'
    }
    & docker compose version
    if ($LASTEXITCODE -ne 0) { throw 'Docker Compose v2 or later is required.' }
    $engine = & docker info --format '{{.OSType}}' 2>$null
    if ($LASTEXITCODE -ne 0) { throw 'Start Docker Desktop, wait for the engine, then rerun. You can use: docker desktop start' }
    if ($engine -ne 'linux') { throw 'Switch Docker Desktop to Linux containers.' }
    if (-not (Test-Path -LiteralPath $script:SeminarEnv)) { throw 'Run scripts/setup.ps1 first to create your private .env file.' }
}
