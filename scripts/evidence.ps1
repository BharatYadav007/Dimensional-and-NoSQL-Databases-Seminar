[CmdletBinding()]
param([ValidateSet('installation','containers','redis','redis-features','redis-pubsub','cassandra','cassandra-schema','mongodb','neo4j','verification')][string]$Stage = 'containers')
. (Join-Path $PSScriptRoot 'common.ps1')
$Host.UI.RawUI.WindowTitle = "NoSQL Seminar Evidence - $Stage"
try {
    $Host.UI.RawUI.BackgroundColor = 'Black'
    $Host.UI.RawUI.ForegroundColor = 'White'
    $size = $Host.UI.RawUI.BufferSize
    $size.Height = [Math]::Max(3000, $size.Height)
    $Host.UI.RawUI.BufferSize = $size
} catch { } # Some terminal hosts choose their own dimensions.
try { Clear-Host } catch { } # Also usable from a redirected command runner.
Write-Host 'NoSQL Databases Seminar | Bharat Yadav | BT24GCS397' -ForegroundColor Cyan
Write-Host "Actual execution: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
Write-Host "Stage: $Stage`n"
switch ($Stage) {
    installation {
        Write-Host '> docker version'
        & docker version --format 'Client={{.Client.Version}} Server={{.Server.Version}}'
        Write-Host '> docker compose version'
        & docker compose version
        Write-Host '> docker info (Linux engine and available resources)'
        & docker info --format 'Engine={{.OSType}} CPUs={{.NCPU}} MemoryBytes={{.MemTotal}}'
        Write-Host '> docker compose config --quiet'
        Invoke-SeminarCompose -ComposeArgs @('config','--quiet')
        Write-Host '[PASS] Compose configuration is valid.'
    }
    containers {
        Write-Host '> docker compose ps'
        Invoke-SeminarCompose -ComposeArgs @('ps','--format','table {{.Service}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}')
        Write-Host "`n> docker compose images"
        Invoke-SeminarCompose -ComposeArgs @('images')
    }
    redis { Invoke-SeminarCompose -ComposeArgs @('exec','-T','redis','sh','/seminar/redis-evidence.sh') }
    redis-features { Invoke-SeminarCompose -ComposeArgs @('exec','-T','redis','sh','/seminar/redis-features.sh') }
    redis-pubsub { Invoke-SeminarCompose -ComposeArgs @('exec','-T','redis','sh','/seminar/redis-pubsub.sh') }
    mongodb {
        Write-Host '> mongosh --file /seminar/mongodb-crud.js (compact JSON output)'
        Invoke-SeminarCompose -ComposeArgs @('exec','-T','-e','SEMINAR_COMPACT_OUTPUT=1','mongodb','mongosh','--quiet','--file','/seminar/mongodb-crud.js')
    }
    cassandra-schema {
        Write-Host '> cqlsh -e "SELECT keyspace_name, replication FROM system_schema.keyspaces WHERE keyspace_name = ''university'';"'
        Invoke-SeminarCompose -ComposeArgs @('exec','-T','cassandra','cqlsh','-e',"SELECT keyspace_name, replication FROM system_schema.keyspaces WHERE keyspace_name = 'university';")
        Write-Host '> cqlsh -e "SELECT column_name, kind, type FROM system_schema.columns WHERE keyspace_name = ''university'' AND table_name = ''students'';"'
        Invoke-SeminarCompose -ComposeArgs @('exec','-T','cassandra','cqlsh','-e',"SELECT column_name, kind, type FROM system_schema.columns WHERE keyspace_name = 'university' AND table_name = 'students';")
        Write-Host '> cqlsh -e "SELECT * FROM university.students WHERE student_id = 101;"'
        Invoke-SeminarCompose -ComposeArgs @('exec','-T','cassandra','cqlsh','-e','SELECT * FROM university.students WHERE student_id = 101;')
    }
    verification { & (Join-Path $PSScriptRoot 'verify.ps1') -CheckSample }
    default { & (Join-Path $PSScriptRoot 'test-crud.ps1') -Database $Stage }
}
Write-Host "`nEnd of actual command output. Window kept open for a screenshot." -ForegroundColor Cyan
