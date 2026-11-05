[CmdletBinding()]
param([Parameter(Mandatory)][ValidateSet('redis','cassandra','mongodb','neo4j')][string]$Database)
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
switch ($Database) {
    redis { Invoke-SeminarCompose -ComposeArgs @('exec','redis','sh','-ec','export REDISCLI_AUTH="$REDIS_PASSWORD"; exec redis-cli') }
    cassandra { Invoke-SeminarCompose -ComposeArgs @('exec','cassandra','cqlsh','127.0.0.1','9042') }
    mongodb { Invoke-SeminarCompose -ComposeArgs @('exec','mongodb','sh','-ec','exec mongosh --username "$MONGO_INITDB_ROOT_USERNAME" --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin university') }
    neo4j { Invoke-SeminarCompose -ComposeArgs @('exec','neo4j','sh','-ec','exec cypher-shell -a bolt://127.0.0.1:7687 -u neo4j -p "$SEMINAR_NEO4J_PASSWORD"') }
}
