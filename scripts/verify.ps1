[CmdletBinding()]
param([switch]$CheckSample)
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
$jsonLines = @(Invoke-SeminarCompose -ComposeArgs @('ps','--all','--format','json'))
$services = @($jsonLines | ForEach-Object { $_ | ConvertFrom-Json })
foreach ($name in @('redis','cassandra','mongodb','neo4j')) {
    $item = @($services | Where-Object Service -eq $name)
    if ($item.Count -ne 1 -or $item[0].State -ne 'running' -or $item[0].Health -ne 'healthy') {
        throw "$name is missing or not healthy. Run scripts/status.ps1 and scripts/troubleshoot.ps1."
    }
    Write-Host "[HEALTHY] $name"
}
Write-Host "`nRedis authenticated PING"
Invoke-SeminarCompose -ComposeArgs @('exec','-T','redis','sh','-ec','export REDISCLI_AUTH="$REDIS_PASSWORD"; test "$(redis-cli ping)" = PONG; redis-cli ping')
Write-Host "`nCassandra CQL version"
Invoke-SeminarCompose -ComposeArgs @('exec','-T','cassandra','cqlsh','-e','SELECT release_version, data_center FROM system.local;')
Write-Host "`nMongoDB authenticated PING"
Invoke-SeminarCompose -ComposeArgs @('exec','-T','mongodb','mongosh','--quiet','--eval','const a=db.getSiblingDB("admin"); if (!a.auth(process.env.MONGO_INITDB_ROOT_USERNAME,process.env.MONGO_INITDB_ROOT_PASSWORD).ok) quit(1); const p=a.runCommand({ping:1}); printjson(p); if(p.ok!==1) quit(2);')
Write-Host "`nNeo4j authenticated Cypher query"
Invoke-SeminarCompose -ComposeArgs @('exec','-T','neo4j','sh','-ec','exec cypher-shell -a bolt://127.0.0.1:7687 -u neo4j -p "$SEMINAR_NEO4J_PASSWORD" --format plain "RETURN 1 AS connected;"')
if ($CheckSample) {
    Write-Host "`nChecking sample student 101"
    $redisSample = @(Invoke-SeminarCompose -ComposeArgs @('exec','-T','redis','sh','-ec','export REDISCLI_AUTH="$REDIS_PASSWORD"; redis-cli --raw HGET seminar:student:101 enrollment_no'))
    if (($redisSample -join '').Trim() -ne 'BT24GCS397') { throw 'Redis sample check failed.' }
    $cassandraSample = @(Invoke-SeminarCompose -ComposeArgs @('exec','-T','cassandra','cqlsh','-e','SELECT enrollment_no FROM university.students WHERE student_id = 101;'))
    if (($cassandraSample -join "`n") -notmatch 'BT24GCS397') { throw 'Cassandra sample check failed.' }
    Invoke-SeminarCompose -ComposeArgs @('exec','-T','mongodb','mongosh','--quiet','--eval','const a=db.getSiblingDB("admin"); if(!a.auth(process.env.MONGO_INITDB_ROOT_USERNAME,process.env.MONGO_INITDB_ROOT_PASSWORD).ok) quit(1); const s=db.getSiblingDB("university").students.findOne({student_id:101}); if(!s || s.enrollment_no!=="BT24GCS397") quit(2); print("MongoDB sample verified");')
    $neo4jSample = @(Invoke-SeminarCompose -ComposeArgs @('exec','-T','neo4j','sh','-ec','exec cypher-shell -a bolt://127.0.0.1:7687 -u neo4j -p "$SEMINAR_NEO4J_PASSWORD" --format plain "MATCH (s:Student {student_id:101})-[:ENROLLED_IN]->(:Course) RETURN s.enrollment_no AS enrollment_no;"'))
    if (($neo4jSample -join "`n") -notmatch 'BT24GCS397') { throw 'Neo4j sample or relationship check failed.' }
    Write-Host '[PASS] Sample record and Neo4j relationship verified in all four databases.'
}
Write-Host "`n[PASS] All four databases accepted real queries."
