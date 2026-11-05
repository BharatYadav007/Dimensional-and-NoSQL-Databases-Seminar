const admin = db.getSiblingDB('admin');
if (!admin.auth(process.env.MONGO_INITDB_ROOT_USERNAME, process.env.MONGO_INITDB_ROOT_PASSWORD).ok) {
  throw new Error('MongoDB authentication failed');
}
const university = db.getSiblingDB('university');
university.students.createIndex({student_id: 1}, {unique: true});
university.students.updateOne(
  {student_id: 101},
  {$set: {name: 'Bharat Yadav', enrollment_no: 'BT24GCS397', course: 'NoSQL Databases', semester: 5,
    contact: {university: 'NIIT University'}, interests: ['NoSQL', 'Databases']}},
  {upsert: true}
);
printjson(university.students.findOne({student_id: 101}, {_id: 0}));
