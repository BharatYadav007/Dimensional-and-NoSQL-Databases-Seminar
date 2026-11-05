// The reserved test IDs differ from the sample displayed in Neo4j Browser.
MERGE (s:Student {student_id:9101})
SET s.name='Bharat Yadav', s.enrollment_no='BT24GCS397', s.course='NoSQL Databases', s.semester=5
MERGE (c:Course {code:'SEMINAR-TEST-9101'}) SET c.name='NoSQL Databases'
MERGE (s)-[:ENROLLED_IN]->(c);
MATCH (s:Student {student_id:9101})-[r:ENROLLED_IN]->(c:Course {code:'SEMINAR-TEST-9101'})
RETURN s.name AS name, s.semester AS created_semester, type(r) AS relationship, c.name AS course;
MATCH (s:Student {student_id:9101}) SET s.semester=6 RETURN s.semester AS updated_semester;
MATCH (s:Student {student_id:9101}) DETACH DELETE s;
MATCH (c:Course {code:'SEMINAR-TEST-9101'}) DETACH DELETE c;
MATCH (s:Student {student_id:9101}) RETURN count(s) AS remaining_students;
MATCH ()-[r:ENROLLED_IN]->(:Course {code:'SEMINAR-TEST-9101'}) RETURN count(r) AS remaining_relationships;
