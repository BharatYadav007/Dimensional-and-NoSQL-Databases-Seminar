# Screenshot evidence for the NoSQL seminar

All files marked **Captured** below are actual screenshots of running applications or live terminal commands. No screenshot was generated from invented output. Terminal screenshots were taken from Windows Terminal after the evidence script executed; the graph screenshot was taken from the connected Neo4j Browser. Screenshots have been visually inspected. Keep the originals when adding them to Word or PowerPoint.

The numeric filenames group evidence by database; gaps do not imply missing files. Several CRUD steps are combined into one readable screenshot.

## Captured images and report captions

| File in `screenshots/` | Status | Suggested caption and observation |
|---|---|---|
| `00_docker_desktop_initial.png` | Captured | Docker Desktop during the initial image download. This is an intermediate setup view, before all images finished downloading. |
| `01_docker_installation.png` | Captured | **Figure 1. Docker and Compose installation verification.** The live client/server versions, Linux engine resources, and successful Compose validation are shown. |
| `02_docker_containers.png` | Captured | **Figure 2. Four NoSQL databases running in Docker Desktop.** The expanded `nosql-seminar` project contains Cassandra, MongoDB, Redis, and Neo4j with their image versions and ports. |
| `03_redis_create_update_delete.png` | Captured | **Figure 3. Redis string and hash CRUD.** `SET`, `GET`, `HSET`, and `HGETALL` read and update test records. `DEL` removes them, and `EXISTS` returns zero. |
| `04_redis_cache_ttl_persistence.png` | Captured | **Figure 4. Redis sets, cache expiration, and persistence configuration.** A cache value is readable before its TTL expires; `EXISTS` later returns zero. AOF is enabled with `everysec` synchronization. |
| `05_redis_pubsub.png` | Captured | **Figure 5. Redis live publish and subscribe.** A genuine background subscriber receives the published message. The subscriber count is one. This capture uses two concurrent CLI processes in one evidence window. |
| `06_cassandra_keyspace.png` | Captured | **Figure 6. Cassandra replication and partition key.** System-schema queries show `NetworkTopologyStrategy`, one replica in `datacenter1`, and `student_id` as the partition key. The seeded student 101 is read from the table. |
| `07_cassandra_crud.png` | Captured | **Figure 7. Cassandra CRUD and consistency settings.** The test row changes from semester 5 to 6 and is then deleted. `LOCAL_ONE` and `LOCAL_QUORUM` execute on a single replica; the final row count is zero. |
| `08_mongodb_crud_indexing.png` | Captured | **Figure 8. MongoDB document CRUD and index access.** The output shows insertion, a flexible nested document, an update, an `IXSCAN` plan, and an empty query result after deletion. An explicit index hint is used. |
| `12_neo4j_graph_visualization.jpg` | Captured | **Figure 9. Student enrollment graph in Neo4j Browser.** Bharat Yadav and the NoSQL Databases course are connected by an `ENROLLED_IN` relationship. The actual query returns two nodes and one relationship. |
| `13_neo4j_update_delete.png` | Captured | **Figure 10. Neo4j traversal, update, and deletion verification.** The test graph is read, semester is updated to 6, and the remaining test-node and relationship counts are both zero. |
| `15_all_databases_verified.png` | Captured | **Figure 11. Successful queries against all four databases.** Authenticated queries are run where authentication is configured, and the shared student sample is verified across the databases. |

`screenshots/manifest.json` records filenames, SHA-256 hashes, dimensions, capture-file timestamps, and the capture status. The timestamp is the local file's last-write time; it is not a substitute for the execution time printed inside the terminal screenshot. `logs/persistence.txt` records the successful container-recreation and data-retention test.

## Reproduce a terminal screenshot

From PowerShell in the Seminar folder, start the services first:

```powershell
.\scripts\start.ps1
```

Then open one evidence window using the corresponding stage below. Wait for **End of actual command output** or the final `[PASS]` line. Ensure no error is visible. Capture the terminal with Windows' screenshot tool and use **Save as** to retain the original filename. Do not include `.env`, passwords, or unrelated windows.

| Screenshot | Exact PowerShell command | Expected observable result |
|---|---|---|
| Installation | `.\scripts\open-evidence.ps1 -Stage installation` | Client/server versions, Linux engine, successful Compose validation |
| Container status alternative | `.\scripts\open-evidence.ps1 -Stage containers` | All four services healthy, expected ports, pinned images |
| Redis CRUD | `.\scripts\open-evidence.ps1 -Stage redis` | Updated hash contains semester 6; deleted keys have `EXISTS = 0` |
| Redis features | `.\scripts\open-evidence.ps1 -Stage redis-features` | Positive TTL, expired key absent, `appendonly=yes` |
| Redis live messaging | `.\scripts\open-evidence.ps1 -Stage redis-pubsub` | Publisher reports a subscriber and the same message appears in subscriber output |
| Cassandra schema | `.\scripts\open-evidence.ps1 -Stage cassandra-schema` | RF 1, student_id partition key, sample student row |
| Cassandra CRUD | `.\scripts\open-evidence.ps1 -Stage cassandra` | Semester 5 then 6, zero remaining test rows |
| MongoDB CRUD and index | `.\scripts\open-evidence.ps1 -Stage mongodb` | Acknowledged writes, document values, `IXSCAN`, empty array after delete |
| Neo4j CRUD | `.\scripts\open-evidence.ps1 -Stage neo4j` | Relationship read, semester 6, zero remaining test nodes and relationships |
| All databases | `.\scripts\open-evidence.ps1 -Stage verification` | Four healthy services, successful real queries, student sample verified |

The screenshot helper can capture the actual current desktop from a separate command runner:

```powershell
.\scripts\capture-screen.ps1 -Filename my_capture.png
```

It captures whichever window is currently visible. It does not activate an evidence window. Review the image immediately and discard or recapture an unrelated view. The script handles Windows display scaling so the right and bottom edges are not accidentally clipped.

## Reproduce the Docker Desktop screenshot

Open Docker Desktop, select **Containers**, and expand **nosql-seminar**. Keep the four database rows, image tags, and port mappings visible. Capture only after all services are running. Pair this image with the terminal verification screenshot, since Docker Desktop's green running indicator alone does not prove query readiness.

## Reproduce the Neo4j graph screenshot

1. Open [Neo4j Browser](http://localhost:7474).
2. Connect to `neo4j://localhost:7687` as `neo4j`, using `NEO4J_PASSWORD` from your private `.env`. If you changed host ports, use those values.
3. Run this Cypher query:

```cypher
MATCH (s:Student {student_id: 101})-[r:ENROLLED_IN]->(c:Course)
RETURN s, r, c;
```

4. Select **Graph** and **Zoom to fit** if needed. Keep the query, both nodes, and relationship label visible.
5. Capture the window after the results appear. Do not capture the sign-in form or password.

If no graph appears, run `scripts/initialize.ps1` and retry. The CRUD tests delete only test student 9101; student 101 is intentionally kept for this graph.

## Optional additional captures

The captured Pub/Sub image already proves live messaging using concurrent processes. For a two-window presentation, use the two-terminal `SUBSCRIBE`/`PUBLISH` instructions in `README.md`, place both terminals side by side, and capture the actual received message.

Python execution screenshots, the full academic report, and the presentation are outside this Docker setup's current deliverables. No Python screenshot, report, or slide deck is claimed as completed here. When those are implemented, add their genuine screenshots to the manifest only after the files exist.

For the report, explain each observed result beneath its figure. Preserve the distinction between student **101**, which remains stored for demonstrations, and test student **9101**, which is created and deleted during CRUD checks. Do not describe this single-node Cassandra setup as evidence of replication failover or performance benchmarking.
