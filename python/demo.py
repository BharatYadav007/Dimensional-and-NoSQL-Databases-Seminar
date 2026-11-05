r"""Real driver CRUD in all four databases. Uses a fresh test ID and removes it.

Run from the project: .\scripts\python-demo.ps1
Credentials come from Compose environment variables and are never printed.
"""
import json
import os
import secrets
import socket
from datetime import datetime, timezone

import redis
from cassandra import ConsistencyLevel
from cassandra.cluster import Cluster
from cassandra.policies import DCAwareRoundRobinPolicy
from pymongo import MongoClient
from neo4j import GraphDatabase

SID = 100_000_000 + secrets.randbelow(900_000_000)
NAME = 'Bharat Yadav'
ENROLLMENT = 'BT24GCS397'

def checked(condition, message):
    if not condition:
        raise RuntimeError(message)

def demo_redis():
    client = redis.Redis(host=os.environ['REDIS_HOST'],
                         password=os.environ['REDIS_PASSWORD'],
                         decode_responses=True, socket_timeout=10)
    key = f'seminar:python:student:{SID}'
    checked(not client.exists(key), 'Test key already exists')
    try:
        client.hset(key, mapping={'name': NAME, 'enrollment_no': ENROLLMENT, 'semester': 5})
        checked(client.hget(key, 'semester') == '5', 'Redis create/read failed')
        client.hset(key, 'semester', 6)
        checked(client.hget(key, 'semester') == '6', 'Redis update failed')
        client.delete(key)
        checked(not client.exists(key), 'Redis delete failed')
    finally:
        client.delete(key)
        client.close()
    return 'PASS create/read semester=5; update semester=6; deleted key absent'

def demo_cassandra():
    # Python 3.12 supplies asyncore for the driver's pure-Python reactor.
    # Resolve the Docker service name before configuring the contact point.
    host = socket.gethostbyname(os.environ['CASSANDRA_HOST'])
    cluster = Cluster([host], load_balancing_policy=DCAwareRoundRobinPolicy(local_dc='datacenter1'),
                      protocol_version=5, connect_timeout=20)
    session = cluster.connect('university')
    session.default_consistency_level = ConsistencyLevel.LOCAL_ONE
    select = session.prepare('SELECT semester FROM students WHERE student_id=?')
    insert = session.prepare('INSERT INTO students (student_id,name,enrollment_no,course,semester) VALUES (?,?,?,?,?)')
    update = session.prepare('UPDATE students SET semester=? WHERE student_id=?')
    delete = session.prepare('DELETE FROM students WHERE student_id=?')
    checked(session.execute(select, [SID]).one() is None, 'Test row already exists')
    try:
        session.execute(insert, [SID, NAME, ENROLLMENT, 'NoSQL Databases', 5])
        checked(session.execute(select, [SID]).one().semester == 5, 'Cassandra create/read failed')
        session.execute(update, [6, SID])
        checked(session.execute(select, [SID]).one().semester == 6, 'Cassandra update failed')
        session.execute(delete, [SID])
        checked(session.execute(select, [SID]).one() is None, 'Cassandra delete failed')
    finally:
        session.execute(delete, [SID])
        cluster.shutdown()
    return 'PASS create/read semester=5; update semester=6; deleted row absent (RF=1)'

def demo_mongodb():
    client = MongoClient(host=os.environ['MONGODB_HOST'],
                         username=os.environ['MONGODB_USERNAME'],
                         password=os.environ['MONGODB_PASSWORD'], authSource='admin',
                         serverSelectionTimeoutMS=15000)
    students = client.university.students
    key = {'student_id': SID}
    checked(students.find_one(key) is None, 'Test document already exists')
    try:
        students.insert_one({**key, 'name': NAME, 'enrollment_no': ENROLLMENT,
                             'semester': 5, 'contact': {'university': 'NIIT University'},
                             'interests': ['NoSQL', 'Databases']})
        checked(students.find_one(key)['semester'] == 5, 'MongoDB create/read failed')
        students.update_one(key, {'$set': {'semester': 6}})
        checked(students.find_one(key)['semester'] == 6, 'MongoDB update failed')
        checked(students.delete_one(key).deleted_count == 1, 'MongoDB delete failed')
        checked(students.find_one(key) is None, 'MongoDB document still exists')
    finally:
        students.delete_one(key)
        client.close()
    return 'PASS create/read semester=5; update semester=6; deleted document absent'

def demo_neo4j():
    with GraphDatabase.driver(os.environ['NEO4J_URI'],
                              auth=('neo4j', os.environ['NEO4J_PASSWORD'])) as driver:
        driver.verify_connectivity()
        with driver.session(database='neo4j') as session:
            row = session.run('MATCH (s:Student {student_id:$id}) RETURN count(s) AS n', id=SID).single()
            checked(row['n'] == 0, 'Test node already exists')
            try:
                session.run('CREATE (s:Student {student_id:$id,name:$name,enrollment_no:$en,semester:5}) '
                            'WITH s MATCH (c:Course {code:"CS3102"}) CREATE (s)-[:ENROLLED_IN]->(c)',
                            id=SID, name=NAME, en=ENROLLMENT).consume()
                row = session.run('MATCH (s:Student {student_id:$id})-[:ENROLLED_IN]->(c:Course) '
                                  'RETURN s.semester AS semester,c.code AS course', id=SID).single()
                checked(row is not None and row['semester'] == 5 and row['course'] == 'CS3102',
                        'Neo4j create/read/traversal failed')
                row = session.run('MATCH (s:Student {student_id:$id}) SET s.semester=6 '
                                  'RETURN s.semester AS semester', id=SID).single()
                checked(row['semester'] == 6, 'Neo4j update failed')
                session.run('MATCH (s:Student {student_id:$id}) DETACH DELETE s', id=SID).consume()
                row = session.run('MATCH (s:Student {student_id:$id}) RETURN count(s) AS n', id=SID).single()
                checked(row['n'] == 0, 'Neo4j delete failed')
            finally:
                session.run('MATCH (s:Student {student_id:$id}) DETACH DELETE s', id=SID).consume()
    return 'PASS node/relationship created and traversed; semester=6; test node deleted'

if __name__ == '__main__':
    print('Python driver CRUD | UTC ' + datetime.now(timezone.utc).isoformat())
    print('Temporary student_id: ' + str(SID) + '; permanent sample 101 is preserved')
    results = {}
    for name, demo in [('Redis', demo_redis), ('Cassandra', demo_cassandra),
                       ('MongoDB', demo_mongodb), ('Neo4j', demo_neo4j)]:
        results[name] = demo()
        print(name + ': ' + results[name])
    print(json.dumps({'status': 'PASS', 'databases': list(results), 'test_id': SID}))
