# NoSQL databases seminar Docker setup

Bharat Yadav · BT24GCS397 · CS 3102 · Semester 5

This folder contains the local database infrastructure and practical CLI demonstrations for `Seminar1.docx`. It follows the University Student Management example in the supplied [shared chat](https://chatgpt.com/share/6ae3202b-2250-83ec-8327-e92ab2f30d67). All Docker files live directly under this Seminar folder; there is no second project folder.

The four services use the official database images. A custom Dockerfile is unnecessary because configuration, persistence, and initialization are supplied through Compose and mounted files.

| Service | Pinned image | Windows connection | Authentication |
|---|---|---|---|
| Redis | `redis:7.4.12-alpine` | `127.0.0.1:6379` | Password from `.env` |
| Cassandra | `cassandra:5.0.9` | `127.0.0.1:9042` | No authentication in this isolated local exercise |
| MongoDB | `mongo:8.0.34` | `127.0.0.1:27017` | `seminar_admin`, password from `.env`, auth database `admin` |
| Neo4j Community | `neo4j:5.26.32-community` | [Browser](http://localhost:7474), Bolt `localhost:7687` | `neo4j`, password from `.env` |

Only loopback host ports are published. The databases share a project Docker network. Cassandra uses one node and replication factor 1; this setup does not demonstrate failover, multi-node replication, or cluster-scale performance. Its CQL port trusts local processes and containers on this project network. MongoDB is a standalone server, without replica-set failover or multi-document transactions.

## Prerequisites

- Docker Desktop running **Linux containers** with its WSL 2 backend.
- Windows PowerShell 5.1 or PowerShell 7. Windows Terminal is needed only for the screenshot helper.
- Internet access for the initial image download.
- Recommended Docker engine memory: 8 GB or more. The container limits total about 5.9 GiB, with additional engine overhead. The machine used for validation provided about 15.4 GiB to the engine.

Redis is limited to 384 MiB with a 192 MiB key-space limit, Cassandra to 3 GiB with a 1 GiB JVM heap, MongoDB to 1 GiB with a 256 MiB WiredTiger cache, and Neo4j to 1.5 GiB with a 512 MiB heap and 256 MiB page cache. These are small seminar settings, not performance recommendations.

## First run

Open PowerShell in this folder:

```powershell
Set-Location -LiteralPath 'D:\NIIT University\Semester 5\Dimensional and NoSQL Databases (CS 3102)\Seminar'
docker version
docker compose version
.\scripts\setup.ps1
```

`setup.ps1` generates separate random passwords in a private `.env`, checks Docker, validates Compose, downloads the images, waits for all four databases to become healthy, and loads student 101. It preserves an existing `.env`. Cassandra can take several minutes; the startup command allows 15 minutes. No Python installation is required for these database containers or CLI demonstrations.

If Docker Desktop is stopped:

```powershell
docker desktop start
# Wait for the engine to start, then:
.\scripts\setup.ps1
```

On a machine where PowerShell blocks local scripts, invoke a script using a process-only policy override rather than changing the machine policy:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```

To prepare `.env` without downloading or starting anything:

```powershell
.\scripts\setup.ps1 -ConfigureOnly
docker compose config --quiet
```

Use `config --quiet` for validation: plain `docker compose config` prints the resolved passwords.

## Daily startup and verification

```powershell
.\scripts\start.ps1
.\scripts\status.ps1
.\scripts\verify.ps1 -CheckSample
```

Expected: four `healthy` services, Redis `PONG`, a Cassandra version row, MongoDB `{ ok: 1 }`, Neo4j `connected = 1`, and a final `[PASS]` message. `-CheckSample` also verifies enrollment `BT24GCS397` in all four databases and the graph relationship.

Start one database if resources are limited:

```powershell
.\scripts\start.ps1 -Service cassandra
```

Verification and initialization of all four databases require all four services to be running.

## Sample data

```json
{"student_id":101,"name":"Bharat Yadav","enrollment_no":"BT24GCS397","course":"NoSQL Databases","semester":5}
```

Run the following again whenever you want to restore the presentation sample. It updates only student 101 and its associated seminar course data.

```powershell
.\scripts\initialize.ps1
```

Redis stores a student hash and a course string. Cassandra stores a row whose `student_id` is the partition key. MongoDB stores a document with a nested contact object and an interests array. Neo4j stores a Student node, a Course node, and an `ENROLLED_IN` relationship. All demonstrations use the same name and enrollment number.

## Open the database CLIs

The helpers load the credentials inside the containers, so you do not have to paste passwords into terminal commands.

```powershell
.\scripts\cli.ps1 -Database redis
.\scripts\cli.ps1 -Database cassandra
.\scripts\cli.ps1 -Database mongodb
.\scripts\cli.ps1 -Database neo4j
```

Run one helper at a time. Use `exit` to leave Redis, Cassandra, or MongoDB; use `:exit` for Cypher Shell.

Inside Redis CLI:

```text
HGETALL seminar:student:101
GET seminar:course:101
CONFIG GET appendonly appendfsync save
```

Inside Cassandra `cqlsh`:

```sql
DESCRIBE KEYSPACE university;
CONSISTENCY LOCAL_ONE;
SELECT * FROM university.students WHERE student_id = 101;
```

The `NetworkTopologyStrategy` keyspace uses `datacenter1: 1`. With one replica, both `LOCAL_ONE` and `LOCAL_QUORUM` require one replica. The demonstration changes CQL consistency settings without claiming to measure distributed consistency behavior.

Inside MongoDB Shell:

```javascript
use university
db.students.find({student_id: 101})
db.students.getIndexes()
db.students.find({student_id: 101}).hint({student_id: 1}).explain('executionStats')
```

The explicit hint demonstrates index access on this tiny dataset; it does not prove that an index is faster than a collection scan.

Inside Cypher Shell or [Neo4j Browser](http://localhost:7474):

```cypher
MATCH (s:Student {student_id: 101})-[r:ENROLLED_IN]->(c:Course)
RETURN s, r, c;
```

Select **Graph** in Neo4j Browser to see the actual Student and Course nodes. The username is `neo4j`. Read the `NEO4J_PASSWORD` value from your local `.env` for Browser sign-in; keep it out of screenshots.

## Run and test CRUD

```powershell
.\scripts\test-crud.ps1
# Or choose a single service:
.\scripts\test-crud.ps1 -Database mongodb
```

The tests create student **9101**, read it, update semester 5 to 6, delete it, and assert the observed results. Redis additionally checks strings, hashes, sets, TTL expiry, and persistence settings. MongoDB checks nested documents, an extra schema field, and an `IXSCAN` query plan. Neo4j checks relationships and verifies both node and relationship deletion. The persistent presentation sample **101** remains available. The reserved test ID 9101 and Redis keys prefixed `seminar:test:` may be overwritten or deleted when demonstrations run.

Executable command files are in `commands/`: Redis shell/text, Cassandra CQL, MongoDB JavaScript, and Neo4j Cypher. CLI commands execute inside the official containers; no host database client is needed.

## Redis Pub Sub in two terminals

In terminal A, open the Redis helper and subscribe:

```powershell
.\scripts\cli.ps1 -Database redis
```

```text
SUBSCRIBE seminar:announcements
```

In terminal B, open another Redis helper and publish:

```powershell
.\scripts\cli.ps1 -Database redis
```

```text
PUBLISH seminar:announcements "NoSQL seminar live message"
```

The publisher reports the subscriber count, and terminal A displays the live message. Capture both windows together. Pub/Sub messages are transient and are not stored by AOF for later delivery. An automated live subscriber/publisher check is also available:

```powershell
.\scripts\evidence.ps1 -Stage redis-pubsub
```

## Persistence test

```powershell
.\scripts\test-persistence.ps1
```

This first checks student 101, recreates all four containers while keeping their named volumes, and checks the stored sample again **without running seed scripts**. It briefly interrupts database connections. A final `[PASS]` confirms all four retained the sample. Redis has AOF enabled with `appendfsync everysec` and RDB snapshots configured; an abrupt power failure can still lose roughly the last second of AOF writes.

## Screenshots

Genuine captured screenshots are in `screenshots/`. See `SCREENSHOT_GUIDE.md` for filenames, captions, and exact reproduction steps. `scripts/evidence.ps1` executes real commands in a readable terminal. To open a fresh evidence window:

```powershell
.\scripts\open-evidence.ps1 -Stage containers
```

Other stages are `installation`, `redis`, `redis-features`, `redis-pubsub`, `cassandra`, `cassandra-schema`, `mongodb`, `neo4j`, and `verification`. Wait for the command to finish, then use Windows' screenshot tool. `scripts/capture-screen.ps1 -Filename example.png` captures the current foreground desktop from a separate command session. Ensure the intended window is visible before using it; it does not choose or activate a window. After adding or replacing screenshots, run `scripts/update-screenshot-manifest.ps1` to refresh their hashes and dimensions.

## Stop and restart

```powershell
.\scripts\stop.ps1                    # Stop; keep containers and volumes.
.\scripts\start.ps1                   # Start and wait for health.
.\scripts\stop.ps1 -RemoveContainers  # Remove containers/network; keep volumes.
.\scripts\start.ps1                   # Recreate containers with existing data.
```

The named volumes are prefixed `nosql-seminar_`: `redis_data`, `cassandra_data`, `mongodb_data`, `mongodb_config`, `neo4j_data`, and `neo4j_logs`. They live in Docker Desktop's Linux storage, rather than this Windows project directory.

For an intentional, permanent reset only, `docker compose down --volumes` deletes all six project volumes and their database data. Normal stop/restart commands never use that option. After such a reset, run `scripts/setup.ps1` again to initialize empty databases and reseed the sample.

## Credentials and port changes

`.env.example` is safe to share. `.env` contains the generated passwords and is ignored by Git. Never include it in a public repository or screenshots. Neo4j's username is fixed to `neo4j` in this setup. MongoDB's initial username can be changed with `MONGODB_USERNAME` before its volume is initialized.

MongoDB and Neo4j use the initial passwords only when their volumes are empty. Editing `.env` after initialization does not change their existing users. Preserve your `.env` with your local data, or rotate credentials using the respective database's supported commands.

If a host port is occupied, change the relevant `*_PORT` value in `.env` and run `scripts/start.ps1` again. The container-internal ports stay fixed; the CLI helpers continue to work. Use the edited HTTP/Bolt ports when opening Neo4j Browser or connecting from Windows.

## Troubleshooting

```powershell
.\scripts\troubleshoot.ps1
docker compose logs --tail 100 cassandra
docker compose logs --tail 100 neo4j
docker stats --no-stream
```

- **Engine unavailable:** start Docker Desktop, wait for it to report the engine running, and use Linux containers.
- **Cassandra still starting:** allow several minutes, inspect its logs, and retry `scripts/start.ps1`. For a very slow disk, use `scripts/start.ps1 -TimeoutSeconds 1800`.
- **Exit 137 or OOMKilled:** provide more engine memory, stop other heavy workloads, or run one service at a time. Do not increase JVM heaps above the service memory limit.
- **Port already allocated:** edit `.env` host ports or stop the conflicting local application.
- **Authentication failure after editing `.env`:** restore the credentials associated with the existing data volume. Deleting volumes would discard data and is not a password recovery method.
- **Neo4j unrecognized setting:** arbitrary variables beginning `NEO4J_` are interpreted as configuration. The helper password variable is deliberately named `SEMINAR_NEO4J_PASSWORD` inside the container.
- **Sample missing:** run `scripts/initialize.ps1`, then `scripts/verify.ps1 -CheckSample`.
- **PowerShell screenshots show an unrelated window:** foreground the evidence terminal and recapture. Use only images that you visually checked.

## Scope of these deliverables

This implementation delivers the requested Docker infrastructure, CLI demonstrations, verification scripts, genuine screenshots, and setup documentation. The full 8–10 page academic report, PowerPoint, and Python driver modules described in the pasted planning prompt are separate seminar deliverables; these files do not claim that those have been completed.

## Official configuration references

- [Docker Compose services and health checks](https://docs.docker.com/reference/compose-file/services/)
- [Redis persistence](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/)
- [Redis CLI authentication](https://redis.io/docs/latest/develop/tools/cli/)
- [Official Cassandra image configuration](https://hub.docker.com/_/cassandra)
- [Official MongoDB image initialization](https://hub.docker.com/_/mongo)
- [Neo4j Docker configuration](https://neo4j.com/docs/operations-manual/current/docker/configuration/)
- [Neo4j Docker authentication and persistence](https://neo4j.com/docs/operations-manual/current/docker/introduction/)
