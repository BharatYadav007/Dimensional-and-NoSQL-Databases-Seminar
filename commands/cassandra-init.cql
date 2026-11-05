CREATE KEYSPACE IF NOT EXISTS university
WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 1};

CREATE TABLE IF NOT EXISTS university.students (
    student_id int PRIMARY KEY,
    name text,
    enrollment_no text,
    course text,
    semester int
);

CONSISTENCY LOCAL_ONE;
INSERT INTO university.students (student_id, name, enrollment_no, course, semester)
VALUES (101, 'Bharat Yadav', 'BT24GCS397', 'NoSQL Databases', 5);
SELECT * FROM university.students WHERE student_id = 101;
