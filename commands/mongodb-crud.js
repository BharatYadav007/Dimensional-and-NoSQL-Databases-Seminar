const admin = db.getSiblingDB('admin');
if (!admin.auth(process.env.MONGO_INITDB_ROOT_USERNAME, process.env.MONGO_INITDB_ROOT_PASSWORD).ok) {
  throw new Error('MongoDB authentication failed');
}
const students = db.getSiblingDB('university').students;
const show = process.env.SEMINAR_COMPACT_OUTPUT === '1' ? (value) => print(EJSON.stringify(value)) : printjson;
function check(condition, message) { if (!condition) throw new Error(message); }
students.createIndex({student_id: 1}, {unique: true});
students.deleteOne({student_id: 9101}); // Only this demonstration's reserved ID.
print('CREATE insertOne student_id=9101');
show(students.insertOne({student_id: 9101, name: 'Bharat Yadav', enrollment_no: 'BT24GCS397',
  course: 'NoSQL Databases', semester: 5, contact: {university: 'NIIT University'}, interests: ['NoSQL', 'Databases']}));
print('READ find student_id=9101');
show(students.find({student_id: 9101}, {_id: 0}).toArray());
check(students.findOne({student_id: 9101}).semester === 5, 'Create/read failed');
print('UPDATE updateOne semester=6 and flexible field project');
show(students.updateOne({student_id: 9101}, {$set: {semester: 6, project: 'NoSQL seminar'}}));
show(students.findOne({student_id: 9101}, {_id: 0}));
check(students.findOne({student_id: 9101}).semester === 6, 'Update/read failed');
print('INDEX query plan (hint requests the student_id index even for this tiny data set)');
show(students.find({student_id: 9101}).hint({student_id: 1}).explain('executionStats').queryPlanner.winningPlan);
print('DELETE deleteOne and verification');
show(students.deleteOne({student_id: 9101}));
show(students.find({student_id: 9101}).toArray());
check(students.countDocuments({student_id: 9101}) === 0, 'Deletion check failed');
print('[PASS] MongoDB CRUD, nested documents, arrays, flexible field and index query plan.');
