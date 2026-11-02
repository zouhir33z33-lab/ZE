import '../models/models.dart';
import 'database_helper.dart';

class TimetableRepository {
  Future<List<TimetableSlot>> slotsOfYear(int yearId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('timetable_slots',
        where: 'academic_year_id = ?', whereArgs: [yearId],
        orderBy: 'day_of_week, start_time');
    return rows.map(TimetableSlot.fromMap).toList();
  }

  Future<int> insertSlot(TimetableSlot s) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('timetable_slots', s.toMap());
  }

  Future<void> updateSlot(TimetableSlot s) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('timetable_slots', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
  }

  Future<void> deleteSlot(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('timetable_slots', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PedagogicalSheet>> sheets() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('pedagogical_sheets', orderBy: 'created_at DESC, id DESC');
    return rows.map(PedagogicalSheet.fromMap).toList();
  }
}
