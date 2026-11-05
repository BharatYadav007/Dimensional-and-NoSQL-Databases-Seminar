# Database comparison

| Database | Data model | Main strength | Main limitation | Typical use |
| --- | --- | --- | --- | --- |
| Redis | Key–value with rich types | Fast memory access; TTL | RAM cost; durability needs configuration | Cache; session state |
| Cassandra | Wide column | Distributed writes and replication | Query driven schema; cluster operations | Events; time series |
| MongoDB | BSON documents | Nested data and flexible fields | Indexes and duplication add cost | Content; product catalogs |
| Neo4j | Property graph | Relationship traversal and patterns | Memory and graph modeling costs | Fraud; knowledge graphs |

The local project uses one instance per database. Cassandra uses RF 1; MongoDB is standalone. No performance benchmark or failover result is implied.

Sources: [redis](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/), [cassandra](https://cassandra.apache.org/doc/latest/cassandra/architecture/dynamo.html), [bson](https://www.mongodb.com/docs/manual/reference/bson-types/), [neo4j](https://neo4j.com/docs/getting-started/whats-neo4j/)
