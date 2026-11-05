// Official Mongo image executes this only when /data/db is initially empty.
const university = db.getSiblingDB('university');
if (!university.getCollectionNames().includes('students')) {
  university.createCollection('students');
}
university.students.createIndex({student_id: 1}, {unique: true});
