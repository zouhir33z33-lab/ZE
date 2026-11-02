import '../models/models.dart';
import 'database_helper.dart';

class StudentRepository {
  Future<List<Student>> byClass(int classId, {bool activeOnly = true}) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('students',
        where: activeOnly ? 'class_id = ? AND is_active = 1' : 'class_id = ?',
        whereArgs: [classId],
        orderBy: 'sort_order, last_name COLLATE NOCASE, first_name COLLATE NOCASE');
    return rows.map(Student.fromMap).toList();
  }

  Future<int> insert(Student s) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('students', s.toMap());
  }

  Future<void> update(Student s) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('students', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  /// Recherche d'élèves dans toutes les classes de l'année active.
  Future<List<Map<String, Object?>>> search(String q, {bool onlyExempt = false}) async {
    final db = await DatabaseHelper.instance.database;
    final like = '%${q.replaceAll('%', '')}%';
    return db.rawQuery('''
      SELECT s.*, c.name AS class_name, c.level AS class_level
      FROM students s
      JOIN classes c ON c.id = s.class_id
      JOIN academic_years y ON y.id = c.academic_year_id AND y.is_active = 1
      WHERE s.is_active = 1
        ${onlyExempt ? 'AND s.is_exempt = 1' : ''}
        AND (? = '' OR s.last_name LIKE ? OR s.first_name LIKE ? OR s.student_number LIKE ?)
      ORDER BY s.last_name COLLATE NOCASE, s.first_name COLLATE NOCASE
      LIMIT 200''', [q.trim(), like, like, like]);
  }
}
