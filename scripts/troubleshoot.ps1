. (Join-Path $PSScriptRoot 'common.ps1')
Write-Host 'Docker client, Compose, engine, and WSL'
& docker version
& docker compose version
& wsl --status
$engine = & docker info --format 'Engine={{.OSType}} CPUs={{.NCPU}} MemoryBytes={{.MemTotal}}' 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host 'Start Docker Desktop with Linux containers, then retry.'; return }
Write-Host $engine
if (-not (Test-Path -LiteralPath $script:SeminarEnv)) { Write-Host 'Run scripts/setup.ps1 first.'; return }
Invoke-SeminarCompose -ComposeArgs @('config','--quiet')
Invoke-SeminarCompose -ComposeArgs @('ps','-a')
Invoke-SeminarCompose -ComposeArgs @('logs','--tail','60','--no-color')
Write-Host 'Listening host ports'
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object LocalPort -In 6379,9042,27017,7474,7687 |
    Select-Object LocalAddress,LocalPort,OwningProcess
