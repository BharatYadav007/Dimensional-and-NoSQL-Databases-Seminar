# NoSQL seminar live demo

## Connect to the databases

Start `nosql-seminar` in Docker Desktop, then open PowerShell in the project folder.

```powershell
Set-Location 'D:\GitHub Repo\University Projects\Seminar\Dimensional-and-NoSQL-Databases-Seminar'
```

Run the command for the database you want to open.

```powershell
# Redis
docker compose exec redis redis-cli --askpass

# Cassandra
docker compose exec cassandra cqlsh 127.0.0.1 9042 -k university

# MongoDB
docker compose exec mongodb mongosh university --username seminar_admin --authenticationDatabase admin --password

# Neo4j
docker compose exec neo4j cypher-shell -a bolt://127.0.0.1:7687 -u neo4j
```

When prompted, use the matching `REDIS_PASSWORD`, `MONGODB_PASSWORD`, or `NEO4J_PASSWORD` from the project's `.env`. If you changed `MONGODB_USERNAME`, use that value in place of `seminar_admin`. Cassandra needs no password in this setup.

For the graphical interface, sign in as `neo4j` in [Neo4j Browser](http://localhost:7474).

## Show schema

Run the commands for each database in its own shell after connecting.

### Redis schema in redis-cli

Inspect the stored key type and hash fields.

```text
TYPE seminar:student:101
HKEYS seminar:student:101
```

### Cassandra schema in cqlsh

Show the keyspace definition, then the table's columns, data types, and primary key.

```sql
DESCRIBE KEYSPACE university;
DESCRIBE TABLE university.students;
```

### MongoDB schema in mongosh

Show the collections, the `students` collection options (including a validator if configured), and its indexes.

```javascript
use university
show collections
db.getCollectionInfos({ name: "students" })
db.students.getIndexes()
```

### Neo4j schema in Browser or cypher-shell

Use **Graph** view in Neo4j Browser for the schema visualization. Run each statement individually.

```cypher
CALL db.schema.visualization();
SHOW CONSTRAINTS;
SHOW INDEXES;
```

## Show all data

### Redis

List the seminar keys in `redis-cli`. If the returned cursor is nonzero, use it in place of the first `0` and repeat until Redis returns cursor `0`.

```text
SCAN 0 MATCH seminar:* COUNT 100
```

Read the values of the seeded keys according to their types.

```text
HGETALL seminar:student:101
GET seminar:course:101
SMEMBERS seminar:courses
```

For additional keys from `SCAN`, use `TYPE <key>` and the matching read command.

### Cassandra

Run in `cqlsh` to show every row in the students table.

```sql
SELECT * FROM university.students;
```

### MongoDB

Run in `mongosh` to print every document in the students collection.

```javascript
use university
db.students.find({}).forEach(doc => printjson(doc))
```

### Neo4j

Run in Neo4j Browser or `cypher-shell` to show every node and relationship, including nodes with no relationships. In the browser, select **Graph** view.

```cypher
MATCH (n)
OPTIONAL MATCH (n)-[r]->(m)
RETURN n, r, m;
```

## Show sample data and run CRUD

Show the structure first, then the existing student `101`, then create, read, update, and delete test student `9101`. Run each block in its database shell.

### Redis

In `redis-cli`, show the existing student's fields and values.

```text
HGETALL seminar:student:101
```

Create and read the test hash, update the semester from `5` to `6`, then delete it.

```text
HSET seminar:test:profile:9101 student_id 9101 name "Demo Student" semester 5
HGETALL seminar:test:profile:9101
HSET seminar:test:profile:9101 semester 6
HGET seminar:test:profile:9101 semester
DEL seminar:test:profile:9101
EXISTS seminar:test:profile:9101
```

The final `EXISTS` should return `0`.

### Cassandra

In `cqlsh`, show the existing student and a sample of the table's rows.

```sql
SELECT * FROM university.students WHERE student_id = 101;
SELECT * FROM university.students LIMIT 10;
```

```sql
INSERT INTO university.students (student_id, name, enrollment_no, course, semester)
VALUES (9101, 'Demo Student', 'DEMO9101', 'NoSQL Databases', 5);

SELECT * FROM university.students WHERE student_id = 9101;

UPDATE university.students SET semester = 6 WHERE student_id = 9101;
SELECT * FROM university.students WHERE student_id = 9101;

DELETE FROM university.students WHERE student_id = 9101;
SELECT * FROM university.students WHERE student_id = 9101;
```

The final query should show **0 rows**.

### MongoDB

In `mongosh`, show the sample document and point out its nested `contact` field and `interests` array.

```javascript
use university
db.students.findOne({ student_id: 101 })
```

```javascript
db.students.insertOne({ student_id: 9101, name: "Demo Student", semester: 5 })
db.students.findOne({ student_id: 9101 })
db.students.updateOne({ student_id: 9101 }, { $set: { semester: 6 } })
db.students.findOne({ student_id: 9101 })
db.students.deleteOne({ student_id: 9101 })
db.students.findOne({ student_id: 9101 })
```

The final `findOne()` should return `null`.

### Neo4j

Run each statement individually in Neo4j Browser or `cypher-shell`. In the browser, use **Graph** view to show the existing student's enrollment.

```cypher
MATCH (s:Student {student_id: 101})-[r:ENROLLED_IN]->(c:Course)
RETURN s, r, c;
```

Create a test student linked to the existing course, read the relationship, update the semester, then delete the test student and its relationship.

```cypher
MATCH (c:Course {code: 'CS3102'})
CREATE (s:Student {student_id: 9101, name: 'Demo Student', semester: 5})
       -[:ENROLLED_IN]->(c)
RETURN s, c;

MATCH (s:Student {student_id: 9101})-[r:ENROLLED_IN]->(c:Course)
RETURN s, r, c;

MATCH (s:Student {student_id: 9101})
SET s.semester = 6
RETURN s.student_id, s.semester;

MATCH (s:Student {student_id: 9101})
DETACH DELETE s;

MATCH (s:Student {student_id: 9101})
RETURN count(s) AS remaining;
```

The final count should be `0`. The shared course remains available for student `101`.

## Run the scripted CRUD demo

From PowerShell in the project folder, run the [CRUD demo script](scripts/test-crud.ps1) to demonstrate all four databases.

```powershell
.\scripts\test-crud.ps1
```
