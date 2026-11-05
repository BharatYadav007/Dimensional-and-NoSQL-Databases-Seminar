# Execution verification

Validation was performed locally on Windows on **29 October 2026**, using Docker Desktop's Linux engine. The four project containers were left running.

| Check | Observed result |
|---|---|
| PowerShell parsing | All project `.ps1` files parsed successfully |
| Compose validation | `docker compose config --quiet` completed successfully |
| Image download | All four pinned official images downloaded successfully |
| Service readiness | Redis, Cassandra, MongoDB, and Neo4j all reported `healthy` |
| Redis connection | Authenticated `PING` returned `PONG` |
| Cassandra connection | CQL returned version `5.0.9` in `datacenter1` |
| MongoDB connection | Authenticated ping returned `ok: 1` |
| Neo4j connection | Authenticated Cypher `RETURN 1` returned `1` |
| Shared sample | Enrollment `BT24GCS397` verified in all four databases; graph relationship verified |
| Redis CRUD | String/hash reads, updates, and deletion assertions passed |
| Redis concepts | Set membership, cache read, TTL expiry, and AOF settings checked |
| Redis Pub/Sub | A real subscriber received the published message |
| Cassandra CRUD | Insert/select/update/delete assertions passed |
| Cassandra concepts | Partition key and RF 1 inspected; LOCAL_ONE and LOCAL_QUORUM executed |
| MongoDB CRUD | Insert/find/update/delete assertions passed |
| MongoDB concepts | Nested document, array, added field, unique index, and hinted IXSCAN plan checked |
| Neo4j CRUD | Node/relationship creation, traversal, update, and deletion assertions passed |
| Persistence | All four containers recreated; sample 101 retained without reseeding |
| Window evidence | Genuine terminal, Docker Desktop, and Neo4j Browser screenshots saved |

`logs/crud.txt`, `logs/verify.txt`, and `logs/persistence.txt` contain command output from actual runs. The initial initialization log includes a Compose JSON parsing error discovered during development; it was corrected in `scripts/verify.ps1`, and subsequent verification and persistence checks passed. The successful end-to-end setup rerun is recorded in `logs/setup.txt`.

## Reproduce the checks

```powershell
.\scripts\setup.ps1 -SkipPull
.\scripts\verify.ps1 -CheckSample
.\scripts\test-crud.ps1
.\scripts\test-persistence.ps1
.\scripts\evidence.ps1 -Stage redis-pubsub
```

The persistence check briefly recreates the containers. It preserves their volumes and never runs seed scripts between its before/after checks.

## Practical limits

- This is a local university demonstration. Cassandra uses no authentication; only its loopback host port is published.
- Cassandra has one node and RF 1. The consistency-level commands do not establish multi-node fault tolerance or distributed consistency tradeoffs.
- MongoDB runs as a standalone server. Replica-set behavior, sharding, and failover are not demonstrated.
- The MongoDB explain demonstration deliberately hints the student index; it is not a performance comparison.
- Redis persistence configuration and clean container recreation were checked. Power-loss durability was not tested.
- No throughput or latency benchmark is claimed.
- Python driver modules, the 8–10 page academic report, and PowerPoint are not part of this Docker-only implementation.
