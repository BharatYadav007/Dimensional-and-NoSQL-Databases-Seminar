. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
Write-Host 'Loading Bharat Yadav / BT24GCS397 / student 101 in all four databases.'
Write-Host 'Existing sample 101 is updated. Other student IDs are preserved.'
Invoke-SeminarCompose -ComposeArgs @('exec','-T','redis','sh','-ec','export REDISCLI_AUTH="$REDIS_PASSWORD"; redis-cli --pipe < /seminar/redis-seed.txt')
Invoke-SeminarCompose -ComposeArgs @('exec','-T','cassandra','cqlsh','127.0.0.1','9042','--request-timeout=60','-f','/seminar/cassandra-init.cql')
Invoke-SeminarCompose -ComposeArgs @('exec','-T','mongodb','mongosh','--quiet','--host','127.0.0.1','--file','/seminar/mongodb-init.js')
Invoke-SeminarCompose -ComposeArgs @('exec','-T','neo4j','sh','-ec','exec cypher-shell -a bolt://127.0.0.1:7687 -u neo4j -p "$SEMINAR_NEO4J_PASSWORD" --format plain -f /seminar/neo4j-init.cypher')
& (Join-Path $PSScriptRoot 'verify.ps1') -CheckSample
