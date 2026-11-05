-- student_id is the partition key. RF=1 is a single node demonstration.
CREATE KEYSPACE IF NOT EXISTS university
WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 1};
CREATE TABLE IF NOT EXISTS university.students (
    student_id int PRIMARY KEY, name text, enrollment_no text, course text, semester int
);
CONSISTENCY LOCAL_ONE;
INSERT INTO university.students (student_id, name, enrollment_no, course, semester)
VALUES (9101, 'Bharat Yadav', 'BT24GCS397', 'NoSQL Databases', 5);
SELECT JSON * FROM university.students WHERE student_id = 9101;
UPDATE university.students SET semester = 6 WHERE student_id = 9101;
CONSISTENCY LOCAL_QUORUM;
SELECT JSON * FROM university.students WHERE student_id = 9101;
DELETE FROM university.students WHERE student_id = 9101;
SELECT COUNT(*) AS remaining FROM university.students WHERE student_id = 9101;
