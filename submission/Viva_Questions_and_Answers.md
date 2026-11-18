# NoSQL seminar viva questions and answers

These are likely questions inferred from the assignment and the actual project, not a prediction of the teacher's exact questions. Practise answering aloud and then point to a command, screenshot or configuration that supports your answer.

## Prepare these ten first

1. Explain the four data models using your student example.
2. Why did you use Docker Compose? What is the difference between an image, a container and a volume?
3. Perform CRUD live in any database and explain the returned values.
4. Why is Redis fast, and how does your setup retain its data?
5. What does TTL do? How is Redis Pub/Sub different from durable messaging?
6. What is Cassandra's partition key? How do replication factor and consistency level differ?
7. Why does LOCAL_QUORUM succeed with only one Cassandra node?
8. What are BSON and schema flexibility? What does IXSCAN prove in your screenshot?
9. Explain the Neo4j nodes, relationship, direction and Cypher query.
10. What did your experiment actually prove, and what would require a cluster or benchmark?

## Project and Docker

**1. What is the objective of your seminar?**  
Compare Redis, Cassandra, MongoDB and Neo4j by installing them, performing CLI and Python CRUD, explaining their concepts, and evaluating workload fit and tradeoffs.

**2. How did you represent the same student in four systems?**  
Redis uses a hash at `seminar:student:101`; Cassandra uses a row keyed by `student_id`; MongoDB uses a document in `university.students`; Neo4j uses a Student connected to a Course by `ENROLLED_IN`.

**3. Why Docker instead of installing four database servers directly?**  
It gives isolated, reproducible services with declared versions, ports and storage. Compose starts and manages the whole environment from one configuration.

**4. Image versus container versus volume?**  
An image packages software and a startup definition. A container is an instance of an image. A volume stores data independently of that container's replacement.

**5. Why is there no custom Dockerfile for each database?**  
The official images already package the database servers. `compose.yaml` supplies configuration and mounts. `docker/python/Dockerfile` packages the additional Python demonstration client.

**6. What are the ports?**  
Redis 6379; Cassandra CQL 9042; MongoDB 27017; Neo4j HTTP 7474 and Bolt 7687. Host access is bound to `127.0.0.1`.

**7. Does a running container mean its database is ready?**  
No. A process may be starting or unable to answer queries. Health checks execute database commands, and `verify.ps1 -CheckSample` checks real queries and the sample data.

**8. What happens if you stop, remove or recreate a container?**  
Stopping retains the container and its volumes. Removing/recreating the container retains named-volume data unless the volumes are also removed. Redis must also persist its in-memory data to those files.

**9. What changed when the repository moved?**  
Relative bind mounts needed to point to the new folder. Compose recreated the containers from the new path. The explicit `nosql-seminar` project name preserved the named-volume identities.

**10. How do you protect credentials?**  
The private `.env` is ignored by Git. Scripts read environment variables rather than placing literal passwords in screenshots or source. This is a local demonstration; production would need stronger secret handling, access controls and transport protection.

Source: [Docker volumes](https://docs.docker.com/engine/storage/volumes/).

## NoSQL fundamentals

**11. What does NoSQL mean?**  
It commonly means “not only SQL”: a family of models beyond conventional relational tables. It does not mean every product has no schema or no transactions.

**12. How is it different from an RDBMS?**  
An RDBMS centers on tables, keys, constraints and SQL joins. These four NoSQL systems center on a key, partition, document or graph. Choose by access pattern, integrity requirements and operational needs.

**13. Is NoSQL always faster or more scalable?**  
No. Performance depends on the query, indexes, data size, deployment and workload. This project's small functional tests do not establish a speed ranking.

**14. Explain horizontal and vertical scaling.**  
Vertical scaling adds resources to one machine. Horizontal scaling distributes work across machines and introduces coordination, partitioning and replication concerns.

**15. Explain CAP without saying “pick any two.”**  
During a network partition, a distributed service cannot guarantee both linearizable consistency and availability for every request. Outside that condition, latency and other tradeoffs still matter.

**16. What are ACID and BASE?**  
ACID describes transaction guarantees: atomicity, consistency, isolation and durability. BASE describes designs allowing soft state and eventual consistency. These labels do not replace the exact guarantees of a particular operation and deployment.

**17. When would you still select a relational database?**  
For strong declarative constraints, multi-entity transactional workflows and flexible SQL reporting. A student administration system may use an RDBMS even if caching or recommendations use NoSQL components.

## Redis

**18. Why is Redis fast?**  
Its common operations access data in memory through purpose-built structures. Actual latency also depends on command complexity, networking, persistence and load.

**19. Which Redis types can you explain?**  
Strings for values/counters, hashes for fields, lists for ordered sequences, sets for unique members and sorted sets for ranked members. The project demonstrates strings, hashes and sets.

**20. Why use a hash for a student?**  
It groups fields under one key and lets a command update one field without replacing an entire serialized profile.

**21. What does TTL do?**  
It sets a key's remaining lifetime. The demo creates a key with `EX 2`, reads it, waits, and observes that it is absent. TTL is expiration, rather than a general guarantee that cached data is fresh.

**22. How do RDB and AOF differ?**  
RDB saves snapshots; AOF records writes. This setup enables both and synchronizes AOF every second. A crash can still lose recent unsynchronized writes.

**23. Why does HSET return zero after your update?**  
It reports newly added fields. Replacing an existing field can succeed while adding zero fields. Read the field to verify the changed value.

**24. What does the return value of PUBLISH mean?**  
It counts subscribers to which Redis sent the message. It is not a durable business-processing acknowledgment.

**25. Can a disconnected Pub/Sub subscriber receive old messages on reconnect?**  
No. Pub/Sub has at-most-once delivery without replay. A durable stream or queue requires different semantics and application handling.

**26. What happens when the configured Redis memory limit is reached?**  
This project uses `noeviction`: writes needing more memory can fail instead of evicting stored student data. A cache deployment might deliberately choose an eviction policy.

Sources: [Redis persistence](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/), [Pub/Sub semantics](https://redis.io/docs/latest/develop/pubsub/).

## Cassandra

**27. What is a keyspace?**  
It groups tables and specifies replication. The project uses `university` with `NetworkTopologyStrategy` and one replica in `datacenter1`.

**28. Partition key versus clustering key?**  
The partition key determines placement. Clustering columns order rows within a partition. Here `student_id` is the entire primary key, so there are no clustering columns.

**29. Replication factor versus consistency level?**  
Replication factor controls how many copies are stored. Consistency level controls how many appropriate replica responses are required to acknowledge an operation.

**30. Why does LOCAL_QUORUM work with one replica?**  
A majority of one is one. At RF 3 it needs two local replicas. The screenshot demonstrates the command, not a realistic multi-node quorum or fault-tolerance test.

**31. Is Cassandra always eventually consistent?**  
No. It exposes tunable read/write consistency. Overlapping read and write acknowledgments can improve visibility; stronger guarantees cost latency or availability. Ordinary quorum operations are not a claim of full serializable transactions.

**32. Is CQL the same as SQL?**  
It looks similar but Cassandra's partition-oriented model is different. Do not assume relational joins or efficient arbitrary filtering. Model the table around a known query.

**33. What is a tombstone?**  
A marker representing a deletion. Replication and compaction must handle it correctly before old data can be safely discarded. Many tombstones can make reads expensive.

**34. Does your Cassandra instance prove high availability?**  
No. RF 1 stores one copy. A multi-node, multi-replica setup with controlled failures is required to demonstrate replica failover.

Sources: [Cassandra architecture](https://cassandra.apache.org/doc/latest/cassandra/architecture/dynamo.html), [data modeling](https://cassandra.apache.org/doc/latest/cassandra/developing/data-modeling/data-modeling_logical.html).

## MongoDB

**35. What is BSON?**  
A binary document representation with types beyond plain JSON, including ObjectId and dates. Documents can contain arrays and nested objects.

**36. Does flexible schema mean no schema?**  
No. The application still has a data model, and MongoDB can enforce validation rules. Optional fields can vary without making field names and types unimportant.

**37. What is the difference between _id and student_id?**  
`_id` is MongoDB's document identifier with its own unique index. `student_id` is the application's identifier; this project adds a separate unique index for it.

**38. What does an index improve and what does it cost?**  
It can speed matching/sorting for suitable queries. It consumes space and adds maintenance work to inserts, deletes and affected updates.

**39. What does IXSCAN establish in your screenshot?**  
The demonstrated plan uses an index. The script explicitly hints the student_id index. It does not prove that this tiny query is faster than a collection scan or that the optimizer would choose that index without the hint.

**40. Is MongoDB atomic? Can your setup run multi-document transactions?**  
Single-document writes are atomic. This standalone deployment cannot run multi-document transactions; those require a replica set or sharded deployment.

**41. Embedding versus referencing?**  
Embed data commonly read/updated together when its size is manageable. Reference shared or independently growing entities. Consider duplication, growth and update consistency.

Sources: [BSON](https://www.mongodb.com/docs/manual/reference/bson-types/), [indexes and write overhead](https://www.mongodb.com/docs/manual/core/write-performance/), [transaction deployment requirements](https://www.mongodb.com/docs/v8.0/data-modeling/enforce-consistency/transactions/).

## Neo4j

**42. Node, label, relationship and property?**  
A node represents an entity; a label groups nodes; a typed directed relationship connects nodes; properties store attributes on nodes or relationships.

**43. Explain your graph query.**  
`MATCH (s:Student {student_id:101})-[r:ENROLLED_IN]->(c:Course) RETURN s,r,c;` starts with the student, follows outgoing enrollment relationships and returns the connected entities. The sample returns two nodes and one relationship.

**44. CREATE versus MERGE?**  
CREATE adds the pattern. MERGE matches the specified pattern or creates it if absent. Correct matching keys and uniqueness constraints are still necessary to avoid unwanted duplicates.

**45. DELETE versus DETACH DELETE?**  
DELETE cannot remove a node that still has relationships. DETACH DELETE removes the selected node and its incident relationships. The test keeps the shared course.

**46. Why use Neo4j for fraud detection?**  
Connections among accounts, devices, addresses and transfers reveal suspicious shared identities and paths. A connection is an investigation lead, not proof of wrongdoing.

**47. Is Neo4j always better than SQL joins?**  
No. Repeated relationship traversals can be a good fit, but the data size, traversal depth, indexes and workload matter. Simple key lookups and unrelated aggregation may favor another model.

Sources: [Neo4j model and transactions](https://neo4j.com/docs/getting-started/whats-neo4j/), [Cypher tutorial](https://neo4j.com/docs/getting-started/cypher/intro-tutorial/).

## Your implementation and conclusions

**48. How do you know the Python program worked?**  
It checks actual returned values after creation and update, verifies absence after deletion, and raises on a mismatch. Neo4j also checks traversal to CS3102. The execution log is `logs/python-driver-crud.txt`.

**49. Why does the Python program use a fresh student ID?**  
It separates temporary tests from sample student 101. Cleanup targets that ID so the permanent sample and shared course remain available.

**50. What did your project prove?**  
Installation and query readiness; working CLI and Python CRUD; the shared sample and graph relationship; configured persistence and retained data after container recreation. It did not establish a production speed ranking or cluster availability.

**51. What would you improve next?**  
Test Cassandra RF 3 across nodes, MongoDB as a replica set, backup restoration, stronger credentials/access controls, transport encryption and representative performance workloads.

**52. Can you defend the company examples in the brief?**  
Use dated primary sources. Netflix's 2022 RENO article identifies Cassandra notification storage; Uber's 2018 M3 article describes early Cassandra use before M3DB. Forbes and eBay have MongoDB cases. Treat the GitHub Redis-session pairing carefully: its cited 2013 session article describes ActiveRecord, not evidence of that exact deployment.

**53. Which database would you choose for a new application?**  
First state the queries and guarantees. Cache/session access suggests Redis; partitioned write-heavy histories suggest Cassandra; variable nested records suggest MongoDB; connected-entity traversals suggest Neo4j. Measure the chosen design against the actual requirements.

## Live demonstration prompts

Open PowerShell in the repository and practise these tasks before the seminar:

```powershell
.\scripts\start.ps1
.\scripts\verify.ps1 -CheckSample
.\scripts\test-crud.ps1
.\scripts\python-demo.ps1 -NoBuild
.\scripts\cli.ps1 -Database redis
```

Be ready to change the CLI argument to `cassandra`, `mongodb` or `neo4j`.

- Show the relevant `compose.yaml` service, published port, health check and named volume.
- Perform create/read/update/delete and explain why the final result confirms deletion.
- Set a short Redis TTL and explain the result after expiry.
- Show Cassandra's `student_id` partition key and RF 1 setting.
- Explain why `LOCAL_ONE` and `LOCAL_QUORUM` both require one response here.
- Show MongoDB's unique index and explain the explicit hint in the screenshot.
- Run the sample Cypher graph query and explain the arrow's direction.
- Explain why deleting a test student should preserve the shared Course node.

## Short opening you can practise

“My seminar compares four NoSQL data models using the same student example. I used Docker Compose to run Redis, Cassandra, MongoDB and Neo4j. I demonstrated CRUD through command-line tools and Python drivers, checked persistence and query readiness, and compared the models by workload. The experiment is local and uses one instance per database, so I distinguish functional evidence from production-scale claims.”
