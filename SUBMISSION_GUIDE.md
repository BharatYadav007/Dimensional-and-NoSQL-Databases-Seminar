# NoSQL seminar submission guide

Author: Bharat Yadav · BT24GCS397 · CS 3102 · NIIT University

The deliverables follow `Seminar-work.docx`. The project is located at `D:\GitHub Repo\University Projects\Seminar\Dimensional-and-NoSQL-Databases-Seminar`.

| Requested deliverable | Project file or folder |
|---|---|
| PowerPoint presentation | `submission/NoSQL_Seminar_Presentation.pptx` |
| Report covering all topics in 8–10 pages | `submission/NoSQL_Seminar_Report.docx` — 10 pages in Microsoft Word |
| Comparison table | `submission/Database_Comparison.md` and `.csv`; also editable in the presentation and report |
| Installation and CLI CRUD code | `scripts/`, `commands/`, `compose.yaml`, `docker/` |
| Basic programming-language usage | `python/demo.py`, pinned `python/requirements.txt`, `docker/python/Dockerfile` |
| Original screenshots | `screenshots/` — all 12 embedded in the presentation; selected captures in the report |
| Viva preparation | `submission/Viva_Questions_and_Answers.md` — 53 questions with short answers |

## Before the seminar

Start Docker Desktop with its Linux engine, then run the following from PowerShell in this repository:

```powershell
.\scripts\start.ps1
.\scripts\verify.ps1 -CheckSample
.\scripts\test-crud.ps1
.\scripts\python-demo.ps1 -NoBuild
```

For the first Python run on a different computer, omit `-NoBuild` so it builds the demonstration image. For a completely new database setup, run `scripts/setup.ps1` first. It prepares a private `.env`, starts the four databases and initializes the sample.

The Python client connects inside the Compose network and cleans up its temporary record. It preserves the permanent student 101, enrollment BT24GCS397 and Course CS3102. CLI CRUD uses separate test records.

## Open the shells

```powershell
.\scripts\cli.ps1 -Database redis
.\scripts\cli.ps1 -Database cassandra
.\scripts\cli.ps1 -Database mongodb
.\scripts\cli.ps1 -Database neo4j
```

Neo4j Browser is available at http://localhost:7474. Credentials are in the private `.env`. The scripts handle credentials without requiring them to be copied into presentation slides.

## Stop and retain data

```powershell
.\scripts\stop.ps1
```

Keep the named volumes. Removing volumes removes the database data. The Compose project name is explicitly `nosql-seminar`, so moving the repository does not require a new data set; rerunning start updates bind mounts to the new folder.

## Scope of the evidence

The screenshots document execution on 29 October 2026. The moved project and Python CRUD were verified on 5 November 2026. Logs are local execution evidence and are ignored by Git. Database data lives in Docker volumes and is not contained in the PPTX, DOCX or repository files; setup scripts reproduce the sample on another computer.

Cassandra has one node and RF 1. MongoDB is standalone. This project demonstrates installation, persistence and functional operations, not production failover or a throughput comparison. Company use cases include dated primary sources; the report explains the qualification needed for the assignment's GitHub session example.
