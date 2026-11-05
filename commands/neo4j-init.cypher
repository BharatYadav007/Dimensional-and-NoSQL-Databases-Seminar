CREATE CONSTRAINT seminar_student_id IF NOT EXISTS FOR (s:Student) REQUIRE s.student_id IS UNIQUE;
CREATE CONSTRAINT seminar_course_code IF NOT EXISTS FOR (c:Course) REQUIRE c.code IS UNIQUE;
MERGE (s:Student {student_id: 101})
SET s.name = 'Bharat Yadav', s.enrollment_no = 'BT24GCS397', s.course = 'NoSQL Databases', s.semester = 5
MERGE (c:Course {code: 'CS3102'})
SET c.name = 'NoSQL Databases'
MERGE (s)-[:ENROLLED_IN]->(c)
RETURN s, c;
