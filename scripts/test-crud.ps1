[CmdletBinding()]
param([ValidateSet('redis','cassandra','mongodb','neo4j')][string[]]$Database = @('redis','cassandra','mongodb','neo4j'))
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-SeminarDocker
foreach ($dbName in $Database) {
    Write-Host "`n========== $($dbName.ToUpperInvariant()) CRUD =========="
    switch ($dbName) {
        redis { Invoke-SeminarCompose -ComposeArgs @('exec','-T','redis','sh','/seminar/redis-crud.sh') }
        cassandra {
            $output = @(Invoke-SeminarCompose -ComposeArgs @('exec','-T','cassandra','cqlsh','--request-timeout=60','-f','/seminar/cassandra-crud.cql'))
            $text = $output -join "`n"
            Write-Output $text
            if ($text -notmatch '"semester": 5' -or $text -notmatch '"semester": 6' -or $text -notmatch '(?m)^\s*0\s*$') {
                throw 'Cassandra create/update/deletion assertions failed.'
            }
            Write-Host '[PASS] Cassandra create, read, update, delete and two consistency levels (RF=1).'
        }
        mongodb { Invoke-SeminarCompose -ComposeArgs @('exec','-T','mongodb','mongosh','--quiet','--file','/seminar/mongodb-crud.js') }
        neo4j {
            $output = @(Invoke-SeminarCompose -ComposeArgs @('exec','-T','neo4j','sh','-ec','exec cypher-shell -a bolt://127.0.0.1:7687 -u neo4j -p "$SEMINAR_NEO4J_PASSWORD" --format plain -f /seminar/neo4j-crud.cypher'))
            $text = $output -join "`n"
            Write-Output $text
            if ($text -notmatch 'ENROLLED_IN' -or $text -notmatch '(?m)^6\s*$' -or ([regex]::Matches($text,'(?m)^0\s*$')).Count -ne 2) {
                throw 'Neo4j relationship/update/deletion assertions failed.'
            }
            Write-Host '[PASS] Neo4j nodes, relationship traversal, update, node and relationship deletion.'
        }
    }
}
Write-Host "`n[PASS] All requested CRUD demonstrations completed. Sample student 101 remains available."
